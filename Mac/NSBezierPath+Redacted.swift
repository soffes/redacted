//
//  NSBezierPath+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 4/26/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

extension NSBezierPath {
	var CGPath: CGPathRef? {
		var path = CGPathCreateMutable()
		var points = NSPointArray.alloc(3)
		var closed = true

		for index in 0..<self.elementCount {
			let pathType = self.elementAtIndex(index, associatedPoints: points)
			switch pathType {
			case .MoveToBezierPathElement:
				CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
				closed = false
			case .LineToBezierPathElement:
				CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
				closed = false
			case .CurveToBezierPathElement:
				CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
				closed = false
			case .ClosePathBezierPathElement:
				CGPathCloseSubpath(path)
				closed = true
			}
		}

		points.dealloc(3)

		if !closed {
			CGPathCloseSubpath(path)
		}

		return path
	}
}
