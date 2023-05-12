//
//  RadioApp.swift
//  Radio
//
//  Created by Kyle Erhabor on 5/8/23.
//

import SwiftUI
import DiscordRPC

@main
struct RadioApp: App {
  let rpc = DiscordRPC(clientID: "1105292931801301004")
  let nowPlayingAppleScript: NSAppleScript = {
    let source = """
      tell application "Doppler"
        set n to the name of the current track
        set a to the artist of the current track
        set p to the player state as string
      end tell

      return {n, a, p}
    """

    return NSAppleScript(source: source)!
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          rpc.onConnect { _, _ in
            poll {
              let song = getNowPlayingSong()
              let request = RequestSetActivity(
                nonce: generateNonce(async: true),
                args: .init(
                  activity: .init(
                    details: song == nil ? nil : "\(song!.artist) - \(song!.name)",
                    state: song == nil ? "Stopped" : getState(state: song!.state),
                    assets: .init(
                      largeImage: "doppler",
                      largeText: "Doppler"
                    )
                  )
                )
              )

              let encoder = JSONEncoder()

              do {
                let encoded = try encoder.encode(request)

                if let json = String(data: encoded, encoding: .utf8) {
                  try rpc.send(json, .frame)
                }
              } catch let err as NSError {
                print(err)
              }
            }
          }

          do {
            try rpc.connect()
          } catch let err {
            print(err)
          }
        }
    }
  }

  func poll(_ call: @escaping () -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
      call()
      poll(call)
    }
  }

  func getNowPlayingSong() -> (name: String, artist: String, state: String)? {
    var error: NSDictionary?
    let descriptor = nowPlayingAppleScript.executeAndReturnError(&error)

    guard error == nil else {
      return nil
    }

    return (
      name: descriptor.atIndex(1)!.stringValue!,
      artist: descriptor.atIndex(2)!.stringValue!,
      state: descriptor.atIndex(3)!.stringValue!
    )
  }

  func getState(state: String) -> String? {
    switch state {
      case "playing": return "Listening"
      case "paused": return "Paused"
      default: return nil
    }
  }
}
