//
//  CoreImageView.swift
//  Redacted
//
//  Created by Sam Soffes on 7/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import CoreImage
import GLKit

public class CoreImageView: GLKView {

	// MARK: - Properties

	var ciImage: CIImage? {
		didSet {
			setNeedsDisplay()
		}
	}

	private let ciContext: CIContext


	// MARK: - Initializers

	public convenience init() {
		self.init(frame: .zero, context: EAGLContext(api: .openGLES2)!)
	}

	public override init(frame: CGRect, context: EAGLContext) {
		ciContext = CIContext(eaglContext: context, options: [
			kCIContextWorkingColorSpace: NSNull()
		])

		super.init(frame: frame, context: context)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - View

	public override func draw(_ rect: CGRect) {
		guard var image = ciImage else {
			// TODO: Clear
			deleteDrawable()
			return
		}

		image = image.applying(CGAffineTransform(scaleX: 1, y: -1))
		image = image.applying(CGAffineTransform(translationX: 0, y: image.extent.height))

		bindDrawable()
		ciContext.draw(image, in: pixelImageRectForBounds(bounds), from: image.extent)
	}


	// MARK: - Configuration

	func imageRectForBounds(_ bounds: CGRect) -> CGRect {
		var rect = bounds

		if let ciImage = ciImage {
			rect = rect.aspectFit(ciImage.extent.size)
		}

		return rect
	}

	private func pixelImageRectForBounds(_ bounds: CGRect) -> CGRect {
		var rect = imageRectForBounds(bounds)

		rect.origin.x *= contentScaleFactor
		rect.origin.y *= contentScaleFactor
		rect.size.width *= contentScaleFactor
		rect.size.height *= contentScaleFactor

		return rect
	}
}
