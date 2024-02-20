//
//  Result+Async.swift
//  XcStringMergerUI
//
//  Created by Yi-Jyun Pan on 2024/2/20.
//

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
