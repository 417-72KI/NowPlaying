//
//  Publisher+Optional.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/11/19.
//

import Foundation
import Combine

extension Publisher where Output: OptionalType {
    var wrapped: AnyPublisher<Self.Output.Wrapped, Self.Failure> {
        compactMap(\.value)
            .eraseToAnyPublisher()
    }

    func map<T>(_ keyPath: KeyPath<Self.Output.Wrapped, T>) -> AnyPublisher<T?, Self.Failure> {
        map { $0.value?[keyPath: keyPath] }
            .eraseToAnyPublisher()
    }

    func map<T>(_ keyPath: KeyPath<Self.Output.Wrapped, T>, default defaultValue: T) -> AnyPublisher<T, Self.Failure> {
        map { $0.value?[keyPath: keyPath] ?? defaultValue }
            .eraseToAnyPublisher()
    }
}

protocol OptionalType {
    associatedtype Wrapped

    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? { self }
}
