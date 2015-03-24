//
//  CoreImageLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import Quartz

class CoreImageLayer: CALayer {

	var image: CIImage? {
		didSet {
			setNeedsDisplayInRect(bounds)
		}
	}

	override func drawInContext(ctx: CGContext!) {
		if let image = image {
			let ciContext = CIContext(CGContext: ctx, options: [
				kCIContextUseSoftwareRenderer: false,
				kCIContextWorkingColorSpace: NSNull()
			])

			ciContext.drawImage(image, inRect: bounds, fromRect: image.extent())
		}
	}
}
