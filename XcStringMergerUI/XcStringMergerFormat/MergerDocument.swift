// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class MergerDocument: ReferenceFileDocument {
  @Published var input: MergerInput

  static var readableContentTypes: [UTType] { [.mergerDocument] }

  init() {
    input = MergerInput()
  }

  required init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents
    else {
      throw CocoaError(.fileReadCorruptFile)
    }
    input = try JSONDecoder().decode(MergerInput.self, from: data)
  }

  func snapshot(contentType _: UTType) throws -> MergerInput {
    input
  }

  func fileWrapper(snapshot: MergerInput, configuration _: WriteConfiguration) throws -> FileWrapper {
    let data = try JSONEncoder().encode(snapshot)
    let fileWrapper = FileWrapper(regularFileWithContents: data)
    return fileWrapper
  }
}
