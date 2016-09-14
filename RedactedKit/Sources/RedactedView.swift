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

public final class RedactedView: View {

	// MARK: - Constants

	public class var modeDidChangeNotificationName: String {
		return "RedactedView.modeDidChangeNotificationName"
	}

	public class var selectionDidChangeNotificationName: String {
		return "RedactedView.selectionDidChangeNotificationName"
	}


	// MARK: - Properties

	private let redactedLayer = RedactedLayer()

	public var originalImage: Image? {
		get {
			return redactedLayer.originalImage
		}

		set {
			redactedLayer.originalImage = newValue
		}
	}

	public var mode: RedactionType {
		get {
			return redactedLayer.mode
		}

		set {
			redactedLayer.mode = newValue
		}
	}

	public override var undoManager: UndoManager? {
		get {
			return redactedLayer.undoManager
		}

		set {
			redactedLayer.undoManager = newValue
		}
	}

	public var redactions: [Redaction] {
		return redactedLayer.redactions
	}

	public var selectionCount: UInt {
		return UInt(redactedLayer.redactions.count)
	}


	// MARK: - Initializers

	public override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}


	// MARK: - View

	public override func layoutSubviews() {
		super.layoutSubviews()
		layoutLayers()
	}

	public override func didMoveToWindow() {
		super.didMoveToWindow()
		updateLayerScale()
	}


	// MARK: - Manipulation

	public func deleteRedaction() {
		redactedLayer.delete()
	}

	public func tap(point: CGPoint, exclusive: Bool = true) {
		redactedLayer.tap(point: point, exclusive: exclusive)
	}

	public func drag(point: CGPoint, state: GestureRecognizerState) {
		redactedLayer.drag(point: point, state: state)
	}


	// MARK: - Selection

	public func selectAllRedactions() {
		redactedLayer.selectAll()
	}


	// MARK: - Rendering

	public func renderedImage() -> Image? {
		return redactedLayer.redactionsController.process()?.renderedImage
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true
		let layer: CALayer? = self.layer
		layer?.backgroundColor = Color(red: 0.863, green: 0.863, blue: 0.863, alpha: 1).cgColor
		layer?.addSublayer(redactedLayer)
		layoutLayers()
	}

	private func layoutLayers() {
		let layer: CALayer? = self.layer

		CATransaction.begin()
		CATransaction.setDisableActions(true)
		redactedLayer.frame = layer?.bounds ?? CGRect.zero
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