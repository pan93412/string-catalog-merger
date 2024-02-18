import XCTest
@testable import XcStringMerger

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
        )
      ]),
      "World": Localizations(localizations: [
        "zh-Hans": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "世界")
        ),
        "zh-Hant": LocalizedString(
          stringUnit: StringUnit(state: "needs_review", value: "你好")
        ),
      ]),
      "Apple": Localizations(localizations: [
        "zh-Hans": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "苹果")
        ),
      ])
    ],
    version: "1.0"
  )

  let mockTranslatedCatalog = StringCatalogV1(
    sourceLanguage: "en",
    strings: [
      "Hello": Localizations(localizations: [
        "zh-Hant": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "你好")
        )
      ]),
      "World": Localizations(localizations: [
        "zh-Hans": LocalizedString(
          stringUnit: StringUnit(state: "translated", value: "世界")
        ),
      ]),
      "Apple": Localizations(localizations: [
        "zh-Hant": LocalizedString(
          stringUnit: StringUnit(state: "needs_review", value: "蘋果")
        )
      ])
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
          )
        ]),
        "World": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "世界")
          ),
        ]),
        "Apple": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "苹果")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "needs_review", value: "蘋果")
          )
        ])
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
          )
        ]),
        "World": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "世界")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "needs_review", value: "你好")
          ),
        ]),
        "Apple": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "苹果")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "needs_review", value: "蘋果")
          )
        ])
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
          )
        ]),
        "World": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "世界")
          ),
          "zh-Hant": LocalizedString(
            stringUnit: StringUnit(state: "needs_review", value: "你好")
          ),
        ]),
        "Apple": Localizations(localizations: [
          "zh-Hans": LocalizedString(
            stringUnit: StringUnit(state: "translated", value: "苹果")
          ),
        ])
      ],
      version: "1.0"
    ))
  }
}
