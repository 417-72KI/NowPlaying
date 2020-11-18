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
}

private extension MusicApp {
    func fetchCurrentTrack() {
        guard app.isRunning else { return }
        if let currentTrack = app.currentTrack.flatMap(Track.init) {
            currentTrackSubject.send(currentTrack)
        }
    }
}

// MARK: - Notification
private extension MusicApp {
    @objc func playerInfoNotification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let persistentID = (userInfo["PersistentID"] as? Int)
                .flatMap({ String(format: "%08lX", UInt(bitPattern: $0)) }) else { return }
        print(persistentID)
        fetchCurrentTrack()
    }
}
