//
//  CGRect+RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import CoreGraphics

extension CGRect {
	var center: CGPoint {
		return CGPoint(x: midX, y: midY)
	}

	func flippedInRect(bounds: CGRect) -> CGRect {
		return CGRect(
			x: origin.x,
			y: bounds.size.height - size.height - origin.y,
			width: size.width,
			height: size.height
		)
	}

	func aspectFit(aspectRatio: CGSize) -> CGRect {
		let size = self.size.aspectFit(aspectRatio)
		var origin = self.origin
		origin.x += (self.size.width - size.width) / 2.0
		origin.y += (self.size.height - size.height) / 2.0
		return CGRect(origin: origin, size: size)
	}

	var stringRepresentation: String {
		#if os(iOS)
			return NSStringFromCGRect(self)
		#else
			return NSStringFromRect(self)
		#endif
	}

	init(string: String) {
		#if os(iOS)
			self = CGRectFromString(string)
		#else
			self = NSRectFromString(string) as CGRect
		#endif
	}

	func inset(x: CGFloat) -> CGRect {
		return inset(x: x, y: x)
	}

	func inset(#x: CGFloat, y: CGFloat) -> CGRect {
		return CGRectInset(self, x, y)
	}
}


extension CGSize {
	func aspectFit(aspectRatio: CGSize) -> CGSize {
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
	func flippedInRect(bounds: CGRect) -> CGPoint {
		return CGPoint(
			x: x,
			y: bounds.size.height - y
		)
	}
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPoint(x: lhs.x - rhs.x, y: lhs.y - lhs.x)
}
