//
//  CoreImageLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/28/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import QuartzCore

#if os(iOS)
	import CoreImage
#endif

class CoreImageLayer: CALayer {

	// MARK: - Properties

	var image: CIImage? {
		didSet {
			setNeedsDisplayIn(bounds)
		}
	}


	// MARK: - CALayer

	override func draw(in context: CGContext) {
		if let image = image {
			let options = [
				kCIContextUseSoftwareRenderer: false,
				kCIContextWorkingColorSpace: NSNull()
			] as [String : Any]


			let ciContext = CIContext(cgContext: context, options: options)
			ciContext.draw(image, in: imageRectForBounds(bounds), from: image.extent)
		}
	}


	// MARK: - Private

	func imageRectForBounds(_ bounds: CGRect) -> CGRect {
		if let image = image {
			return bounds.aspectFit(image.extent.size)
		}
		return bounds
	}
}
