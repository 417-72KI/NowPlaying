//
//  MusicApp.swift
//  MusicApp
//
//  Created by 417.72KI on 2020/11/18.
//

import Foundation
import ScriptingBridge
import Combine

public final class MusicApp {
    let app: MusicApplication

    private let currentTrackSubject: CurrentValueSubject<Track?, Never> = .init(nil)
    private let isPlayingSubject: CurrentValueSubject<Bool, Never> = .init(false)

    public init() {
        app = SBApplication(bundleIdentifier: "com.apple.Music")!
        DistributedNotificationCenter.default()
            .addObserver(self,
                         selector: #selector(playerInfoNotification(_:)),
                         name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"),
                         object: nil)

        fetchCurrentTrack()
    }

    deinit {
        DistributedNotificationCenter.default()
            .removeObserver(self)
    }
}

public extension MusicApp {
    var currentTrack: AnyPublisher<Track?, Never> {
        currentTrackSubject.eraseToAnyPublisher()
    }

    var isPlaying: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }
}

public extension MusicApp {
    func playPause() {
        app.playpause?()
    }

    func nextTrack() {
        app.nextTrack?()
    }

    func previousTrack() {
        app.previousTrack?()
    }
}

public extension MusicApp {
    func restoreArtwork(for track: Track) {
        guard let tracks = app.tracks?() else { return }
        guard let track = tracks.lazy
            .compactMap({ $0 as? MusicTrack })
            .first(where: { $0.persistentID == track.persistentID }) else { return }
        restoreArtwork(for: track)
    }

    func restoreArtworkForCurrentTrack() {
        guard app.isRunning,
              let currentTrack = app.currentTrack else { return }
        restoreArtwork(for: currentTrack)
    }
}

private extension MusicApp {
    func fetchCurrentTrack() {
        guard app.isRunning else { return }
        if let currentTrack = app.currentTrack.flatMap(Track.init) {
            currentTrackSubject.send(currentTrack)
        }
        if let playerState = app.playerState {
            switch playerState {
            case .playing, .fastForwarding, .rewinding:
                isPlayingSubject.send(true)
            case .paused, .stopped:
                isPlayingSubject.send(false)
            }
        }
    }

    func restoreArtwork(for track: MusicTrack) {
        guard let artworks = track.artworks?() else { return }
        print(artworks.count)
        artworks.lazy
            .compactMap { $0 as? MusicArtwork }
            .forEach { artwork in
                guard let data = artwork.data else { return }
                artwork.setData?(data)
            }
    }
}

public extension MusicApp {
    func applySortForArtistFromCurrentTrack() async {
        guard app.isRunning,
              let currentTrack = app.currentTrack else { return }
        await applySortForArtistFromTrack(currentTrack)
    }
    
    func applySortForAlbumArtistFromCurrentTrack() async {
        guard app.isRunning,
              let currentTrack = app.currentTrack else { return }
        await applySortForAlbumArtistFromTrack(currentTrack)
    }

    func applySortForAlbumFromCurrentTrack() async {
        guard app.isRunning,
              let currentTrack = app.currentTrack else { return }
        await applySortForAlbumFromTrack(currentTrack)
    }

    func applySortForComposerFromCurrentTrack() async {
        guard app.isRunning,
              let currentTrack = app.currentTrack else { return }
        await applySortForComposerFromTrack(currentTrack)
    }
}

extension MusicApp {
    func applySortForArtistFromTrack(_ track: MusicTrack) async {
        guard let persistentID = track.persistentID, !persistentID.isEmpty else { fatalError() }
        guard let artist = track.artist, !artist.isEmpty else {
            print("Artist is empty")
            return
        }
        guard let sortArtist = track.sortArtist, !sortArtist.isEmpty else {
            print("Sort for artist is empty")
            return
        }
        print(artist, sortArtist)
    }
    
    func applySortForAlbumArtistFromTrack(_ track: MusicTrack) async {
        guard let persistentID = track.persistentID, !persistentID.isEmpty else { fatalError() }
        guard let albumArtist = track.albumArtist, !albumArtist.isEmpty else {
            print("Album artist is empty")
            return
        }
        guard let sortAlbumArtist = track.sortAlbumArtist, !sortAlbumArtist.isEmpty else {
            print("Sort for albumArtist is empty")
            return
        }
        print(albumArtist, sortAlbumArtist)
    }

    func applySortForAlbumFromTrack(_ track: MusicTrack) async {
        guard let persistentID = track.persistentID, !persistentID.isEmpty else { fatalError() }
        guard let album = track.album, !album.isEmpty else {
            print("Album is empty")
            return
        }
        guard let sortAlbum = track.sortAlbum, !sortAlbum.isEmpty else {
            print("Sort for album is empty")
            return
        }
        print(album, sortAlbum)
    }

    func applySortForComposerFromTrack(_ track: MusicTrack) async {
        guard let persistentID = track.persistentID, !persistentID.isEmpty else {
            fatalError()
        }
        guard let composer = track.composer, !composer.isEmpty else {
            return print("Composer is empty")
        }
        guard let sortComposer = track.sortComposer, !sortComposer.isEmpty else {
            return print("Sort for composer is empty")
        }
        await Task.detached { [app] in
            guard let tracks = app.tracks?() else { return }
            let count = tracks.count
            tracks.enumerateObjects { t, i, _ in
                guard let musicTrack = t as? MusicTrack,
                      musicTrack.persistentID != persistentID else { return }
                print("\(i + 1)/\(count)", musicTrack.name ?? "")
                guard musicTrack.composer == composer,
                      musicTrack.sortComposer != sortComposer else {
                    return print("skip")
                }
                musicTrack.setSortComposer?(sortComposer)
            }
        }.value
    }
}

// MARK: - Notification
private extension MusicApp {
    @objc func playerInfoNotification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let persistentID = (userInfo["PersistentID"] as? Int)
                .flatMap({ String(format: "%08lX", UInt(bitPattern: $0)) }) else { return currentTrackSubject.send(nil) }
        print(persistentID)
        fetchCurrentTrack()
    }
}
