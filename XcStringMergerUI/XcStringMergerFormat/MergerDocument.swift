//
//  MergerDocument.swift
//  XcStringMergerUI
//
//  Created by Yi-Jyun Pan on 2024/2/18.
//

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
    self.input = try JSONDecoder().decode(MergerInput.self, from: data)
  }
  
  func snapshot(contentType: UTType) throws -> MergerInput {
    input
  }

  func fileWrapper(snapshot: MergerInput, configuration: WriteConfiguration) throws -> FileWrapper {
    let data = try JSONEncoder().encode(snapshot)
    let fileWrapper = FileWrapper(regularFileWithContents: data)
    return fileWrapper
  }
}
