// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

@testable import XcStringMerger
import XCTest

final class MergerTests: XCTestCase {
  let mockCurrentCatalog = StringCatalogV1(
    sourceLanguage: "en",
    strings: [
      "Hello": Localizations(localizations: [
        "zh-Hans": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "你好")
        ),
        "zh-Hant": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "你好")
        ),
      ]),
      "World": Localizations(
        comment: "suffix of Hello",
        extractionState: nil,
        localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "世界")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "needs_review", value: "你好")
          ),
        ]
      ),
      "Apple": Localizations(
        comment: nil,
        extractionState: "manual",
        localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "苹果")
          ),
        ]
      ),
    ],
    version: "1.0"
  )

  let mockTranslatedCatalog = StringCatalogV1(
    sourceLanguage: "en",
    strings: [
      "Hello": Localizations(localizations: [
        "zh-Hant": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "你好")
        ),
      ]),
      "World": Localizations(
        comment: "suffix of Hello",
        extractionState: nil,
        localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "世界")
          ),
        ]
      ),
      "Apple": Localizations(
        comment: nil,
        extractionState: "manual",
        localizations: [
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "needs_review", value: "蘋果")
          ),
        ]
      ),
    ],
    version: "1.0"
  )

  func newMerger() -> XcStringMerger {
    XcStringMerger(current: mockCurrentCatalog, translated: mockTranslatedCatalog)
  }

  func testReplaceStrategy() throws {
    let merger = newMerger()
    let mergedCatalog = merger.mergeTranslation(of: "zh-Hant", by: .replace)

    XCTAssertEqual(mergedCatalog, StringCatalogV1(
      sourceLanguage: "en",
      strings: [
        "Hello": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好")
          ),
        ]),
        "World": Localizations(
          comment: "suffix of Hello",
          extractionState: nil,
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(state: "translated", value: "世界")
            ),
          ]
        ),
        "Apple": Localizations(
          comment: nil,
          extractionState: "manual",
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(state: "translated", value: "苹果")
            ),
            "zh-Hant": LocalizedString(
              stringUnit: StringUnit(state: "needs_review", value: "蘋果")
            ),
          ]
        ),
      ],
      version: "1.0"
    ))
  }

  func testMergeStrategy() throws {
    let merger = newMerger()
    let mergedCatalog = merger.mergeTranslation(of: "zh-Hant", by: .merge)

    XCTAssertEqual(mergedCatalog, StringCatalogV1(
      sourceLanguage: "en",
      strings: [
        "Hello": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好")
          ),
        ]),
        "World": Localizations(
          comment: "suffix of Hello",
          extractionState: nil,
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(state: "translated", value: "世界")
            ),
            "zh-Hant": LocalizedString(
              stringUnit: StringUnit(state: "needs_review", value: "你好")
            ),
          ]
        ),
        "Apple": Localizations(
          comment: nil,
          extractionState: "manual",
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(state: "translated", value: "苹果")
            ),
            "zh-Hant": LocalizedString(
              stringUnit: StringUnit(state: "needs_review", value: "蘋果")
            ),
          ]
        ),
      ],
      version: "1.0"
    ))
  }

  func testMergeTranslatedStrategy() throws {
    let merger = newMerger()
    let mergedCatalog = merger.mergeTranslation(of: "zh-Hant", by: .mergeTranslated)

    XCTAssertEqual(mergedCatalog, StringCatalogV1(
      sourceLanguage: "en",
      strings: [
        "Hello": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "你好")
          ),
        ]),
        "World": Localizations(
          comment: "suffix of Hello",
          extractionState: nil,
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(state: "translated", value: "世界")
            ),
            "zh-Hant": LocalizedString(
              stringUnit: StringUnit(state: "needs_review", value: "你好")
            ),
          ]
        ),
        "Apple": Localizations(
          comment: nil,
          extractionState: "manual",
          localizations: [
            "zh-Hans": LocalizedString(
              stringUnit: StringUnit(state: "translated", value: "苹果")
            ),
          ]
        ),
      ],
      version: "1.0"
    ))
  }
}
