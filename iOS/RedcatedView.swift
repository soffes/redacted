//
//  RedcatedView.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit
import X

class RedactedView: UIView {

	// MARK: - Properties

	let redactedLayer = RedactedLayer()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}


	// MARK: - UIView

	override func layoutSubviews() {
		super.layoutSubviews()
		layoutLayers()
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if let scale = window?.screen.scale {
			layer.contentsScale = scale
			redactedLayer.contentsScale = scale
		}
	}


	// MARK: - Private

	private func initialize() {
		layer.backgroundColor = Color(red: 0.863, green: 0.863, blue: 0.863, alpha: 1).CGColor
		layer.addSublayer(redactedLayer)
		layoutLayers()
	}

	private func layoutLayers() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		redactedLayer.frame = layer.bounds
		CATransaction.commit()
	}
}
