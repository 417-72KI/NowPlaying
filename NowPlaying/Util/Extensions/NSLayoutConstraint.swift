//
//  NSLayoutConstraint.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/12/12.
//

import AppKit

typealias Constraint = (NSView, NSView) -> NSLayoutConstraint

func equal<L, Axis>(_ from: KeyPath<NSView, L>, _ to: KeyPath<NSView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    { $0[keyPath: from].constraint(equalTo: $1[keyPath: to], constant: constant) }
}

func equal<L, Axis>(_ keyPath: KeyPath<NSView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    equal(keyPath, keyPath, constant: constant)
}

extension NSView {
    func addSubview(_ other: NSView, constraints: [(NSView, NSView) -> NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        other.translatesAutoresizingMaskIntoConstraints = false
        addSubview(other)
        addConstraints(constraints.map { $0(other, self) })
    }
}
