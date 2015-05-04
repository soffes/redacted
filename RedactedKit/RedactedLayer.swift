//
//  RedactedLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 3/28/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import QuartzCore
import X

class RedactedLayer: CoreImageLayer {

	// MARK: - Types

	enum DraggingMode {
		case Creating(String)
		case Moving(String, CGRect, CGPoint)
	}


	// MARK: - Properties

	var originalImage: Image? {
		get {
			return redactionsController.image
		}
		
		set {
			redactionsController.image = newValue

			deselectAll()
			redactions.removeAll()

			// TODO: Allow for undoing images
			undoManager?.removeAllActions()
		}
	}

	var mode: RedactionType = .Pixelate {
		didSet {
			NSNotificationCenter.defaultCenter().postNotificationName(RedactedView.modeDidChangeNotificationName, object: self)
		}
	}

	var redactionsController = RedactionsController()

	var redactions: [Redaction] {
		get {
			return redactionsController.redactions
		}

		set {
			redactionsController.redactions = newValue
			updateRedactions()
		}
	}

	private var selectedUUIDs = Set<String>() {
		didSet {
			updateSelections()
		}
	}

	var selectedRedactions: [Redaction] {
		var selected = [Redaction]()
		let allUUIDs = redactions.map({ $0.UUID })
		for UUID in selectedUUIDs {
			if let index = find(allUUIDs, UUID) {
				selected.append(redactions[index])
			}
		}
		return selected
	}

	var imageRect: CGRect {
		return imageRectForBounds(bounds)
	}

	private var draggingMode: DraggingMode?
	private var boundingBoxes = [String: CALayer]()

	var undoManager: NSUndoManager?


	// MARK: - CALayer

	override var frame: CGRect {
		didSet {
			if oldValue.size != frame.size {
				updateRedactions()
			}
		}
	}


	// MARK: - Manipulation

	func delete() {
		removeRedactions(selectedRedactions)
	}

	func tap(#point: CGPoint, exclusive: Bool = true) {
		if image == nil {
			return
		}

		let point = converPointToUnits(point)

		if let redaction = hitTestRedaction(point) {
			if isSelected(redaction) {
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

	func drag(#point: CGPoint, state: GestureRecognizerState) {
		if image == nil {
			return
		}
		
		let point = converPointToUnits(point)

		// Begin
		if state == .Began {
			deselectAll()

			// Start moving
			if let redaction = hitTestRedaction(point) {
				draggingMode = .Moving(redaction.UUID, redaction.rect, point)
				select(redaction)
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

			case let .Moving(UUID, rect, startPoint):
				// Find the currently dragging redaction
				if let index = find(redactions.map({ $0.UUID }), UUID) {
					var redaction = redactions[index]
					var rect = rect
					rect.origin.x += point.x - startPoint.x
					rect.origin.y += point.y - startPoint.y
					redaction.rect = rect

					redactions[index] = redaction
				}
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
		image = redactionsController.process()
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
			let s = redactions.count == 1 ? "" : "S"
			undoManager?.setActionName(string("INSERT_REDACTION\(s)"))
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
			let s = redactions.count == 1 ? "" : "S"
			undoManager?.setActionName(string("DELETE_REDACTION\(s)"))
		}
		undoManager?.registerUndoWithTarget(self, selector: "insertRedactionDictionaries:", object: redactions.map({ $0.dictionaryRepresentation }))
	}
}


// Selection
extension RedactedLayer {

	// MARK: - Public

	func selectAll() {
		for redaction in redactions {
			select(redaction)
		}
	}

	var selectionCount: Int {
		return selectedUUIDs.count
	}


	// MARK: - Private

	private func isSelected(redaction: Redaction) -> Bool {
		return selectedUUIDs.contains(redaction.UUID)
	}

	private func select(redaction: Redaction) {
		if isSelected(redaction) {
			return
		}

		selectedUUIDs.insert(redaction.UUID)

		CATransaction.begin()
		CATransaction.setDisableActions(true)

		let layer = BoundingBoxLayer()
		boundingBoxes[redaction.UUID] = layer
		addSublayer(layer)

		updateSelections()

		CATransaction.commit()
	}

	private func deselect(redaction: Redaction) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		if let layer = boundingBoxes[redaction.UUID] {
			layer.removeFromSuperlayer()
		}
		boundingBoxes.removeValueForKey(redaction.UUID)
		selectedUUIDs.remove(redaction.UUID)

		CATransaction.commit()
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
				var rect = redaction.rectForBounds(imageRect).flippedInRect(bounds)
				rect.inset(dx: -2, dy: -2)
				layer.frame = rect
			}
		}

		CATransaction.commit()

		NSNotificationCenter.defaultCenter().postNotificationName(RedactedView.selectionDidChangeNotificationName, object: self)
	}
}
