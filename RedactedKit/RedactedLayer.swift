//
//  RedactedLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/28/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import QuartzCore

public class RedactedLayer: CoreImageLayer {

	// MARK: - Properties

	public var originalImage: Image? {
		didSet {
			if let originalImage = originalImage {
				// TODO: iOS
				let cgImage = originalImage.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue()
				originalCIImage = CIImage(CGImage: cgImage)
			} else {
				originalCIImage = nil
			}
		}
	}

	public var originalCIImage: CIImage? {
		didSet {
			updateRedactions()
		}
	}

	public var redactions = [Redaction]() {
		didSet {
			updateRedactions()
		}
	}

	public var imageRect: CGRect {
		return imageRectForBounds(bounds)
	}

	private var boundingBoxes = [CALayer]()


	// MARK: - CALayer

	public override var frame: CGRect {
		didSet {
			if oldValue.size != frame.size {
				updateRedactions()
			}
		}
	}


	// MARK: - Private

	private func updateRedactions() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		for layer in boundingBoxes {
			layer.removeFromSuperlayer()
		}

		if let ciImage = originalCIImage {
			image = redact(image: ciImage, withRedactions: redactions)

			for redaction in redactions {
				let layer = CALayer()
				layer.borderWidth = 1
				layer.borderColor = CGColorCreateGenericRGB(0, 0, 0, 0.2)
				layer.frame = redaction.filteredRectForBounds(imageRect)
				boundingBoxes.append(layer)
				addSublayer(layer)
			}

		} else {
			image = nil
		}
		CATransaction.commit()
	}
}
