//
//  RedactedLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/28/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import QuartzCore

// TODO: iOS
public typealias GestureRecognizerState = NSGestureRecognizerState

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

			boundingBoxes.removeAll()
			selectedUUIDs.removeAll()
			redactions.removeAll()
		}
	}

	public var originalCIImage: CIImage? {
		didSet {
			updateRedactions()
		}
	}

	public var mode: RedactionType = .Pixelate

	public var redactions = [Redaction]() {
		didSet {
			updateRedactions()
		}
	}

	public var selectedUUIDs = Set<String>() {
		didSet {
			updateSelections()
		}
	}

	public var imageRect: CGRect {
		return imageRectForBounds(bounds)
	}

	private var editingUUID: String?
	private var boundingBoxes = [String: CALayer]()


	// MARK: - CALayer

	public override var frame: CGRect {
		didSet {
			if oldValue.size != frame.size {
				updateRedactions()
			}
		}
	}


	// MARK: - Manipulation

	public func tap(#point: CGPoint) {
		
	}

	public func drag(#point: CGPoint, state: GestureRecognizerState) {
		let bounds = imageRect

		// Convert point
		var point = point.flippedInRect(bounds)
		point.x = (point.x - bounds.origin.x) / bounds.size.width
		point.y = (point.y - bounds.origin.y) / bounds.size.height

		// Start
		if state == .Began {
			let redaction = Redaction(type: mode, rect: CGRect(origin: point, size: CGSizeZero))
			editingUUID = redaction.UUID
			redactions.append(redaction)
			selectRedaction(redaction)
		}

		// Find the currently dragging redaction
		if let editingUUID = editingUUID, index = find(redactions.map({ $0.UUID }), editingUUID) {
			var redaction = redactions[index]
			let startPoint = redaction.rect.origin
			redaction.rect = CGRect(
				x: startPoint.x,
				y: startPoint.y,
				width: point.x - startPoint.x,
				height: point.y - startPoint.y
			)

			redactions[index] = redaction
		}

		// Finished dragging
		if state == .Ended {
			if let editingUUID = editingUUID, index = find(redactions.map({ $0.UUID }), editingUUID) {
				deselectRedaction(redactions[index])
			}

			// TODO: Check for too small of a rect
			editingUUID = nil
		}
	}


	// MARK: - Private

	private func selectRedaction(redaction: Redaction) {
		selectedUUIDs.insert(redaction.UUID)

		let layer = CALayer()
		layer.borderWidth = 1
		layer.borderColor = CGColorCreateGenericRGB(0, 0, 0, 0.2)
		boundingBoxes[redaction.UUID] = layer
		addSublayer(layer)

		updateSelections()
	}

	private func deselectRedaction(redaction: Redaction) {
		if let layer = boundingBoxes[redaction.UUID] {
			layer.removeFromSuperlayer()
		}
		boundingBoxes.removeValueForKey(redaction.UUID)
		selectedUUIDs.remove(redaction.UUID)
	}

	private func updateRedactions() {
		if let ciImage = originalCIImage {
			image = redact(image: ciImage, withRedactions: redactions)
		} else {
			image = nil
		}

		updateSelections()
	}

	private func updateSelections() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		for UUID in selectedUUIDs {
			if let index = find(redactions.map({ $0.UUID }), UUID) {
				let redaction = redactions[index]
				if let layer = boundingBoxes[redaction.UUID] {
					layer.frame = redaction.filteredRectForBounds(imageRect)
					println("layer.frame = \(layer.frame)")
				}
			}
		}

		CATransaction.commit()
	}
}
