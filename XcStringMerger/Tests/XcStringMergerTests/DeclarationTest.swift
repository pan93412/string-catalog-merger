// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation
@testable import XcStringMerger
import XCTest

final class DeclarationTests: XCTestCase {
  func testStructure() throws {
    let given = """
    {
      "sourceLanguage" : "en",
      "strings" : {
        "Hello, world!" : {
          "comment" : "Post install",
          "localizations" : {
            "zh-Hans" : {
              "stringUnit" : {
                "state" : "translated",
                "value" : "你好，世界"
              }
            }
          }
        }
      },
      "version" : "1.0"
    }
    """
    let expected = StringCatalogV1(
      sourceLanguage: "en",
      strings: [
        "Hello, world!": Localizations(
          comment: "Post install",
          extractionState: nil,
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(
                state: "translated",
                value: "你好，世界"
              )
            ),
          ]
        ),
      ],
      version: "1.0"
    )

    let actual = try JSONDecoder().decode(StringCatalogV1.self, from: given.data(using: .utf8)!)

    XCTAssertEqual(expected, actual)
  }
}
