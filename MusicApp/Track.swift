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
    public var title: String?
    public var artist: String?
    public var album: String?
    public var albumArtist: String?
    public var composer: String?
    public var fileURL: URL?
    public var artwork: [NSImage]
    public var bitRate: Int
}

extension Track {
    init?(track: MusicTrack) {
        guard let persistentID = track.persistentID else { return nil }
        self.persistentID = persistentID
        self.title = track.name
        self.artist = track.artist
        self.album = track.album
        self.albumArtist = track.albumArtist
        self.composer = track.composer
        if let keys = track.properties?.keys, keys.contains(where: { ($0 as? String) == "location" }) {
            self.fileURL = (track as? MusicFileTrack)?.location
        }
        self.artwork = track.artworks?().compactMap { $0 as? MusicArtwork }
            .compactMap(\.data) ?? []
        self.bitRate = track.bitRate ?? 0
    }
}
