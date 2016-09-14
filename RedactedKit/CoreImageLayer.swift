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

open class CoreImageLayer: CALayer {

	// MARK: - Properties

	var image: CIImage? {
		didSet {
			setNeedsDisplayIn(bounds)
		}
	}


	// MARK: - CALayer

	open override func draw(in context: CGContext) {
		if let image = image {
			let options = [
				kCIContextUseSoftwareRenderer: false,
				kCIContextWorkingColorSpace: NSNull()
			] as [String : Any]

			#if os(iOS)
				let ciContext = CIContext(options: options)
			#else
				let ciContext = CIContext(cgContext: context, options: options)
			#endif

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
