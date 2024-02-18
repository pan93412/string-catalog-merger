//
//  ContentView.swift
//  XcStringMergerUI
//
//  Created by Yi-Jyun Pan on 2024/2/18.
//

import SwiftUI
import SwiftUIIntrospect
import XcStringMerger

struct ContentView: View {
  @State var currentCatalogRaw: String = ""
  @State var translatedCatalogRaw: String = ""

  @State var strategy: XcStringMerger.Strategy = .merge
  @State var languageCode: LanguageCode = ""

  @State var outputCatalog: OutputCatalog? = nil
  @State var workingTask: Task<Void, Never>?
  @State var error: Error?

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Picker(selection: $strategy, label: Text("Strategy")) {
          ForEach([
            XcStringMerger.Strategy.merge,
            .mergeTranslated, .replace
          ], id: \.self) { strategy in
            Text(strategy.description)
          }
        }

        TextField("Language", text: $languageCode)

        Button("Process") {
          workingTask = Task.detached {
            defer { Task { @MainActor in
              workingTask = nil
            } }

            do {
              let currentCatalog = try decodeCatalog(of: currentCatalogRaw)
              let translatedCatalog = try decodeCatalog(of: translatedCatalogRaw)

              let merger = XcStringMerger(current: currentCatalog, translated: translatedCatalog)
              let merged = merger.mergeTranslation(of: languageCode, by: strategy)

              let translatedPercentage = merged.strings.map { _, localizations -> Double in
                guard let localization = localizations.localizations[languageCode] else {
                  return 0.0
                }

                return localization.stringUnit.state == "translated" ? 1.0 : 0.0
              }.reduce(0, +) / Double(merged.strings.count)

              let outputCatalogJSON = try encodeCatalog(of: merged)

              outputCatalog = OutputCatalog(
                outputCatalogJSON: outputCatalogJSON,
                translatedPercentage: translatedPercentage
              )
            } catch {
              self.error = error
            }
          }
        }
        .disabled(workingTask != nil)
      }

      HStack {
        VStack(alignment: .leading) {
          Section("Current (HEAD) catalog JSON") {
            CodeEditor(content: $currentCatalogRaw)
              .frame(idealHeight: 200)
          }
        }

        VStack(alignment: .leading) {
          Section("Translated catelog JSON") {
            CodeEditor(content: $translatedCatalogRaw)
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
          Text("Translated: \(outputCatalog.translatedPercentageString)")
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
}

class OutputCatalog {
  var outputCatalogJSON: String
  var translatedPercentage: Double

  init(outputCatalogJSON: String, translatedPercentage: Double) {
    self.outputCatalogJSON = outputCatalogJSON
    self.translatedPercentage = translatedPercentage
  }

  var translatedPercentageString: String {
    String(format: "%.2f %%", translatedPercentage * 100)
  }
}

extension OutputCatalog? {
  var translatedPercentageString: String {
    if let output = self {
      return output.translatedPercentageString
    }

    return "0.00 %"
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
    case .serializeFailed(let error):
      return String(localized: "Serialize to JSON failed: \(error.localizedDescription)")
    case .deserializeFailed(let error):
      return String(localized: "Deserialize from JSON failed: \(error.localizedDescription)")
    }
  }
}

#Preview {
  ContentView()
}
