// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import SwiftUI
import SwiftUIIntrospect
import XcStringMerger

@MainActor
struct ContentView: View {
  @EnvironmentObject var document: MergerDocument
  @State var result: Result<OutputCatalog, Error>?

  @State private var task: Task<(), Error>?

  private var languageCode: LanguageCode { document.input.languageCode }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Picker(selection: $document.input.strategy, label: Text("Strategy")) {
          ForEach([
            XcStringMerger.Strategy.merge,
            .mergeTranslated, .replace,
          ], id: \.self) { strategy in
            Text(strategy.description)
          }
        }

        TextField("Language", text: $document.input.languageCode)

        Button("Process", action: { process() })
          .disabled(task != nil)
      }

      HStack {
        VStack(alignment: .leading) {
          Section("Current (HEAD) catalog JSON") {
            CodeEditor(content: $document.input.currentCatalogRaw)
              .frame(idealHeight: 200)
          }
        }

        VStack(alignment: .leading) {
          Section("Translated catelog JSON") {
            CodeEditor(content: $document.input.translatedCatalogRaw)
              .frame(idealHeight: 200)
          }
        }
      }

      Section {
        CodeEditor(content: .constant(result?.successValue?.json ?? ""))
          .frame(idealHeight: 200)
      } header: {
        let percentage = result?.successValue?.getTranslatedPercentageOf(languageCode: languageCode).percentageString ?? "0.00"

        HStack {
          Text("Output Catalog")
          Spacer()
          Text("Translated: \(percentage) %", comment: "the percentage of the translated strings")
        }
      }
    }
    .alert("Error", isPresented: .constant(result?.errorValue != nil)) {
      Button("OK") { result = nil }
    } message: {
      Text(result?.errorValue?.localizedDescription ?? String(localized: "Unknown error happened."))
    }
    .padding()
  }

  @MainActor
  private func process() {
    task?.cancel()
    task = Task(priority: .userInitiated) { [input = document.input] in
      defer {
        self.task = nil
      }

      let result = await Result.async {
        try await mergeDecodableCatalog(input)
      }

      self.result = result
    }
  }
}

#Preview {
  ContentView()
}
