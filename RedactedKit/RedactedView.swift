//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import X
import QuartzCore

// TODO: Remove
#if os(iOS)
	import CoreImage
	import UIKit.UIGestureRecognizer
	public typealias GestureRecognizerState = UIGestureRecognizerState
#else
	import AppKit.NSGestureRecognizer
	public typealias GestureRecognizerState = NSGestureRecognizerState
#endif

open class RedactedView: View {

	// MARK: - Constants

	open class var modeDidChangeNotificationName: String {
		return "RedactedView.modeDidChangeNotificationName"
	}

	open class var selectionDidChangeNotificationName: String {
		return "RedactedView.selectionDidChangeNotificationName"
	}


	// MARK: - Properties

	fileprivate let redactedLayer = RedactedLayer()

	open var originalImage: Image? {
		get {
			return redactedLayer.originalImage
		}

		set {
			redactedLayer.originalImage = newValue
		}
	}

	open var mode: RedactionType {
		get {
			return redactedLayer.mode
		}

		set {
			redactedLayer.mode = newValue
		}
	}

	open override var undoManager: UndoManager? {
		get {
			return redactedLayer.undoManager
		}

		set {
			redactedLayer.undoManager = newValue
		}
	}

	open var redactions: [Redaction] {
		return redactedLayer.redactions
	}

	open var selectionCount: UInt {
		return UInt(redactedLayer.redactions.count)
	}


	// MARK: - Initializers

	public override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	#if os(iOS)
		public required init?(coder aDecoder: NSCoder) {
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

	open override func layoutSubviews() {
		super.layoutSubviews()
		layoutLayers()
	}

	open override func didMoveToWindow() {
		super.didMoveToWindow()
		updateLayerScale()
	}


	// MARK: - Manipulation

	open func deleteRedaction() {
		redactedLayer.delete()
	}

	open func tap(point: CGPoint, exclusive: Bool = true) {
		redactedLayer.tap(point: point, exclusive: exclusive)
	}

	open func drag(point: CGPoint, state: GestureRecognizerState) {
		redactedLayer.drag(point: point, state: state)
	}


	// MARK: - Selection

	open func selectAllRedactions() {
		redactedLayer.selectAll()
	}


	// MARK: - Rendering

	open func renderedImage() -> Image? {
		return redactedLayer.redactionsController.process()?.renderedImage
	}


	// MARK: - Private

	fileprivate func initialize() {
		wantsLayer = true
		let layer: CALayer? = self.layer
		layer?.backgroundColor = Color(red: 0.863, green: 0.863, blue: 0.863, alpha: 1).cgColor
		layer?.addSublayer(redactedLayer)
		layoutLayers()
	}

	fileprivate func layoutLayers() {
		let layer: CALayer? = self.layer

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		redactedLayer.frame = layer?.bounds ?? CGRect.zero
		CATransaction.commit()
	}

	fileprivate func updateLayerScale() {
		let screen: Screen? = window?.screen
		let layer: CALayer? = self.layer
		let scale = screen?.scale ?? 1.0
		layer?.contentsScale = scale
		redactedLayer.contentsScale = scale
	}
}
