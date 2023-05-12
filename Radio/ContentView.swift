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

  var body: some View {
    VStack {
      HStack {
        Text("Radio")
          .bold()

        Text("—")
          .foregroundColor(.secondary)

        Text("Broadcast your currently playing song in Doppler to Discord.")
          .font(.title)
      }.font(.largeTitle)

      VStack(alignment: .leading) {
        LabeledContent("Client ID") { // TODO: Add details about the relation to displaying artwork.
          TextField("Client ID", text: $clientId, prompt: Text(defaultClientId))
            .textFieldStyle(.plain)
            .onChange(of: clientId) { id in
              guard !id.isEmpty else {
                appClientId = defaultClientId

                return
              }

              appClientId = id
            }
        }

        HStack {
          Slider(value: $refreshRate, in: 1...10, step: 1) {
            Text("Refresh Rate")
          }

          Text("\(refreshRate, format: .number) seconds")
        }

        Toggle(isOn: $displayArtwork) {
          Text("Display Artwork")

          VStack(alignment: .leading, spacing: 8) {
            Text("You'll need to create your own Discord application and Rich Presence Assets for each artwork. The asset keys should be the album artist and album name separated by a space, which will be converted by Discord.")

            Text("e.g. ")
            + Text("Susumu Hirasawa error CD").fontDesign(.monospaced)
            + Text(" -> ").bold()
            + Text("susumu_hirasawa_error_cd").fontDesign(.monospaced)
          }
        }
      }
    }
    .padding()
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
