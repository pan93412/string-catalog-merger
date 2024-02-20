// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

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
        textEditor.isRichText = false
      }
      .font(.system(.body, design: .monospaced))
      .autocorrectionDisabled()
  }
}
