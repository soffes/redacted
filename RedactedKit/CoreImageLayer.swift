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

public class CoreImageLayer: CALayer {

	// MARK: - Properties

	var image: CIImage? {
		didSet {
			setNeedsDisplayInRect(bounds)
		}
	}


	// MARK: - CALayer

	public override func drawInContext(ctx: CGContext!) {
		if let image = image {
			let options = [
				kCIContextUseSoftwareRenderer: false,
				kCIContextWorkingColorSpace: NSNull()
			]

			#if os(iOS)
				let ciContext = CIContext(options: options)
			#else
				let ciContext = CIContext(CGContext: ctx, options: options)
			#endif

			ciContext.drawImage(image, inRect: imageRectForBounds(bounds), fromRect: image.extent())
		}
	}


	// MARK: - Private

	func imageRectForBounds(bounds: CGRect) -> CGRect {
		if let image = image {
			return bounds.aspectFit(image.extent().size)
		}
		return bounds
	}
}
