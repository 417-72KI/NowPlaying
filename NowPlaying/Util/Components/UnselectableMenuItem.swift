//
//  UnselectableMenuItem.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/12/12.
//

import Cocoa

final class UnselectableMenuItem: NSMenuItem {
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setContentView(NSTextField(labelWithString: title))
    }
}

extension UnselectableMenuItem {
    override var title: String {
        didSet {
            setContentView(NSTextField(labelWithString: title))
        }
    }
    override var image: NSImage? {
        didSet {
            let contentView = NSView().apply {
                if let imageView = image.flatMap(NSImageView.init(image:)) {
                    imageView.frame.size = imageView.image?.size ?? .zero
                    $0.addSubview(imageView, constraints: [
                        equal(\.leadingAnchor),
                        equal(\.topAnchor),
                        equal(\.centerYAnchor)
                    ])
                }
            }
            setContentView(contentView)
        }
    }
}

private extension UnselectableMenuItem {
    func setContentView(_ content: NSView?) {
        let root = NSView().apply {
            if let content = content {
                $0.addSubview(content, constraints: [
                    equal(\.topAnchor, constant: 2),
                    equal(\.centerYAnchor),
                    equal(\.leadingAnchor, constant: 20),
                    equal(\.centerXAnchor)
                ])
            }
        }
        view = root
    }
}
