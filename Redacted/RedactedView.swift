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

	var image: NSImage? {
		didSet {
			imageLayer.contents = image
		}
	}

	private let imageLayer = CALayer()


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

	override var flipped: Bool {
		return true
	}

	override func layout() {
		super.layout()

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		imageLayer.frame = layer?.bounds ?? bounds
		CATransaction.commit()
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true

		imageLayer.contentsGravity = kCAGravityResizeAspect

		if let layer = layer {
			imageLayer.frame = layer.bounds
			layer.addSublayer(imageLayer)
		}
	}
}
