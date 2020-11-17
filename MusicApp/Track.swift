//
//  Track.swift
//  MusicApp
//
//  Created by 417.72KI on 2020/11/18.
//

import Foundation
import class Cocoa.NSImage

public struct Track {
    public var persistentID: String
    public var title: String
    public var album: String
    public var artist: String
    public var fileURL: URL
    public var artwork: NSImage
}
