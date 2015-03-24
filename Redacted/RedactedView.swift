//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class RedactedView: NSView {

	// MARK: - Properties

	var originalImage: NSImage? {
		didSet {
			if let originalImage = originalImage {
				let cgImage = originalImage.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue()
				originalCIImage = CIImage(CGImage: cgImage)
			} else {
				originalCIImage = nil
			}
		}
	}

	var originalCIImage: CIImage? {
		didSet {
			updateRedactions()
		}
	}

	var redactions = [Redaction]() {
		didSet {
			updateRedactions()
		}
	}

	private let imageLayer = CoreImageLayer()

	var imageRect: CGRect {
		return imageLayer.imageRectForBounds(imageLayer.bounds)
	}


	// MARK: - Initializers

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}


	// MARK: - NSView

	override func layout() {
		super.layout()
		layoutLayers()
	}


	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		if let scale = window?.screen?.backingScaleFactor {
			layer?.contentsScale = scale
			imageLayer.contentsScale = scale
		}
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true

		if let layer = layer {
			layer.backgroundColor = NSColor(SRGBRed: 0.863, green: 0.863, blue: 0.863, alpha: 1).CGColor
			layer.addSublayer(imageLayer)
			layoutLayers()
		}
	}

	private func layoutLayers() {
		if let layer = layer {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			imageLayer.frame = layer.bounds
			CATransaction.commit()
		}

		updateRedactions()
	}

	
	// MARK: - Private

	private func updateRedactions() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		if let ciImage = originalCIImage {
			imageLayer.image = redact(image: ciImage, withRedactions: redactions)
		} else {
			imageLayer.image = nil
		}
		CATransaction.commit()
	}
}
