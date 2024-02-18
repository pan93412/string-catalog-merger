//
//  XcStringMergerUIApp.swift
//  XcStringMergerUI
//
//  Created by Yi-Jyun Pan on 2024/2/18.
//

import SwiftUI

@main
struct XcStringMergerUIApp: App {
  var body: some Scene {
    DocumentGroup(newDocument: { MergerDocument() }) { configuration in
      ContentView()
    }
  }
}
