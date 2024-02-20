// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import SwiftUI

@MainActor
struct CodeEditor: NSViewRepresentable {
  @Binding var content: String

  public let scrollView = NSTextView.scrollableTextView()

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeNSView(context: Context) -> NSScrollView {
    guard let textView = scrollView.textView else { return scrollView }

    textView.font = .monospacedSystemFont(ofSize: 0, weight: .regular)

    // disable all checks for richText
    textView.isAutomaticQuoteSubstitutionEnabled = false
    textView.isGrammarCheckingEnabled = false
    textView.isAutomaticDashSubstitutionEnabled = false
    textView.isAutomaticSpellingCorrectionEnabled = false
    textView.isAutomaticLinkDetectionEnabled = false
    textView.isAutomaticTextReplacementEnabled = false
    textView.isAutomaticTextCompletionEnabled = false
    textView.isContinuousSpellCheckingEnabled = false
    textView.isRichText = false

    textView.delegate = context.coordinator

    return scrollView
  }

  func updateNSView(_ view: NSScrollView, context _: Context) {
    guard let textView = view.textView else { return }

    if textView.string != content {
      textView.string = content
    }
  }

  final class Coordinator: NSObject, NSTextViewDelegate {
    let parent: CodeEditor

    init(_ parent: CodeEditor) {
      self.parent = parent
    }

    func textDidChange(_ notification: Notification) {
      guard let textView = notification.object as? NSTextView else { return }
      parent.content = textView.string
    }
  }
}

private extension NSScrollView {
  var textView: NSTextView? {
    documentView as? NSTextView
  }
}
