//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

#if os(iOS)
	import UIKit
	public typealias View = UIView
#else
	import AppKit
	public typealias View = NSView
#endif

import X

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

	#if os(iOS)
		public override func layoutSubviews() {
			super.layoutSubviews()
			layoutLayers()
		}

		public override func didMoveToWindow() {
			super.didMoveToWindow()
			updateLayerScale()
		}
	#else
		public override func layout() {
			super.layout()
			layoutLayers()
		}

		public override func viewDidMoveToWindow() {
			super.viewDidMoveToWindow()
			updateLayerScale()
		}
	#endif


	// MARK: - Private

	private var backingLayer: CALayer! {
		#if os(iOS)
			return layer
		#else
			return layer
		#endif
	}

	private func initialize() {
		#if os(OSX)
			wantsLayer = true
		#endif

		backingLayer.backgroundColor = Color(red: 0.863, green: 0.863, blue: 0.863, alpha: 1).CGColor
		backingLayer.addSublayer(redactedLayer)
		layoutLayers()
	}

	private func layoutLayers() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		redactedLayer.frame = backingLayer.bounds
		CATransaction.commit()
	}

	private func updateLayerScale() {
		#if os(iOS)
			let scale = window?.screen.scale ?? 1.0
		#else
			let scale = window?.screen?.backingScaleFactor ?? 1.0
		#endif

		backingLayer.contentsScale = scale
		redactedLayer.contentsScale = scale
	}
}
