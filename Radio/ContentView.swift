//
//  ContentView.swift
//  Radio
//
//  Created by Kyle Erhabor on 5/8/23.
//

import SwiftUI

let defaultClientId = "1105292931801301004"

struct ContentView: View {
  @AppStorage("clientId") private var appClientId: String = defaultClientId
  @AppStorage("refreshRate") private var refreshRate: Double = 5
  @AppStorage("displayArtwork") private var displayArtwork = false

  @State private var clientId: String = ""
  @State private var displayArtworkInfo = false

  let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = .second
    formatter.unitsStyle = .full

    return formatter
  }()

  var body: some View {
    Form {
      LabeledContent("Client ID") {
        TextField("Client ID", text: $clientId, prompt: Text(defaultClientId))
          .labelsHidden()
          .fontDesign(.monospaced)
      }.onChange(of: clientId) { id in
        guard !id.isEmpty else {
          appClientId = defaultClientId

          return
        }

        appClientId = id
      }

      LabeledContent("Refresh Rate") {
        Slider(value: $refreshRate, in: 1...10, step: 1) {
          Text(formatter.string(from: refreshRate) ?? "")
        }
      }

      LabeledContent("Display Artwork") {
        Toggle("Display Artwork", isOn: $displayArtwork)
          .labelsHidden()
          .toggleStyle(.switch)

        Button {
          displayArtworkInfo.toggle()
        } label: {
          Image(systemName: "questionmark")
        }
        .clipShape(Circle())
        .popover(isPresented: $displayArtworkInfo, arrowEdge: .trailing) {
          VStack {
            Text("To use this feature, please read the guide here:")

            let url = "https://github.com/KyleErhabor/Radio#artwork"

            Link(url, destination: .init(string: url)!)
              .focusable(false)
          }.padding()
        }
      }

      Section {
        // Empty
      } footer: {
        Link("Homepage", destination: .init(string: "https://github.com/KyleErhabor/Radio")!)
      }
    }
    .formStyle(.grouped)
    .frame(minWidth: 384, minHeight: 256)
    .onAppear {
      clientId = appClientId
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
