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


    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)

    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?

    private lazy var musicDataStore: MusicDataStore = MusicDataStoreImpl()

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()

        statusItem.menu = menu
        bind()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        tearDownNotifications()
    }
}

private extension AppDelegate {
    func bind() {
        let currentTrack = musicDataStore.currentTrack
            .wrapped

        currentTrack.map(\.artwork)
            .map { $0.first?.resize(height: 100) }
            .handleEvents(receiveOutput: { [statusItem] in statusItem.button?.image = $0?.resize(height: 18) })
            .assign(to: \.image, on: artworkMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.title)
            .assign(to: \.title, on: titleMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.artist)
            .assign(to: \.title, on: artistMenuItem)
            .store(in: &cancellables)

        currentTrack.map(\.album)
            .assign(to: \.title, on: albumMenuItem)
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

// MARK: -
private extension AppDelegate {
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

    @IBAction func previousTrack(_ sender: NSMenuItem) {
        
    }

    @IBAction func nextTrack(_ sender: NSMenuItem) {

    }

    @IBAction func quit(_ sender: NSMenuItem) {
        exit(0)
    }
}
