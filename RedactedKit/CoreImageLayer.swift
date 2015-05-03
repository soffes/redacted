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
	import OpenGLES

	public typealias OpenGLLayerType = OpenGLLayer
#else
	public typealias OpenGLLayerType = CALayer
#endif

public class CoreImageLayer: OpenGLLayerType {

	// MARK: - Properties

	var image: CIImage? {
		didSet {
			#if os(iOS)
				display()
			#else
				setNeedsDisplayInRect(bounds)
			#endif
		}
	}


	// MARK: - Initializers

	public convenience init() {
		self.init(layer: nil)
	}

	public override init!(layer: AnyObject!) {
		super.init(layer: layer)
		initialize()
	}

	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}


	// MARK: - CALayer

	#if os(iOS)
		public override func render() {
			if let image = image {
				let options = [
					kCIContextUseSoftwareRenderer: false,
					kCIContextWorkingColorSpace: NSNull()
				]

				let ciContext = CIContext(EAGLContext: eaglContext, options: options)
				ciContext.drawImage(image, inRect: imageRectForBounds(bounds), fromRect: image.extent())
			}
		}
	#else
		public override func drawInContext(ctx: CGContext!) {
			if let image = image {
				let options = [
					kCIContextUseSoftwareRenderer: false,
					kCIContextWorkingColorSpace: NSNull()
				]

				let ciContext = CIContext(CGContext: ctx, options: options)
				ciContext.drawImage(image, inRect: imageRectForBounds(bounds), fromRect: image.extent())
			}
		}
	#endif


	// MARK: - Private

	private func initialize() {
		opaque = true
	}

	func imageRectForBounds(bounds: CGRect) -> CGRect {
		if let image = image {
			return bounds.aspectFit(image.extent().size)
		}
		return bounds
	}
}
