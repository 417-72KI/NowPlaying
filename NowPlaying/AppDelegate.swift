//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/17.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet private weak var menu: NSMenu!

    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)

    private var sleepObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()

        statusItem.menu = menu
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
