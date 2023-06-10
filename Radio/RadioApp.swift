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

let defaultClientId = "1105292931801301004"
let defaultRefreshRate = 5
let defaultDisplayingArtwork = false

@main
struct RadioApp: App {
  static let logger = Logger()
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

  @AppStorage("clientId") private var clientId = defaultClientId
  @AppStorage("refreshRate") private var refreshRate = Double(defaultRefreshRate)
  @AppStorage("displayArtwork") private var displayArtwork = defaultDisplayingArtwork
  @State private var rpc: DiscordRPC?

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onAppear {
          rpc = .init(clientID: clientId)

          rpc!.onConnect { rpc, _ in
            Self.logger.info("Connected!")

            poll(every: .seconds(Int(refreshRate))) {
              // If the socket is not connected (likely was disconnected by the user closing Discord), try reconnecting
              // until connected. When connected, this poll will stop, since onConnect will be called again.
              guard rpc.socket?.isConnected == true else {
                return !connect(rpc: rpc)
              }

              updateActivity(rpc: rpc)

              return true
            }
          }

          rpc!.onError { _, _, error in
            Self.logger.error("Error! \(String(describing: error.data.code)): \(error.data.message)")
          }

          rpc!.onDisconnect { _, _ in
            Self.logger.warning("Disconnected!")
          }

          poll(every: .seconds(5)) {
            !connect(rpc: rpc!)
          }
        }
    }
  }

  func connect(rpc: DiscordRPC) -> Bool {
    do {
      try rpc.connect()

      return true
    } catch {
      Self.logger.warning("Could not connect to Discord: \(error)")

      return false
    }
  }

  func poll(every delay: DispatchTimeInterval, action: @escaping () -> Bool) {
    if action() {
      DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
        poll(every: delay, action: action)
      }
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

    Self.logger.debug("\(song.album) \(image)")

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

  func updateActivity(rpc: DiscordRPC) {
    let song = getNowPlayingSong()
    let activity = song == nil ? activity() : activity(for: song!)

    updateActivity(rpc: rpc, activity: activity)
  }

  func updateActivity(rpc: DiscordRPC, activity: Activity) {
    let request = RequestSetActivity(
      nonce: generateNonce(async: true),
      args: .init(activity: activity)
    )

    let encoder = JSONEncoder()

    do {
      let encoded = try encoder.encode(request)

      if let json = String(data: encoded, encoding: .utf8) {
        try rpc.send(json, .frame)
      }
    } catch let err {
      Self.logger.error("\(err)")
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
