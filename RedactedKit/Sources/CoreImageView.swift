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
		guard window != nil, let image = image else { return }

		var bounds = self.bounds
		bounds.size.width *= contentScaleFactor
		bounds.size.height *= contentScaleFactor

		let rect = imageRect(for: bounds)

		ciContext.draw(image, in: bounds, from: rect)
	}

	open override func layoutSubviews() {
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
