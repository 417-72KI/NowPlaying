//
//  MusicApp.swift
//  MusicApp
//
//  Created by 417.72KI on 2020/11/18.
//

import Foundation
import ScriptingBridge

public final class MusicApp {
    let app: MusicApplication

    public init() {
        app = SBApplication(bundleIdentifier: "com.apple.Music")!
        app.activate()
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

private extension MusicApp {
    func fetchCurrentTrack() {
        if let currentTrack = app.currentTrack.flatMap(Track.init) {
            print(currentTrack)
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
