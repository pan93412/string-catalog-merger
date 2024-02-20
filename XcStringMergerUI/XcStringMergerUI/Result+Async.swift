// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation

extension Result where Failure == Error {
  static func async(_ catching: @Sendable () async throws -> Success) async -> Self {
    do {
      return Result.success(try await catching())
    } catch {
      return Result.failure(error)
    }
  }
}
