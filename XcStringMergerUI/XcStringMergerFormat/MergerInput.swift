// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation
import XcStringMerger

struct MergerInput: Identifiable, Codable, Sendable {
  var id = UUID()

  var currentCatalogRaw: String = ""
  var translatedCatalogRaw: String = ""

  var strategy: XcStringMerger.Strategy = .merge
  var languageCode: LanguageCode = ""
}
