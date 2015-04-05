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

	// MARK: - Types

	enum DraggingMode {
		case Creating(String)
		case Moving(String)
	}


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

	private var draggingMode: DraggingMode?
	private var boundingBoxes = [String: CALayer]()

	public var undoManager: NSUndoManager?


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
		removeRedactions(selectedRedactions)
	}

	public func tap(#point: CGPoint, exclusive: Bool = true) {
		let point = converPointToUnits(point)

		if let redaction = hitTestRedaction(point) {
			if selected(redaction) {
				deselect(redaction)
			} else {
				if exclusive {
					deselectAll()
				}
				select(redaction)
			}
			return
		}

		deselectAll()
	}

	public func drag(#point: CGPoint, state: GestureRecognizerState) {
		let point = converPointToUnits(point)

		// Begin
		if state == .Began {
			deselectAll()

			// Start moving
			if let redaction = hitTestRedaction(point) {

			}

			// Start creating
			else {
				let redaction = Redaction(type: mode, rect: CGRect(origin: point, size: CGSizeZero))
				draggingMode = .Creating(redaction.UUID)
				redactions.append(redaction)
				select(redaction)
			}
		}

		// Continue
		if let draggingMode = draggingMode {
			switch draggingMode {
			case let .Creating(UUID):
				// Find the currently dragging redaction
				if let index = find(redactions.map({ $0.UUID }), UUID) {
					var redaction = redactions[index]
					let startPoint = redaction.rect.origin
					redaction.rect = CGRect(
						x: startPoint.x,
						y: startPoint.y,
						width: point.x - startPoint.x,
						height: point.y - startPoint.y
					)

					redactions[index] = redaction

					// Finished dragging
					if state == .Ended {
						redactions.removeAtIndex(index)
						insertRedactions([redaction])
					}
				}

			case let .Moving(UUID):
				println("UUID: \(UUID)")
			}
		}

		// End
		if state == .Ended {
			draggingMode = nil
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

	private func hitTestRedaction(point: CGPoint) -> Redaction? {
		for redaction in reverse(redactions) {
			if redaction.rect.contains(point) {
				return redaction
			}
		}
		return nil
	}

	private func updateRedactions() {
		if let ciImage = originalCIImage {
			image = redact(image: ciImage, withRedactions: redactions)
		} else {
			image = nil
		}

		updateSelections()
	}

	@objc private func insertRedactionDictionaries(dictionaries: [[String: AnyObject]]) {
		let array = dictionaries.map({ Redaction(dictionary: $0) }).filter({ $0 != nil }).map({ $0! })
		insertRedactions(array)
	}

	@objc private func removeRedactionDictionaries(dictionaries: [[String: AnyObject]]) {
		let array = dictionaries.map({ Redaction(dictionary: $0) }).filter({ $0 != nil }).map({ $0! })
		removeRedactions(array)
	}

	private func insertRedactions(redactions: [Redaction]) {
		self.redactions += redactions

		if !(undoManager?.undoing ?? false) {
			let s = redactions.count == 1 ? "" : "s"
			undoManager?.setActionName("Insert Redaction\(s)")
		}
		undoManager?.registerUndoWithTarget(self, selector: "removeRedactionDictionaries:", object: redactions.map({ $0.dictionaryRepresentation }))
	}

	private func removeRedactions(redactions: [Redaction]) {
		for UUID in redactions.map({ $0.UUID }) {
			if let index = find(self.redactions.map({ $0.UUID }), UUID) {
				let redaction = self.redactions[index]
				deselect(redaction)
				self.redactions.removeAtIndex(index)
			}
		}

		if !(undoManager?.undoing ?? false) {
			let s = redactions.count == 1 ? "" : "s"
			undoManager?.setActionName("Delete Redaction\(s)")
		}
		undoManager?.registerUndoWithTarget(self, selector: "insertRedactionDictionaries:", object: redactions.map({ $0.dictionaryRepresentation }))
	}
}


// Selection
extension RedactedLayer {

	// MARK: - Public

	public func selectAll() {
		for redaction in redactions {
			select(redaction)
		}
	}


	// MARK: - Private

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
