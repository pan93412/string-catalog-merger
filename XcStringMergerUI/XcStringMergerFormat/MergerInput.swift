//
//  MergerInput.swift
//  XcStringMergerUI
//
//  Created by Yi-Jyun Pan on 2024/2/18.
//

import Foundation
import XcStringMerger

struct MergerInput: Identifiable, Codable {
  var id = UUID()

  var currentCatalogRaw: String = ""
  var translatedCatalogRaw: String = ""

  var strategy: XcStringMerger.Strategy = .merge
  var languageCode: LanguageCode = ""
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
      try container.encode("merge_translated")
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
    case "merge_translated":
      self = .mergeTranslated
    case "replace":
      self = .replace
    default:
      throw CodingError.unknownValue(rawValue)
    }
  }
}
