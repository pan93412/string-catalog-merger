// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import XcStringMerger

extension XcStringMerger {
  static func merge(of input: MergerInput) throws -> StringCatalogV1 {
    let currentCatalog = try StringCatalogV1.deserialize(of: input.currentCatalogRaw)
    let translatedCatalog = try StringCatalogV1.deserialize(of: input.translatedCatalogRaw)

    return XcStringMerger(current: currentCatalog, translated: translatedCatalog)
      .mergeTranslation(of: input.languageCode, by: input.strategy)
  }
}
