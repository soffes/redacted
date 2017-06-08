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

		let extent = self.extent

		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let cgContext = CGContext(
			data: nil,
			width: Int(extent.width),
			height: Int(extent.height),
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: bitmapInfo.rawValue,
			releaseCallback: nil,
			releaseInfo: nil
		)!
		let ciContext = CIContext(cgContext: cgContext, options: options)

		let cgImage = ciContext.createCGImage(self, from: extent)!

		#if os(iOS)
			return Image(cgImage: cgImage)
		#else
			return Image(cgImage: cgImage)!
		#endif
	}
}
