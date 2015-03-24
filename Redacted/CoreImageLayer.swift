//
//  CoreImageLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import Quartz
import RedactedKit

class CoreImageLayer: CALayer {

	// MARK: - Properties

	var image: CIImage? {
		didSet {
			setNeedsDisplayInRect(bounds)
		}
	}


	// MARK: - CALayer

	override func drawInContext(ctx: CGContext!) {
		if let image = image {
			let ciContext = CIContext(CGContext: ctx, options: [
				kCIContextUseSoftwareRenderer: false,
				kCIContextWorkingColorSpace: NSNull()
			])

			ciContext.drawImage(image, inRect: imageRectForBounds(bounds), fromRect: image.extent())
		}
	}


	// MARK: - Private

	private func imageRectForBounds(bounds: CGRect) -> CGRect {
		if let image = image {
			return RectAspectFit(image.extent().size, bounds)
		}
		return bounds
	}
}
