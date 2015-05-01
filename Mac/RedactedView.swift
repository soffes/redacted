//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import RedactedKit
import X

class RedactedView: NSView {

	// MARK: - Properties

	let redactedLayer = RedactedLayer()


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
			redactedLayer.contentsScale = scale
		}
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true

		if let layer = layer {
			layer.backgroundColor = Color(red: 0.863, green: 0.863, blue: 0.863, alpha: 1).CGColor
			layer.addSublayer(redactedLayer)
			layoutLayers()
		}
	}

	private func layoutLayers() {
		if let layer = layer {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			redactedLayer.frame = layer.bounds
			CATransaction.commit()
		}
	}
}
