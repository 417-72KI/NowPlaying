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
    private let musicDataStore = MusicDataStoreImpl()

    var body: some Scene {
        MenuBarExtra {
            MenuView(dataStore: musicDataStore,
                     currentTrack: $currentTrack)
        } label: {
            Group {
                if let artwork = currentTrack?.artwork.first?.resize(height: 18) {
                    Image(nsImage: artwork)
                        .environment(\.displayScale, 2.0)
                } else {
                    Color.white
                        .frame(width: 18)
                }
            }
            .onReceive(musicDataStore.currentTrack) {
                currentTrack = $0
            }
        }
        .menuBarExtraStyle(.window)
    }
}
