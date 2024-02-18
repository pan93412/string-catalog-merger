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
        "Hello, world!": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好，世界")
          ),
        ]),
      ],
      version: "1.0"
    )

    let actual = try JSONDecoder().decode(StringCatalogV1.self, from: given.data(using: .utf8)!)

    XCTAssertEqual(expected, actual)
  }
}
