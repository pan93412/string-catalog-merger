// (c) 2024 and onwards The SCMerger Project (AGPL-3.0 License).
// ====================
// This code is released under the AGPL v3.0 license (SPDX-License-Identifier: AGPL-3.0)
// SCMerger is short for "String Catalog Merger", a project founded by Pan93412.

import SwiftUI
import XcStringMerger

@MainActor
struct ContentView: View {
  @EnvironmentObject var document: MergerDocument
  @State var result: Result<StringCatalogV1, Error>?

  @State private var task: Task<Void, Never>?

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
              .frame(minWidth: 300, minHeight: 200)
          }
        }

        VStack(alignment: .leading) {
          Section("Translated catelog JSON") {
            CodeEditor(content: $document.input.translatedCatalogRaw)
              .frame(minWidth: 300, minHeight: 200)
          }
        }
      }

      if let catalog = result?.successValue {
        Section {
          CodeEditor(content: .constant(catalog.json ?? ""))
            .frame(minWidth: 600, minHeight: 400)
        } header: {
          let percentage = catalog.getTranslatedPercentage(in: languageCode).percentage

          HStack {
            Text("Output Catalog")
            Spacer()
            Text("Translated: \(percentage) %", comment: "the percentage of the translated strings")
          }
        }
      }
    }
    .alert("Error", isPresented: .constant(result?.errorValue != nil)) {
      Button("OK") { result = nil }
    } message: {
      Text(result?.errorValue?.localizedDescription ?? String(localized: "Unknown error happened."))
    }
    .onReceive(document.$input) { _ in
      withAnimation {
        result = nil
      }
    }
    .padding()
  }

  private func process() {
    task?.cancel()
    task = Task.detached(priority: .userInitiated) { [input = document.input] in
      let result = await Result.async {
        try XcStringMerger.merge(of: input)
      }

      await MainActor.run {
        withAnimation {
          self.result = result
          task = nil
        }
      }
    }
  }
}

#Preview {
  ContentView().environmentObject(MergerDocument())
}
