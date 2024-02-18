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

  @State var outputCatalog: OutputCatalog?
  @State var workingTask: Task<Void, Never>?
  @State var error: Error?

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
          .disabled(workingTask != nil)
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
        CodeEditor(content: .constant(outputCatalog?.outputCatalogJSON ?? ""))
          .frame(idealHeight: 200)
      } header: {
        HStack {
          Text("Output Catalog")
          Spacer()
          Text("Translated: \(outputCatalog.translatedPercentageString) %", comment: "the percentage of the translated strings")
        }
      }
    }
    .alert("Error", isPresented: .constant(error != nil)) {
      Button("OK") { error = nil }
    } message: {
      Text(error?.localizedDescription ?? String(localized: "Unknown error happened."))
    }
    .padding()
  }

  private func process() {
    workingTask = Task.detached {
      defer { Task { @MainActor in
        workingTask = nil
      } }

      do {
        let input = await MainActor.run {
          document.input
        }

        let currentCatalog = try decodeCatalog(of: input.currentCatalogRaw)
        let translatedCatalog = try decodeCatalog(of: input.translatedCatalogRaw)

        let merger = XcStringMerger(current: currentCatalog, translated: translatedCatalog)
        let merged = merger.mergeTranslation(of: input.languageCode, by: input.strategy)

        let translatedPercentage = merged.strings.map { _, localizations -> Double in
          guard let localization = localizations.localizations[input.languageCode] else {
            return 0.0
          }

          return localization.stringUnit.state == "translated" ? 1.0 : 0.0
        }.reduce(0, +) / Double(merged.strings.count)

        let outputCatalogJSON = try encodeCatalog(of: merged)

        await MainActor.run {
          outputCatalog = OutputCatalog(
            outputCatalogJSON: outputCatalogJSON,
            translatedPercentage: translatedPercentage
          )
        }
      } catch {
        await MainActor.run {
          self.error = error
        }
      }
    }
  }
}

private func decodeCatalog(of catalogString: String) throws -> StringCatalogV1 {
  let decoder = JSONDecoder()

  guard let catalogData = catalogString.data(using: .utf8) else {
    throw ContentError.encodeFailed
  }

  return try Result {
    try decoder.decode(StringCatalogV1.self, from: catalogData)
  }.mapError(ContentError.deserializeFailed).get()
}

private func encodeCatalog(of catalog: StringCatalogV1) throws -> String {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

  let catalogData = try Result {
    try encoder.encode(catalog)
  }.mapError(ContentError.serializeFailed).get()

  guard let result = String(data: catalogData, encoding: .utf8) else {
    throw ContentError.decodeFailed
  }

  return result
}

class OutputCatalog {
  var outputCatalogJSON: String
  var translatedPercentage: Double

  init(outputCatalogJSON: String, translatedPercentage: Double) {
    self.outputCatalogJSON = outputCatalogJSON
    self.translatedPercentage = translatedPercentage
  }

  var translatedPercentageString: String {
    String(format: "%.2f", translatedPercentage * 100)
  }
}

extension OutputCatalog? {
  var translatedPercentageString: String {
    self?.translatedPercentageString ?? "0.00"
  }
}

enum ContentError: Error, LocalizedError {
  case encodeFailed
  case decodeFailed
  case serializeFailed(Error)
  case deserializeFailed(Error)

  var errorDescription: String? {
    switch self {
    case .encodeFailed:
      return String(localized: "Encode failed")
    case .decodeFailed:
      return String(localized: "Decode failed")
    case let .serializeFailed(error):
      return String(localized: "Serialize to JSON failed: \(error.localizedDescription)")
    case let .deserializeFailed(error):
      return String(localized: "Deserialize from JSON failed: \(error.localizedDescription)")
    }
  }
}

#Preview {
  ContentView()
}
