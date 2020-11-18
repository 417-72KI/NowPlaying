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

    @IBOutlet private weak var menu: NSMenu!

    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)

    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?

    private lazy var musicDataStore: MusicDataStore = MusicDataStoreImpl()

    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()

        statusItem.menu = menu
        musicDataStore.currentTrack
            .compactMap { $0 }
            .handleEvents(receiveOutput: { print($0.title ?? "") })
            .sink { [statusItem] in
                statusItem.button?.image = $0.artwork.first?
                    .resize(height: 20)
            }
            .store(in: &cancellables)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        tearDownNotifications()
    }
}

private extension AppDelegate {
    func setupNotifications() {
        let notificationCenter = NSWorkspace.shared.notificationCenter
        sleepObserver = notificationCenter.addObserver(forName: NSWorkspace.willSleepNotification,
                                                       object: nil,
                                                       queue: nil) { _ in }
        wakeObserver = notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification,
                                                      object: nil,
                                                      queue: nil) { _ in }
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
