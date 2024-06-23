//
//  MenuView.swift
//  NowPlaying
//
//  Created by 417.72KI on 2024/06/23.
//

import SwiftUI
import MusicApp

struct MenuView: View {
    @Binding var currentTrack: Track?

    var body: some View {
        if let currentTrack {
            if let artwork = currentTrack.artwork.first?.resize(height: 100) {
                Image(nsImage: artwork)
                    .resizable()
                    .frame(height: 100)
            }
            Text(currentTrack.title)
            Text(currentTrack.artist)
            Text(currentTrack.album)
        }
    }
}

#Preview {
    MenuView(currentTrack: .constant(nil))
}
