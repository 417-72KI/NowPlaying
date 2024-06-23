//
//  MenuView.swift
//  NowPlaying
//
//  Created by 417.72KI on 2024/06/23.
//

import SwiftUI
import MusicApp

struct MenuView<DataStore: MusicDataStore>: View {
    let dataStore: DataStore
    @Binding var currentTrack: Track?
    @State private var isPlaying = false
    @State private var autoRestoreArtwork = false
    @State private var autoSort = false

    var body: some View {
        VStack(spacing: 4) {
            GroupBox {
                VStack {
                    HStack {
                        if let currentTrack {
                            if let artwork = currentTrack.artwork.first {
                                Image(nsImage: artwork)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray)
                                    .frame(width: 100, height: 100)
                                    .overlay(alignment: .center) {
                                        Image(systemName: "music.note")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 25)
                                    }
                            }
                            VStack(alignment: .leading) {
                                Text(currentTrack.title)
                                    .font(.headline.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(currentTrack.artist)")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(currentTrack.album)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    GroupBox {
                        HStack {
                            Spacer()
                            Button {
                                dataStore.previousTrack()
                            } label: {
                                Image(systemName: "backward.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                            }
                            Button {
                                dataStore.playPause()
                            } label: {
                                if isPlaying {
                                    Image(systemName: "pause.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25)
                                } else {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25)
                                }
                            }
                            Button {
                                dataStore.nextTrack()
                            } label: {
                                Image(systemName: "forward.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25)
                            }
                            Spacer()
                        }
                        .buttonStyle(.accessoryBar)
                        .frame(height: 25)
                    }
                }
            }.padding(8)
            GroupBox {
                VStack {
                    Button("アートワークをコピー") {
                        guard let artwork = currentTrack?.artwork.first else { return }
                        artwork.copy(to: .general)
                    }
                    Button("アートワークを復旧[debug]") {
                        dataStore.restoreArtwork()
                    }
                    Toggle("アートワークを自動で復旧", isOn: $autoRestoreArtwork)
                        .toggleStyle(.switch)
                }
            }
            GroupBox {
                Button("URLを復旧[debug]") {
                    dataStore.restoreURL()
                }
                Button("アルバムのURLを復旧[debug]") {
                    dataStore.restoreURLForAlbum()
                }
            }
            GroupBox {
                Button("アーティスト(読み)を反映") {
                    dataStore.applySortFromCurrentTrack(forKeyPath: \.artist)
                }
                Button("アルバムアーティスト(読み)を反映") {
                    dataStore.applySortFromCurrentTrack(forKeyPath: \.albumArtist)
                }
                Button("アルバム(読み)を反映") {
                    dataStore.applySortFromCurrentTrack(forKeyPath: \.album)
                }
                Button("作曲者(読み)を反映") {
                    dataStore.applySortFromCurrentTrack(forKeyPath: \.composer)
                }
                Toggle("読みを自動反映", isOn: $autoSort)
                    .toggleStyle(.switch)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .onChange(of: currentTrack?.persistentID) {
            guard let _ = $1 else { return }
            if autoRestoreArtwork {
                dataStore.restoreArtwork()
            }
            if autoSort {
                dataStore.autoSortForCurrentTrack()
            }
        }
        .onChange(of: autoSort) {
            if $1 {
                dataStore.autoSortForCurrentTrack()
            }
        }
        .onReceive(dataStore.isPlaying) {
            isPlaying = $0
        }
    }
}

#Preview {
    MenuView(
        dataStore: StubMusicDataStore(),
        currentTrack: .constant(.mock)
    )
}
