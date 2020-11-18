//
//  NSImage+Util.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/19.
//

import Cocoa

extension NSImage {
    func resize(width: CGFloat, height: CGFloat) -> NSImage? {
        guard let sourceBitmapRep = tiffRepresentation.flatMap(NSBitmapImageRep.init(data:)),
              let image = sourceBitmapRep.cgImage else { return nil }
        guard let bitmapContext = CGContext(data: nil,
                                            width: Int(width),
                                            height: Int(height),
                                            bitsPerComponent: 8,
                                            bytesPerRow: Int(width) * 4,
                                            space: CGColorSpaceCreateDeviceRGB(),
                                            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue) else { return nil }
        bitmapContext.draw(image, in: .init(origin: .zero, size: .init(width: width, height: height)))
        guard let newImageRef = bitmapContext.makeImage() else { return nil }
        return NSImage(cgImage: newImageRef, size: .init(width: width, height: height))
    }
}

extension NSImage {
    func resize(width: CGFloat) -> NSImage? {
        resize(width: width, height: width / size.aspectRatio)
    }

    func resize(height: CGFloat) -> NSImage? {
        resize(width: height * size.aspectRatio, height: height)
    }
}

extension CGSize {
    var aspectRatio: CGFloat {
        width / height
    }
}
