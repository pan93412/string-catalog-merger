// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation

@available(macOS 10.15, *)
public extension StringCatalogV1 {
  func serialize() throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

    do {
      return try encoder.encode(self)
    } catch {
      throw StringCatalogError.serializeFailed(error)
    }
  }

  func serialize() throws -> String {
    let data: Data = try serialize()

    guard let result = String(data: data, encoding: .utf8) else {
      throw StringCatalogError.decodeFailed
    }

    return result
  }
}

public extension StringCatalogV1 {
  static func deserialize(of data: Data) throws -> Self {
    let decoder = JSONDecoder()

    do {
      return try decoder.decode(Self.self, from: data)
    } catch {
      throw StringCatalogError.deserializeFailed(error)
    }
  }

  static func deserialize(of dataString: String) throws -> Self {
    guard let data = dataString.data(using: .utf8) else {
      throw StringCatalogError.encodeFailed
    }

    return try deserialize(of: data)
  }
}

enum StringCatalogError: Error, LocalizedError {
  case encodeFailed
  case decodeFailed
  case serializeFailed(Error)
  case deserializeFailed(Error)

  var errorDescription: String? {
    switch self {
    case .encodeFailed:
      return NSLocalizedString("Encode failed", bundle: .module, comment: "StringCatalogError")
    case .decodeFailed:
      return NSLocalizedString("Decode failed", bundle: .module, comment: "StringCatalogError")
    case let .serializeFailed(error):
      return String(format: NSLocalizedString("Serialize to JSON failed: %@", bundle: .module, comment: "StringCatalogError"), error.localizedDescription)
    case let .deserializeFailed(error):
      return String(format: NSLocalizedString("Deserialize from JSON failed: %@", bundle: .module, comment: "StringCatalogError"), error.localizedDescription)
    }
  }
}
