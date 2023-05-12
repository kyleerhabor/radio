//
//  RadioApp.swift
//  Radio
//
//  Created by Kyle Erhabor on 5/8/23.
//

import DiscordRPC
import SwiftUI
import os

typealias Song = (name: String, artist: String, album: String, albumArtist: String, state: String)

@main
struct RadioApp: App {
  let logger = Logger()
  let nowPlayingAppleScript: NSAppleScript = {
    let source = """
      tell application "Doppler"
        set n to the name of the current track
        set a to the artist of the current track
        set aa to the album of the current track
        set aaa to the album artist of the current track
        set p to the player state as string
      end tell

      return {n, a, aa, aaa, p}
    """

    return NSAppleScript(source: source)!
  }()

  @AppStorage("clientId") private var clientId: String = defaultClientId
  @AppStorage("refreshRate") private var refreshRate: Double = 5
  @AppStorage("displayArtwork") private var displayArtwork = false
  @State private var rpc: DiscordRPC?

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          rpc = .init(clientID: clientId)

          rpc!.onConnect { _, _ in
            poll {
              updateActivity()
            }
          }

          rpc!.onError { _, _, error in
            logger.error("\(String(describing: error.data.code)): \(error.data.message)")
          }

          do {
            try rpc!.connect()
          } catch let err {
            logger.error("\(err)")
          }
        }
    }
  }

  func poll(_ call: @escaping () -> Void) {
    call()

    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(Int(refreshRate))) {
      poll(call)
    }
  }

  func activity() -> Activity {
    .init(
      details: nil,
      state: "Stopped",
      assets: .init(
        largeImage: "doppler",
        largeText: "Doppler",
        smallImage: nil,
        smallText: nil
      )
    )
  }

  func activityAssetImage(for song: Song) -> String {
    let image = "\(song.albumArtist) \(song.album)"
      .folding(options: .diacriticInsensitive, locale: .current)
      .replacingOccurrences(of: "[^\\w-]+", with: "_", options: .regularExpression)
      .lowercased()

    logger.debug("\(song.album) \(image)")

    return image
  }

  func activity(for song: Song) -> Activity {
    return .init(
      details: "\(song.artist) - \(song.name)",
      state: getState(state: song.state),
      assets: .init(
        largeImage: displayArtwork ? activityAssetImage(for: song) : "doppler",
        largeText: displayArtwork ? song.album : "Doppler",
        smallImage: displayArtwork ? "doppler" : nil,
        smallText: displayArtwork ? "Doppler" : nil
      )
    )
  }

  func updateActivity() {
    let song = getNowPlayingSong()
    let activity = song == nil ? activity() : activity(for: song!)

    updateActivity(activity)
  }

  func updateActivity(_ activity: Activity) {
    let request = RequestSetActivity(
      nonce: generateNonce(async: true),
      args: .init(activity: activity)
    )

    let encoder = JSONEncoder()

    do {
      let encoded = try encoder.encode(request)

      if let json = String(data: encoded, encoding: .utf8) {
        try rpc!.send(json, .frame)
      }
    } catch let err {
      logger.error("\(err)")
    }
  }

  func getNowPlayingSong() -> Song? {
    var error: NSDictionary?
    let descriptor = nowPlayingAppleScript.executeAndReturnError(&error)

    guard error == nil else {
      return nil
    }

    return (
      name: descriptor.atIndex(1)!.stringValue!,
      artist: descriptor.atIndex(2)!.stringValue!,
      album: descriptor.atIndex(3)!.stringValue!,
      albumArtist: descriptor.atIndex(4)!.stringValue!,
      state: descriptor.atIndex(5)!.stringValue!
    )
  }

  func getState(state: String) -> String? {
    switch state {
      case "playing": return "Listening"
      case "paused": return "Paused"
      case "stopped": return "Stopped"
      default: return nil
    }
  }
}
