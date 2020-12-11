//
//  MusicDataStore.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/17.
//

import Foundation
import MusicApp
import Combine

protocol MusicDataStore {
    var currentTrack: AnyPublisher<Track?, Never> { get }
    var isPlaying: AnyPublisher<Bool, Never> { get }

    func playPause()
    func nextTrack()
    func previousTrack()
}

final class MusicDataStoreImpl {
    private let musicApp = MusicApp()
}

extension MusicDataStoreImpl: MusicDataStore {
    var currentTrack: AnyPublisher<Track?, Never> {
        musicApp.currentTrack
    }

    var isPlaying: AnyPublisher<Bool, Never> {
        musicApp.isPlaying
    }

    func playPause() {
        musicApp.playPause()
    }

    func nextTrack() {
        musicApp.nextTrack()
    }

    func previousTrack() {
        musicApp.previousTrack()
    }
}
