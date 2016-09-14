//
//  NSBezierPath+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 4/26/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

extension NSBezierPath {
	var cgPath: CGPath? {
		let path = CGMutablePath()
		let points = NSPointArray.allocate(capacity: 3)
		var closed = true

		for index in 0..<self.elementCount {
			let pathType = self.element(at: index, associatedPoints: points)
			switch pathType {
			case .moveToBezierPathElement:
				path.move(to: points[0])
				closed = false
			case .lineToBezierPathElement:
				path.addLine(to: points[0])
				closed = false
			case .curveToBezierPathElement:
				path.addCurve(to: points[2], control1: points[0], control2: points[1])
				closed = false
			case .closePathBezierPathElement:
				path.closeSubpath()
				closed = true
			}
		}

		points.deallocate(capacity: 3)

		if !closed {
			path.closeSubpath()
		}

		return path
	}
}
