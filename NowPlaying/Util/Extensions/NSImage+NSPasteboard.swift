//
//  NSImage+NSPasteboard.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/12/12.
//

import Cocoa

extension NSImage {
    func copy(to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        pasteboard.writeObjects([self])
    }
}
