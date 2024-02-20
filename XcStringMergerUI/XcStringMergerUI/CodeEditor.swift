// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import SwiftUI

@MainActor
struct CodeEditor: NSViewRepresentable {
  private let textViewDelegation: NSTextViewDelegate
  @Binding public var content: String

  public init(content: Binding<String>) {
    _content = content
    textViewDelegation = CodeEditorDelegation(_content)
  }

  public let scrollView = NSTextView.scrollableTextView()

  public func makeNSView(context _: Context) -> NSScrollView {
    guard let textView = scrollView.documentView as? NSTextView else {
      return scrollView
    }

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

    textView.delegate = textViewDelegation

    return scrollView
  }

  public func updateNSView(_ scrollView: NSScrollView, context _: Context) {
    guard let textView = scrollView.documentView as? NSTextView else {
      return
    }

    textView.string = content
  }
}

private final class CodeEditorDelegation: NSObject, NSTextViewDelegate {
  @Binding var content: String

  public init(_ content: Binding<String>) {
    _content = content
  }

  public func textDidChange(_ notification: Notification) {
    content = (notification.object as! NSTextView).string
  }
}
