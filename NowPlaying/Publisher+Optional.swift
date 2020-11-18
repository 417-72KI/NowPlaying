//
//  Publisher+Optional.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/19.
//

import Foundation
import Combine

extension Publisher where Output: OptionalType {
    var wrapped: Publishers.CompactMap<Self, Output.Wrapped> {
        compactMap { $0.value }
    }
}

protocol OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? { self }
}
