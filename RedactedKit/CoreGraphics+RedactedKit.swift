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

	public func aspectFit(aspectRatio: CGSize) -> CGRect {
		let size = self.size.aspectFit(aspectRatio)
		var origin = self.origin
		origin.x += (self.size.width - size.width) / 2.0
		origin.y += (self.size.height - size.height) / 2.0
		return CGRect(origin: origin, size: size)
	}
}


extension CGSize {
	public func aspectFit(aspectRatio: CGSize) -> CGSize {
		let widthRatio = (width / aspectRatio.width)
		let heightRatio = (height / aspectRatio.height)
		var size = self
		if widthRatio < heightRatio {
			size.height = width / aspectRatio.width * aspectRatio.height
		}
		else if heightRatio < widthRatio {
			size.width = height / aspectRatio.height * aspectRatio.width
		}
		return CGSizeMake(ceil(size.width), ceil(size.height))
	}
}


extension CGPoint {
	public func flippedInRect(bounds: CGRect) -> CGPoint {
		return CGPoint(
			x: x,
			y: bounds.size.height - y
		)
	}
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x - rhs.x, y: lhs.y - lhs.x)
}
