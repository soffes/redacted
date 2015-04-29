//
//  CIImage+RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import X

#if os(iOS)
	import CoreImage
#else
	import QuartzCore
#endif

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
		#else
			let cgContext = CGBitmapContextCreate(nil, Int(extent.width), Int(extent.height), 8, 0, colorSpace, CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue))
			let ciContext = CIContext(CGContext: cgContext, options: options)
		#endif

		let cgImage = ciContext.createCGImage(self, fromRect: extent)
		return Image(CGImage: cgImage)!
	}
}
