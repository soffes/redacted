//
//  CoreImageLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/28/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import Quartz

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
			// TODO: iOS
			let ciContext = CIContext(CGContext: ctx, options: [
				kCIContextUseSoftwareRenderer: false,
				kCIContextWorkingColorSpace: NSNull()
			])

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
