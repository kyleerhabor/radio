//
//  ContentView.swift
//  Radio
//
//  Created by Kyle Erhabor on 5/8/23.
//

import SwiftUI

class HelpButton: NSButton {
  typealias Action = () -> Void

  var call: Action

  init(action: @escaping Action) {
    self.call = action

    super.init(frame: .zero)

    self.bezelStyle = .helpButton
    self.title = ""
    self.target = self
    self.action = #selector(click(_:))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func click(_ sender: HelpButton) {
    call()
  }
}

struct HelpButtonView: NSViewRepresentable {
  var action: HelpButton.Action

  func makeNSView(context: Context) -> HelpButton {
    HelpButton(action: action)
  }

  func updateNSView(_ nsView: HelpButton, context: Context) {}
}

struct ContentView: View {
  @Environment(\.openURL) private var openUrl

  @AppStorage("clientId") private var appClientId = defaultClientId
  @AppStorage("refreshRate") private var refreshRate = Double(defaultRefreshRate)
  @AppStorage("displayArtwork") private var displayArtwork = defaultDisplayingArtwork

  @State private var clientId: String = ""
  @State private var displayArtworkInfo = false

  let formatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = .second
    formatter.unitsStyle = .full

    return formatter
  }()

  let homepage = URL(string: "https://github.com/KyleErhabor/Radio")!

  var body: some View {
    Form {
      Section {
        LabeledContent("Client ID") {
          TextField("Client ID", text: $clientId, prompt: Text(defaultClientId))
            .labelsHidden()
            .fontDesign(.monospaced)
            .help("The ID of the Discord application to use when establishing a connection with Discord. This needs to be changed when displaying artwork.")
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

          HelpButtonView {
            var components = URLComponents(url: homepage, resolvingAgainstBaseURL: false)!
            components.fragment = "artwork"

            openUrl(components.url!)
          }.help("Opens the guide for properly enabling artwork displays in the browser.")
        }
      } footer: {
        Link("Homepage", destination: homepage)
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
