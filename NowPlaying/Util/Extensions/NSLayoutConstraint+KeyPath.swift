//
//  NSLayoutConstraint+KeyPath.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/12/12.
//

#if canImport(AppKit)
import AppKit
typealias NSUIView = NSView
#endif

#if canImport(UIKit)
import UIKit
typealias NSUIView = UIView
#endif

typealias Constraint = (NSUIView, NSUIView) -> NSLayoutConstraint

func equal<L, Axis>(_ from: KeyPath<NSUIView, L>, _ to: KeyPath<NSUIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    { $0[keyPath: from].constraint(equalTo: $1[keyPath: to], constant: constant) }
}

func equal<L, Axis>(_ keyPath: KeyPath<NSUIView, L>, constant: CGFloat = 0) -> Constraint where L: NSLayoutAnchor<Axis> {
    equal(keyPath, keyPath, constant: constant)
}

extension NSUIView {
    func addSubview(_ other: NSUIView, constraints: [(NSUIView, NSUIView) -> NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        other.translatesAutoresizingMaskIntoConstraints = false
        addSubview(other)
        addConstraints(constraints.map { $0(other, self) })
    }
}
