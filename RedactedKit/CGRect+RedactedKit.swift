//
//  CGRect+RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import CoreGraphics

extension CGRect {

	public var center: CGPoint {
		return CGPoint(x: midX, y: midY)
	}

	public func flippedInRect(bounds: CGRect) -> CGRect {
		return CGRect(
			x: origin.x,
			y: bounds.size.height - size.height - origin.y,
			width: size.width,
			height: size.height
		)
	}
}
