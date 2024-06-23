//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/17.
//

import Cocoa
import SwiftUI
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: outlet
    @IBOutlet private weak var menu: NSMenu!
    @IBOutlet private weak var artworkMenuItem: NSMenuItem!
    @IBOutlet private weak var titleMenuItem: NSMenuItem!
    @IBOutlet private weak var artistMenuItem: NSMenuItem!
    @IBOutlet private weak var albumMenuItem: NSMenuItem!

    @IBOutlet private weak var playPauseItem: NSMenuItem!

    @IBOutlet private weak var restoreArtworkMenuItem: NSMenuItem!
    @IBOutlet private weak var autoRestoreArtworkMenuItem: NSMenuItem!

    @IBOutlet private weak var autoSortMenuItem: NSMenuItem!

    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)

    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?

    private lazy var musicDataStore: MusicDataStore = MusicDataStoreImpl()

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()

        statusItem.menu = menu

        #if !DEBUG
        restoreArtworkMenuItem.isHidden = true
        autoRestoreArtworkMenuItem.isHidden = true
        autoSortMenuItem.isHidden = true
        #endif

        bind()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        tearDownNotifications()
    }
}

private extension AppDelegate {
    func bind() {
        musicDataStore.isPlaying.map { $0 ? "一時停止": "再生" }
            .assign(to: \.title, on: playPauseItem)
            .store(in: &cancellables)

        let currentTrack = musicDataStore.currentTrack

        currentTrack.map(\.artwork)
            .map { $0?.first?.resize(height: 100) }
            .handleEvents(receiveOutput: { [statusItem] in statusItem.button?.image = $0?.resize(height: 18) })
            .assign(to: \.image, on: artworkMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.title, default: "")
            .assign(to: \.title, on: titleMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.artist, default: "")
            .assign(to: \.title, on: artistMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.album, default: "")
            .assign(to: \.title, on: albumMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.persistentID, default: "")
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self else { return }
                if case .on = autoRestoreArtworkMenuItem.state {
                    musicDataStore.restoreArtwork()
                }
                if case .on = autoSortMenuItem.state {
                    musicDataStore.autoSortForCurrentTrack()
                }
            }
            .store(in: &cancellables)

        currentTrack.map(\.?.fileURL)
            .sink { print($0 as Any) }
            .store(in: &cancellables)
    }
}

private extension AppDelegate {
    func setupNotifications() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        sleepObserver = notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification,
                                                       object: nil,
                                                       queue: nil) { _ in print("willSleep") }
        wakeObserver = notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification,
                                                      object: nil,
                                                      queue: nil) { _ in print("didWake") }
    }

    func tearDownNotifications() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        if let sleepObserver = sleepObserver {
            notificationCenter.removeObserver(sleepObserver)
        }
        if let wakeObserver = wakeObserver {
            notificationCenter.removeObserver(wakeObserver)
        }
    }
}

// MARK: - actions
private extension AppDelegate {
    // MARK: Artworks
    @IBAction func copyArtwork(_ sender: NSMenuItem) {
        musicDataStore.currentTrack.prefix(1)
            .asFuture()
            .sink {
                guard let track = $0,
                      let artwork = track.artwork.first else { return }
                artwork.copy(to: .general)
            }
            .store(in: &cancellables)
    }

    @IBAction func restoreArtwork(_ sender: NSMenuItem) {
        musicDataStore.restoreArtwork()
    }

    @IBAction func toggleAutoRestoreArtwork(_ sender: NSMenuItem) {
        autoRestoreArtworkMenuItem.state = switch autoRestoreArtworkMenuItem.state {
        case .off: .on
        default: .off
        }
    }

    @IBAction func restoreURL(_ sender: NSMenuItem) {
        musicDataStore.restoreURL()
    }

    @IBAction func restoreURLForAlbum(_ sender: NSMenuItem) {
        musicDataStore.restoreURLForAlbum()
    }

    // MARK: Sort
    @IBAction func artistSort(_ sender: NSMenuItem) {
        musicDataStore.applySortFromCurrentTrack(forKeyPath: \.artist)
    }

    @IBAction func albumArtistSort(_ sender: NSMenuItem) {
        musicDataStore.applySortFromCurrentTrack(forKeyPath: \.albumArtist)
    }

    @IBAction func albumSort(_ sender: NSMenuItem) {
        musicDataStore.applySortFromCurrentTrack(forKeyPath: \.album)
    }

    @IBAction func composerSort(_ sender: NSMenuItem) {
        musicDataStore.applySortFromCurrentTrack(forKeyPath: \.composer)
    }

    @IBAction func toggleAutoSortMenu(_ sender: NSMenuItem) {
        autoSortMenuItem.state = switch autoSortMenuItem.state {
        case .off: .on
        default: .off
        }
        if case .on = autoSortMenuItem.state {
            musicDataStore.autoSortForCurrentTrack()
        }
    }

    // MARK: Player
    @IBAction func playPause(_ sender: NSMenuItem) {
        musicDataStore.playPause()
    }

    @IBAction func previousTrack(_ sender: NSMenuItem) {
        musicDataStore.previousTrack()
    }

    @IBAction func nextTrack(_ sender: NSMenuItem) {
        musicDataStore.nextTrack()
    }

    @IBAction func quit(_ sender: NSMenuItem) {
        exit(0)
    }
}
