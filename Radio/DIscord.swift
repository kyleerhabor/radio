//
//  DIscord.swift
//  Radio
//
//  Created by Kyle Erhabor on 5/9/23.
//

import Darwin
import DiscordRPC
import Foundation

struct RequestSetActivity: Encodable {
  let cmd: CommandType = .setActivity
  let nonce: String
  let args: RequestSetActivityArgs
}

struct RequestSetActivityArgs: Encodable {
  let pid = getpid()
  let activity: Activity
}

struct Activity: Encodable {
  let details: String?
  let state: String?
  let assets: ActivityAssets?
}

struct ActivityAssets: Encodable {
  let largeImage: String?
  let largeText: String?
  let smallImage: String?
  let smallText: String?

  enum CodingKeys: String, CodingKey {
    case largeImage = "large_image"
    case largeText = "large_text"
    case smallImage = "small_image"
    case smallText = "small_text"
  }
}
