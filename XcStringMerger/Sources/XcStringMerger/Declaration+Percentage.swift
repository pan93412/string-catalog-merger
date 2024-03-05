// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

public extension StringCatalogV1 {
  /// Get the translated percentage in a language.
  func getTranslatedPercentage(in languageCode: LanguageCode) -> Double {
    strings.map { _, localizations -> Double in
      localizations.localizations[languageCode]?.stringUnit.state == "translated"
        ? 1.0
        : 0.0
    }.reduce(0, +) / Double(strings.count)
  }
}
