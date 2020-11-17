//
//  MusicDataStore.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/17.
//

import Foundation
import MusicApp

protocol MusicDataStore {
    func getCurrentMusicData()
}

final class MusicDataStoreImpl {
    private let musicApp = MusicApp()
}

extension MusicDataStoreImpl: MusicDataStore {
    func getCurrentMusicData() {

    }
}
