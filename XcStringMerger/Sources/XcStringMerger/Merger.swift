// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation
import os

public class XcStringMerger {
  let currentCatalog: StringCatalogV1
  let translatedCatalog: StringCatalogV1

  public init(current currentCatalog: StringCatalogV1, translated translatedCatalog: StringCatalogV1) {
    self.currentCatalog = currentCatalog.clone()
    self.translatedCatalog = translatedCatalog
  }

  /// Merge the translation from new to base based on the strategy.
  public func mergeTranslation(of lang: LanguageCode, by strategy: Strategy) -> StringCatalogV1 {
    var mergedStrings = [StringKey: Localizations]()

    for (stringKey, localizationsOfTranslatedCatalog) in translatedCatalog.strings {
      guard let localizationsOfCurrentCatalog = currentCatalog.strings[stringKey] else {
        NSLog("string %@ is not presented in the current catalog", stringKey)
        continue
      }

      var currentLocalizations = localizationsOfCurrentCatalog.localizations.clone()

      guard let stringUnitOfTranslated = localizationsOfTranslatedCatalog.localizations[lang] else {
        NSLog("string %@ has not been translated to %@ – use the current one", stringKey, lang)

        if strategy == .replace {
          NSLog("remove the %@ localization from the string %@ of current catalog (replace)", lang, stringKey)
          currentLocalizations.removeValue(forKey: lang)
        }

        mergedStrings[stringKey] = Localizations(localizations: currentLocalizations)

        continue
      }

      // for .merge and .replace, we allow replacing.
      if strategy == .mergeTranslated, stringUnitOfTranslated.stringUnit.state != "translated" {
        NSLog("string %@ has not been reviewed in %@ – use the current one (not merge)", stringKey, lang)

        mergedStrings[stringKey] = Localizations(localizations: currentLocalizations)
        continue
      }

      // replace the stringUnit with the currentOne
      currentLocalizations[lang] = stringUnitOfTranslated
      mergedStrings[stringKey] = Localizations(localizations: currentLocalizations)
    }

    return StringCatalogV1(sourceLanguage: currentCatalog.sourceLanguage, strings: mergedStrings, version: currentCatalog.version)
  }

  public enum Strategy: CustomStringConvertible, Equatable {
    /// Replace the whole localization of a given language from translatedCatalog to currentCatalog,
    /// which means that:
    ///
    /// * If the string is translated in translatedCatalog, it copies to currentCatalog
    /// * If the string is marked “Reviewing” in translatedCatalog, it still copies to currentCatalog
    /// * It the string is not translated in translatedCatalog, it deletes the corresponding one in currentCatalog
    ///   even the currentCatalog has its translation.
    case replace

    /// Merge all localizations for a given language from translatedCatalog to currentCatalog,
    /// which means that:
    ///
    /// * If the string is translated in translatedCatalog, it copies to currentCatalog
    /// * If the string is marked “Reviewing” in translatedCatalog, it still copies to currentCatalog
    /// * It the string is not translated in translatedCatalog, it leaves the corresponding one in currentCatalog as it is
    case merge

    /// Merge the translated localizations for a given language from translatedCatalog to currentCatalog,
    /// which means that:
    ///
    /// * If the string is translated in translatedCatalog, it copies to currentCatalog
    /// * If the string is marked “Reviewing” in translatedCatalog, it leaves the corresponding one in currentCatalog as it is
    /// * It the string is not translated in translatedCatalog, it leaves the corresponding one in currentCatalog as it is
    case mergeTranslated

    public var description: String {
      switch self {
      case .replace: NSLocalizedString("Replace", bundle: .module, comment: "Strategy")
      case .merge: NSLocalizedString("Merge", bundle: .module, comment: "Strategy")
      case .mergeTranslated: NSLocalizedString("Merge translated", bundle: .module, comment: "Strategy")
      }
    }
  }
}

public enum XcStringMergerErrors: Error, LocalizedError {
  case noLanguage(code: LanguageCode)

  public var errorDescription: String? {
    switch self {
    case let .noLanguage(code): NSLocalizedString("No such language: \(code)", bundle: .module, comment: "Error description")
    }
  }
}
