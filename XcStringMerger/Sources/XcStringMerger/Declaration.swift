// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

public typealias LanguageCode = String
public typealias StringKey = String

public struct StringCatalogV1: Hashable, Equatable, Codable, Clonable, Sendable {
  public let sourceLanguage: String
  public let strings: [StringKey: Localizations]

  public let version: String

  public func clone() -> Self {
    Self(sourceLanguage: sourceLanguage, strings: strings.clone(), version: version)
  }
}

public struct Localizations: Hashable, Equatable, Codable, Clonable, Sendable {
  public let comment: String?
  public let extractionState: String? // ex. "manual"
  public let localizations: [LanguageCode: LocalizedString]

  public init(comment: String?, extractionState: String?, localizations: [LanguageCode: LocalizedString]) {
    self.comment = comment
    self.extractionState = extractionState
    self.localizations = localizations
  }

  public init(localizations: [LanguageCode: LocalizedString]) {
    self.init(comment: nil, extractionState: nil, localizations: localizations)
  }

  public func withNewLocalizations(_ newLocalizations: [LanguageCode: LocalizedString]) -> Self {
    Self(comment: comment, extractionState: extractionState, localizations: newLocalizations)
  }

  public func clone() -> Self {
    Self(comment: comment, extractionState: extractionState, localizations: localizations.clone())
  }
}

public struct LocalizedString: Hashable, Equatable, Codable, Clonable, Sendable {
  public let stringUnit: StringUnit

  public func clone() -> Self {
    Self(stringUnit: stringUnit.clone())
  }
}

public struct StringUnit: Hashable, Equatable, Codable, Clonable, Sendable {
  public let state: String // ex. "translated"
  public let value: String

  public func clone() -> Self {
    Self(state: state, value: value)
  }
}

public protocol Clonable {
  func clone() -> Self
}

extension Dictionary: Clonable
  where
  Value: Clonable
{
  public func clone() -> Self {
    Self(uniqueKeysWithValues: enumerated().map { _, element in
      (element.key, element.value.clone())
    })
  }
}

extension XcStringMerger.Strategy: Codable {
  enum CodingError: Error {
    case unknownValue(String)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .merge:
      try container.encode("merge")
    case .mergeTranslated:
      try container.encode("mergeTranslated")
    case .replace:
      try container.encode("replace")
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)

    switch rawValue {
    case "merge":
      self = .merge
      // merge_translated is for <= SCMerger 1.0.3
    case "merge_translated", "mergeTranslated":
      self = .mergeTranslated
    case "replace":
      self = .replace
    default:
      throw CodingError.unknownValue(rawValue)
    }
  }
}
