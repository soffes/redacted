//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class RedactedView: ImageDragDestinationView {

	// MARK: - Properties

	var image: NSImage? {
		didSet {
			if let image = image {
				let cgImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue()
				ciImage = CIImage(CGImage: cgImage)
			} else {
				ciImage = nil
			}
		}
	}

	private var ciImage: CIImage? {
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


	// MARK: - Private

	private func initialize() {
		wantsLayer = true

		registerForDraggedTypes([NSFilenamesPboardType])

		if let layer = layer {
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
		if let ciImage = ciImage {
			imageLayer.image = redact(image: ciImage, withRedactions: redactions)
		} else {
			imageLayer.image = nil
		}
	}
}
