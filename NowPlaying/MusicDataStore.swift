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
    var isExecuting: AnyPublisher<Bool, Never> { get }

    func playPause()
    func nextTrack()
    func previousTrack()

    func restoreArtwork()

    func restoreURL()
    func restoreURLForAlbum()

    func applySortFromCurrentTrack(forKeyPath keyPath: KeyPath<Track, String>)
    func guessSortInCurrentTrack(forKeyPath keyPath: KeyPath<Track, String>)

    func autoSortForCurrentTrack()
}

final class MusicDataStoreImpl {
    private let musicApp = MusicApp()
    private let executingSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables: Set<AnyCancellable> = []
}

extension MusicDataStoreImpl: MusicDataStore {
    var currentTrack: AnyPublisher<Track?, Never> {
        musicApp.currentTrack
    }

    var isPlaying: AnyPublisher<Bool, Never> {
        musicApp.isPlaying
    }

    var isExecuting: AnyPublisher<Bool, Never> {
        executingSubject.eraseToAnyPublisher()
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

    func restoreArtwork() {
        musicApp.restoreArtworkForCurrentTrack()
    }

    func restoreURL() {
        musicApp.restoreURLForCurrentTrack()
    }

    func restoreURLForAlbum() {
        Task { await musicApp.restoreURLForAlbumByCurrentTrack() }
    }

    func applySortFromCurrentTrack(forKeyPath keyPath: KeyPath<Track, String>) {
        Task {
            executingSubject.send(true)
            defer { executingSubject.send(false) }
            switch keyPath {
            case \.artist: await musicApp.applySortForArtistFromCurrentTrack()
            case \.album: await musicApp.applySortForAlbumFromCurrentTrack()
            case \.albumArtist: await musicApp.applySortForAlbumArtistFromCurrentTrack()
            case \.composer: await musicApp.applySortForComposerFromCurrentTrack()
            default: fatalError()
            }
        }
    }

    func guessSortInCurrentTrack(forKeyPath keyPath: KeyPath<Track, String>) {
    }

    func autoSortForCurrentTrack() {
        musicApp.autoSortForCurrentTrack()
    }
}
