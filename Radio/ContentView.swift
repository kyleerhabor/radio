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

  let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = .second
    formatter.unitsStyle = .full

    return formatter
  }()

  var body: some View {
    Form {
      HStack {
        Spacer()

        Text("Radio")
          .bold()

        Text("—")
          .foregroundColor(.secondary)

        Text("Broadcast your currently playing song in Doppler to Discord.")
          .font(.title)

        Spacer()
      }.font(.largeTitle)

      // TODO: Add details about the relation to displaying artwork.
      // TODO: Figure out how to monospace the value but not the label.
      TextField("Client ID", text: $clientId, prompt: Text(defaultClientId))
        .onChange(of: clientId) { id in
          guard !id.isEmpty else {
            appClientId = defaultClientId

            return
          }

          appClientId = id
        }

      HStack {
        Slider(value: $refreshRate, in: 1...10, step: 1) {
          Text("Refresh Rate")
        }

        if let s = formatter.string(from: refreshRate) {
          Text(s)
        }
      }

      Toggle(isOn: $displayArtwork) {
        Text("Display Artwork")

        Text("You'll need to create your own Discord application and Rich Presence Assets for each artwork. The asset keys should be the album artist and album name separated by a space, which will be converted by Discord.")

        Text("e.g. ")
        + Text("Susumu Hirasawa error CD").fontDesign(.monospaced)
        + Text(" -> ").bold()
        + Text("susumu_hirasawa_error_cd").fontDesign(.monospaced)
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
