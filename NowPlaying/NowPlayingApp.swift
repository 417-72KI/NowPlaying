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
    @State private var isPlaying = false
    @State private var autoRestoreArtwork = false
    @AppStorage("autoSort") private var autoSort = false
    @State private var autoDivideDisc = false

    private let musicDataStore = MusicDataStoreImpl()

    var body: some Scene {
        MenuBarExtra {
            MenuView(
                dataStore: musicDataStore,
                currentTrack: $currentTrack,
                isPlaying: $isPlaying,
                autoRestoreArtwork: $autoRestoreArtwork,
                autoSort: $autoSort,
                autoDivideDisc: $autoDivideDisc
            )
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
                if let currentTrack {
                    print(currentTrack.title)
                    if autoRestoreArtwork {
                        musicDataStore.restoreArtwork()
                    }
                    if autoSort {
                        musicDataStore.autoSortForCurrentTrack()
                    }
                    if autoDivideDisc {
                        musicDataStore.divideFolderWithMultipleDiscs()
                    }
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
