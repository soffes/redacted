//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import X
import QuartzCore

public class RedactedView: View {

	// MARK: - Properties

	public let redactedLayer = RedactedLayer()


	// MARK: - Initializers

	public override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	#if os(iOS)
		public required init(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			initialize()
		}
	#else
		public required init?(coder aDecoder: NSCoder) {
			super.init(coder: aDecoder)
			initialize()
		}
	#endif


	// MARK: - View

	public override func layoutSubviews() {
		super.layoutSubviews()
		layoutLayers()
	}

	public override func didMoveToWindow() {
		super.didMoveToWindow()
		updateLayerScale()
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true
		let layer: CALayer? = self.layer
		layer?.backgroundColor = Color(red: 0.863, green: 0.863, blue: 0.863, alpha: 1).CGColor
		layer?.addSublayer(redactedLayer)
		layoutLayers()
	}

	private func layoutLayers() {
		let layer: CALayer? = self.layer

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		redactedLayer.frame = layer?.bounds ?? CGRectZero
		CATransaction.commit()
	}

	private func updateLayerScale() {
		let screen: Screen? = window?.screen
		let layer: CALayer? = self.layer
		let scale = screen?.scale ?? 1.0
		layer?.contentsScale = scale
		redactedLayer.contentsScale = scale
	}
}
