//
//  CIImage+RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import QuartzCore

extension CIImage {
	public var renderedImage: NSImage {
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let options = [
			kCIContextWorkingColorSpace: colorSpace,
			kCIContextOutputColorSpace: colorSpace,
		]

		let extent = self.extent()
		let cgContext = CGBitmapContextCreate(nil, Int(extent.width), Int(extent.height), 8, 0, colorSpace, CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue))
		let ciContext = CIContext(CGContext: cgContext, options: options)
		let imageRef = ciContext.createCGImage(self, fromRect: extent)
		return NSImage(CGImage: imageRef, size: NSMakeSize(0, 0))
	}
}
