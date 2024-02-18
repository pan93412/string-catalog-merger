//
//  CodeEditor.swift
//  XcStringMergerUI
//
//  Created by Yi-Jyun Pan on 2024/2/18.
//

import SwiftUI
import SwiftUIIntrospect

struct CodeEditor: View {
  @Binding var content: String

  var body: some View {
    TextEditor(text: $content)
      .introspect(.textEditor, on: .macOS(.v11, .v12, .v13, .v14)) { textEditor in
        textEditor.isAutomaticQuoteSubstitutionEnabled = false
        textEditor.isGrammarCheckingEnabled = false
        textEditor.isAutomaticDashSubstitutionEnabled = false
        textEditor.isAutomaticSpellingCorrectionEnabled = false
        textEditor.isAutomaticLinkDetectionEnabled = false
        textEditor.isAutomaticTextReplacementEnabled = false
        textEditor.isAutomaticTextCompletionEnabled = false
      }
      .fontDesign(.monospaced)
      .autocorrectionDisabled()
  }
}
