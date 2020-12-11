//
//  Applicable.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/12/12.
//

import Foundation

protocol Applicable {
}

extension Applicable where Self: AnyObject {
    func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Applicable {
}
