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
    public var artist: String
    public var album: String
    public var albumArtist: String
    public var composer: String
    public var fileURL: URL?
    public var artwork: [NSImage]
    public var bitRate: Int
}

extension Track {
    init?(track: MusicTrack) {
        guard let persistentID = track.persistentID else { return nil }
        self.persistentID = persistentID
        self.title = track.name ?? ""
        self.artist = track.artist ?? ""
        self.album = track.album ?? ""
        self.albumArtist = track.albumArtist ?? ""
        self.composer = track.composer ?? ""
        if let keys = track.properties?.keys, keys.contains(where: { ($0 as? String) == "location" }) {
            self.fileURL = (track as? MusicFileTrack)?.location
        }
        self.artwork = track.artworks?().compactMap { $0 as? MusicArtwork }
            .compactMap(\.image) ?? []
        self.bitRate = track.bitRate ?? 0
    }
}

private extension MusicArtwork {
    var image: NSImage? {
        // `data` にはNSImageが入っているはずだがPNGだとなぜか `NSAppleEventDescriptor` が返ってくる謎仕様
        // https://stackoverflow.com/questions/7035350/get-itunes-artwork-for-current-song-with-scriptingbridge
        // https://genjiapp.com/blog/2015/02/13/developed-itunes-rating-widget.html
        guard let obj = rawData as? SBObjectProtocol else { return nil }
        switch obj.get() {
        case let image as NSImage:
            return image
        case let descriptor as NSAppleEventDescriptor:
            return NSImage(data: descriptor.data)
        default:
            return nil
        }
    }
}
