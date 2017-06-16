//
//  CoreImageView.swift
//  Redacted
//
//  Created by Sam Soffes on 6/16/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import GLKit

#if os(OSX)
	import QuartzCore
#else
	import CoreImage
#endif

open class CoreImageView: GLKView {

	// MARK: - Properties

	open var image: CIImage? {
		didSet {
			triggerDraw()
		}
	}

	private let ciContext: CIContext


	// MARK: - Initializers

	public convenience init() {
		self.init(frame: .zero)
	}

	public override init(frame: CGRect) {
		let context = EAGLContext(api: .openGLES2)!
		ciContext = CIContext(eaglContext: context)

		super.init(frame: frame, context: context)

		isUserInteractionEnabled = false
		enableSetNeedsDisplay = false
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - View

	open override func draw(_ rect: CGRect) {
		guard window != nil && self.bounds.width > 0 && self.bounds.height > 0,
			let image = image
		else { return }

		// Calculate coordinates
		var bounds = self.bounds
		bounds.size.width *= contentScaleFactor
		bounds.size.height *= contentScaleFactor

		let rect = imageRect(for: bounds)

		// Flip image
		let flipped = image.applying(CGAffineTransform(scaleX: 1, y: -1).concatenating(CGAffineTransform(translationX: 0, y: image.extent.height)))

		// Draw
		ciContext.draw(flipped, in: rect, from: flipped.extent)
	}

	open override func layoutSubviews() {
		super.layoutSubviews()
		triggerDraw()
	}


	// MARK: - Configuration

	open func imageRect(for bounds: CGRect) -> CGRect {
		if let image = image {
			return bounds.aspectFit(image.extent.size)
		}
		
		return bounds
	}


	// MARK: - Private

	private func triggerDraw() {
		if enableSetNeedsDisplay {
			setNeedsDisplay()
		} else {
			display()
		}
	}
}
