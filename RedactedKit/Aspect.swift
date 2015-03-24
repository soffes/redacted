//
//  Aspect.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import CoreGraphics

public func SizeAspectFit(aspectRatio: CGSize, boundingSize: CGSize) -> CGSize {
	let widthRatio = (boundingSize.width / aspectRatio.width)
	let heightRatio = (boundingSize.height / aspectRatio.height)
	var size = boundingSize
	if widthRatio < heightRatio {
		size.height = boundingSize.width / aspectRatio.width * aspectRatio.height
	}
	else if heightRatio < widthRatio {
		size.width = boundingSize.height / aspectRatio.height * aspectRatio.width
	}
	return CGSizeMake(ceil(size.width), ceil(size.height))
}

public func RectAspectFit(aspectRatio: CGSize, boundingRect: CGRect) -> CGRect {
	let size = SizeAspectFit(aspectRatio, boundingRect.size)
	var origin = boundingRect.origin
	origin.x += (boundingRect.size.width - size.width) / 2.0
	origin.y += (boundingRect.size.height - size.height) / 2.0
	return CGRect(origin: origin, size: size)
}
