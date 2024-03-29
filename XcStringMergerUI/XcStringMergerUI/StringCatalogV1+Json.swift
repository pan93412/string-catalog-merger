// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import os
import XcStringMerger

private let logger = Logger()

extension StringCatalogV1 {
  var json: String? {
    do {
      return try serialize()
    } catch {
      logger.error("encoding catalog: \(error)")
      return ""
    }
  }
}
