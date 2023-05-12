//
//  ContentView.swift
//  Radio
//
//  Created by Kyle Erhabor on 5/8/23.
//

import SwiftUI

struct ContentView: View {
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
    }.padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
