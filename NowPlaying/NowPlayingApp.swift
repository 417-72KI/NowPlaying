//
//  NowPlayingApp.swift
//  NowPlaying
//
//  Created by 417.72KI on 2024/06/23.
//

import SwiftUI
import MusicApp

@main
struct NowPlayingApp: App {
    @State private var currentTrack: Track?
    private let musicDataStore: MusicDataStore = MusicDataStoreImpl()

    var body: some Scene {
        MenuBarExtra {
            Text("foo")
        } label: {
            Group {
                if let artwork = currentTrack?.artwork.first?.resize(height: 18) {
                    Image(nsImage: artwork)
                } else {
                    Color.white
                        .frame(width: 18)
                }
            }
            .onReceive(musicDataStore.currentTrack) {
                currentTrack = $0
            }
        }
    }
}
