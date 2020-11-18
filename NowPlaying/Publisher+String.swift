//
//  Publisher+String.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/19.
//

import Foundation
import Combine

extension Publisher where Output == String? {
    var orEmpty: Publishers.Map<Self, String> {
        map { $0 ?? "" }
    }
}
