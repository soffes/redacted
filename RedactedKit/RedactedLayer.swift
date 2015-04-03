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

	private var selectedUUIDs = Set<String>() {
		didSet {
			updateSelections()
		}
	}

	public var selectedRedactions: [Redaction] {
		var selected = [Redaction]()
		let allUUIDs = redactions.map({ $0.UUID })
		for UUID in selectedUUIDs {
			if let index = find(allUUIDs, UUID) {
				selected.append(redactions[index])
			}
		}
		return selected
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

	public func delete() {
		for UUID in selectedUUIDs {
			if let index = find(redactions.map({ $0.UUID }), UUID) {
				let redaction = redactions[index]
				deselect(redaction)
				redactions.removeAtIndex(index)
			}
		}
	}

	public func tap(#point: CGPoint) {
		let point = converPointToUnits(point)

		for redaction in reverse(redactions) {
			if redaction.rect.contains(point) {
				if selected(redaction) {
					deselect(redaction)
				} else {
					select(redaction)
				}
				return
			}
		}
	}

	public func drag(#point: CGPoint, state: GestureRecognizerState) {
		let point = converPointToUnits(point)

		// Start
		if state == .Began {
			deselectAll()

			let redaction = Redaction(type: mode, rect: CGRect(origin: point, size: CGSizeZero))
			editingUUID = redaction.UUID
			redactions.append(redaction)
			select(redaction)
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
			// TODO: Check for too small of a rect
			editingUUID = nil
		}
	}


	// MARK: - Private

	private func converPointToUnits(point: CGPoint) -> CGPoint {
		let rect = imageRect
		var point = point.flippedInRect(bounds)
		point.x = (point.x - rect.origin.x) / rect.size.width
		point.y = (point.y - rect.origin.y) / rect.size.height
		return point
	}

	private func selected(redaction: Redaction) -> Bool {
		return selectedUUIDs.contains(redaction.UUID)
	}

	private func select(redaction: Redaction) {
		if selected(redaction) {
			return
		}

		selectedUUIDs.insert(redaction.UUID)

		let layer = CALayer()
		layer.borderWidth = 1
		layer.borderColor = CGColorCreateGenericRGB(0, 0, 0, 0.2)
		boundingBoxes[redaction.UUID] = layer
		addSublayer(layer)

		updateSelections()
	}

	private func deselect(redaction: Redaction) {
		if let layer = boundingBoxes[redaction.UUID] {
			layer.removeFromSuperlayer()
		}
		boundingBoxes.removeValueForKey(redaction.UUID)
		selectedUUIDs.remove(redaction.UUID)
	}

	private func deselectAll() {
		for redaction in selectedRedactions {
			deselect(redaction)
		}
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

		for redaction in selectedRedactions {
			if let layer = boundingBoxes[redaction.UUID] {
				layer.frame = redaction.rectForBounds(imageRect).flippedInRect(bounds)
			}
		}

		CATransaction.commit()
	}
}
