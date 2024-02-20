// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import os
import Foundation
import XcStringMerger

private let logger = Logger()

struct OutputCatalog: Sendable {
  let catelog: StringCatalogV1?

  var json: String {
    guard let catelog else { return "" }

    do {
      return try encodeCatalog(of: catelog)
    } catch {
      logger.error("encoding catalog: \(error)")
      return ""
    }
  }

  func getTranslatedPercentageOf(languageCode: LanguageCode) -> Double {
    guard let catelog else { return 0.0 }

    return catelog.strings.map { _, localizations -> Double in
      guard let localization = localizations.localizations[languageCode] else {
        return 0.0
      }

      return localization.stringUnit.state == "translated" ? 1.0 : 0.0
    }.reduce(0, +) / Double(catelog.strings.count)
  }
}

enum OutputCatalogError: Error, LocalizedError {
  case encodeFailed
  case decodeFailed
  case serializeFailed(Error)
  case deserializeFailed(Error)

  var errorDescription: String? {
    switch self {
    case .encodeFailed:
      return String(localized: "Encode failed")
    case .decodeFailed:
      return String(localized: "Decode failed")
    case let .serializeFailed(error):
      return String(localized: "Serialize to JSON failed: \(error.localizedDescription)")
    case let .deserializeFailed(error):
      return String(localized: "Deserialize from JSON failed: \(error.localizedDescription)")
    }
  }
}

func decodeCatalog(of catalogString: String) throws -> StringCatalogV1 {
  let decoder = JSONDecoder()

  guard let catalogData = catalogString.data(using: .utf8) else {
    throw OutputCatalogError.encodeFailed
  }

  return try Result {
    try decoder.decode(StringCatalogV1.self, from: catalogData)
  }.mapError(OutputCatalogError.deserializeFailed).get()
}

func encodeCatalog(of catalog: StringCatalogV1) throws -> String {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

  let catalogData = try Result {
    try encoder.encode(catalog)
  }.mapError(OutputCatalogError.serializeFailed).get()

  guard let result = String(data: catalogData, encoding: .utf8) else {
    throw OutputCatalogError.decodeFailed
  }

  return result
}

nonisolated func mergeDecodableCatalog(_ input: MergerInput) async throws -> OutputCatalog {
  let currentCatalog = try decodeCatalog(of: input.currentCatalogRaw)
  await Task.yield()
  try Task.checkCancellation()

  let translatedCatalog = try decodeCatalog(of: input.translatedCatalogRaw)
  await Task.yield()
  try Task.checkCancellation()

  let merger = XcStringMerger(current: currentCatalog, translated: translatedCatalog)
  let merged = merger.mergeTranslation(of: input.languageCode, by: input.strategy)

  return OutputCatalog(catelog: merged)
}
