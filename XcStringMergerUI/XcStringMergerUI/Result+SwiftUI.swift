// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation

extension Result {
  var successValue: Success? {
    if case let .success(success) = self {
      return success
    }

    return nil
  }

  var errorValue: Failure? {
    if case let .failure(failure) = self {
      return failure
    }

    return nil
  }
}
