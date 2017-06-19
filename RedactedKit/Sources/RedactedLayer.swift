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

final class RedactedLayer: CoreImageLayer {

	// MARK: - Types

	enum DraggingMode {
		case creating(uuid: String, startPoint: CGPoint)
		case moving(uuid: String, rect: CGRect, startPoint: CGPoint)
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

	var mode: RedactionType = .pixelate {
		didSet {
			NotificationCenter.default.post(name: Notification.Name(rawValue: RedactedView.modeDidChangeNotificationName), object: self)
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
		let allUUIDs = redactions.map({ $0.uuid })
		for UUID in selectedUUIDs {
			if let index = allUUIDs.index(of: UUID) {
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

	var undoManager: UndoManager?


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

	func tap(point: CGPoint, exclusive: Bool = true) {
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

	func drag(point: CGPoint, state: GestureRecognizerState) {
		if image == nil {
			return
		}
		
		let point = converPointToUnits(point)

		// Begin
		if state == .began {
			deselectAll()

			// Start moving
			if let redaction = hitTestRedaction(point) {
				draggingMode = .moving(uuid: redaction.uuid, rect: redaction.rect, startPoint: point)
				select(redaction)
			}

			// Start creating
			else {
				let redaction = Redaction(type: mode, rect: CGRect(origin: point, size: CGSize.zero))
				draggingMode = .creating(uuid: redaction.uuid, startPoint: redaction.rect.origin)
				redactions.append(redaction)
				select(redaction)
			}
		}

		// Continue
		if let draggingMode = draggingMode {
			switch draggingMode {
			case let .creating(uuid, startPoint):
				// Find the currently dragging redaction
				if let index = redactions.map({ $0.uuid }).index(of: uuid) {
					var redaction = redactions[index]
					
					redaction.rect = CGRect(
						x: min(point.x, startPoint.x),
						y: min(point.y, startPoint.y),
						width: max(point.x, startPoint.x) - min(point.x, startPoint.x),
						height: max(point.y, startPoint.y) - min(point.y, startPoint.y)
					)

					redactions[index] = redaction

					// Finished dragging
					if state == .ended {
						redactions.remove(at: index)
						insertRedactions([redaction])
					}
				}

			case let .moving(UUID, rect, startPoint):
				// Find the currently dragging redaction
				if let index = redactions.map({ $0.uuid }).index(of: UUID) {
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
		if state == .ended {
			draggingMode = nil
		}
	}


	// MARK: - Selection

	func selectAll() {
		for redaction in redactions {
			select(redaction)
		}
	}

	var selectionCount: Int {
		return selectedUUIDs.count
	}

	func rect(for redaction: Redaction) -> CGRect {
		return redaction.rectForBounds(imageRect).flippedInRect(bounds)
	}


	// MARK: - Private

	private func converPointToUnits(_ point: CGPoint) -> CGPoint {
		let rect = imageRect
		var point = point.flippedInRect(bounds)
		point.x = (point.x - rect.origin.x) / rect.size.width
		point.y = (point.y - rect.origin.y) / rect.size.height
		return point
	}

	private func hitTestRedaction(_ point: CGPoint) -> Redaction? {
		for redaction in redactions.reversed() {
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

	@objc private func insertRedactionDictionaries(_ dictionaries: [[String: Any]]) {
		let array = dictionaries.map({ Redaction(dictionary: $0) }).filter({ $0 != nil }).map({ $0! })
		insertRedactions(array)
	}

	@objc private func removeRedactionDictionaries(_ dictionaries: [[String: Any]]) {
		let array = dictionaries.map({ Redaction(dictionary: $0) }).filter({ $0 != nil }).map({ $0! })
		removeRedactions(array)
	}

	private func insertRedactions(_ redactions: [Redaction]) {
		self.redactions += redactions

		if !(undoManager?.isUndoing ?? false) {
			let s = redactions.count == 1 ? "" : "S"
			undoManager?.setActionName(string("INSERT_REDACTION\(s)"))
		}
		undoManager?.registerUndo(withTarget: self, selector: #selector(RedactedLayer.removeRedactionDictionaries(_:)), object: redactions.map({ $0.dictionaryRepresentation }))
	}

	private func removeRedactions(_ redactions: [Redaction]) {
		for UUID in redactions.map({ $0.uuid }) {
			if let index = self.redactions.map({ $0.uuid }).index(of: UUID) {
				let redaction = self.redactions[index]
				deselect(redaction)
				self.redactions.remove(at: index)
			}
		}

		if !(undoManager?.isUndoing ?? false) {
			let s = redactions.count == 1 ? "" : "S"
			undoManager?.setActionName(string("DELETE_REDACTION\(s)"))
		}
		undoManager?.registerUndo(withTarget: self, selector: #selector(RedactedLayer.insertRedactionDictionaries(_:)), object: redactions.map({ $0.dictionaryRepresentation }))
	}

	private func isSelected(_ redaction: Redaction) -> Bool {
		return selectedUUIDs.contains(redaction.uuid)
	}

	private func select(_ redaction: Redaction) {
		if isSelected(redaction) {
			return
		}

		selectedUUIDs.insert(redaction.uuid)

		CATransaction.begin()
		CATransaction.setDisableActions(true)

		let layer = BoundingBoxLayer()
		boundingBoxes[redaction.uuid] = layer
		addSublayer(layer)

		updateSelections()

		CATransaction.commit()
	}

	private func deselect(_ redaction: Redaction) {
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		if let layer = boundingBoxes[redaction.uuid] {
			layer.removeFromSuperlayer()
		}
		boundingBoxes.removeValue(forKey: redaction.uuid)
		selectedUUIDs.remove(redaction.uuid)

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
			if let layer = boundingBoxes[redaction.uuid] {
				layer.frame = rect(for: redaction).insetBy(dx: -2, dy: -2)
			}
		}

		CATransaction.commit()

		NotificationCenter.default.post(name: Notification.Name(rawValue: RedactedView.selectionDidChangeNotificationName), object: self)
	}
}
