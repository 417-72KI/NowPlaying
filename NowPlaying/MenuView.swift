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
    @State private var autoDivideDisc = false
    @State private var isMenuOpened = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            GroupBox {
                VStack(spacing: 4) {
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
                                    .frame(width: 25)
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
            }
            .padding(8)
            Button {
                isMenuOpened.toggle()
            } label: {
                GroupBox {
                    ZStack {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.primary)
                    }
                    .frame(width: 15, height: 15)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
            .popover(isPresented: $isMenuOpened) {
                popoverMenuView()
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
            if autoDivideDisc {
                dataStore.divideFolderWithMultipleDiscs()
            }
        }
        .onChange(of: autoSort) {
            if $1 { dataStore.autoSortForCurrentTrack() }
        }
        .onChange(of: autoDivideDisc) {
            if $1 { dataStore.divideFolderWithMultipleDiscs() }
        }
        .onReceive(dataStore.isPlaying) {
            isPlaying = $0
        }
    }
}

private extension MenuView {
    @ViewBuilder
    func popoverMenuView() -> some View {
        GroupBox {
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
                .frame(maxWidth: .infinity)
            }
            GroupBox {
                VStack {
                    Button("URLを復旧[debug]") {
                        dataStore.restoreURL()
                    }
                    Button("アルバムのURLを復旧[debug]") {
                        dataStore.restoreURLForAlbum()
                    }
                    Button("アルバムのディスクごとにフォルダを分割") {
                        dataStore.divideFolderWithMultipleDiscs()
                    }
                    Toggle("自動でディスク分割", isOn: $autoDivideDisc)
                        .toggleStyle(.switch)
                }
                .frame(maxWidth: .infinity)
            }
            GroupBox {
                VStack {
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
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    MenuView(
        dataStore: StubMusicDataStore(),
        currentTrack: .constant(.mock)
    )
}
