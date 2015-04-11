//
//  CIImage+RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

#if os(iOS)
	import CoreImage
	import UIKit.UIColor
	public typealias Image = UIImage
 #else
	import AppKit.NSColor
	public typealias Image = NSImage

	extension NSImage {
		var CGImage: CGImageRef! {
			return CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue()
		}
	}
 #endif

import QuartzCore

extension CIImage {
	public var renderedImage: Image {
	let colorSpace = CGColorSpaceCreateDeviceRGB()
	let options = [
		kCIContextWorkingColorSpace: colorSpace,
		kCIContextOutputColorSpace: colorSpace,
	]

	let extent = self.extent()

	#if os(iOS)
		let ciContext = CIContext(options: nil)
		let cgImage = ciContext.createCGImage(self, fromRect: extent)
		return UIImage(CGImage: cgImage)!
	#else
		let cgContext = CGBitmapContextCreate(nil, Int(extent.width), Int(extent.height), 8, 0, colorSpace, CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue))
		let ciContext = CIContext(CGContext: cgContext, options: options)
		let cgImage = ciContext.createCGImage(self, fromRect: extent)
		return NSImage(CGImage: cgImage, size: CGSizeZero)
	#endif
	}
}
