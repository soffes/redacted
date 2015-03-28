//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class EditorViewController: NSViewController {

	// MARK: - Constants

	class var imageDidChangeNotification: String {
		return "EditorViewController.imageDidChangeNotification"
	}


	// MARK: - Properties

	@IBOutlet var redactedView: RedactedView!

	var mode: RedactionType = .Pixelate
	
	var image: NSImage? {
		didSet {
			redactedView.redactedLayer.originalImage = image
			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.imageDidChangeNotification, object: image)
		}
	}

	var renderedImage: NSImage? {
		if let ciImage = redactedView.redactedLayer.originalCIImage {
			return redact(image: ciImage, withRedactions: redactedView.redactedLayer.redactions).renderedImage
		}
		return nil
	}

	private var editingUUID: String?


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let pan = NSPanGestureRecognizer(target: self, action: "panned:")
		view.addGestureRecognizer(pan)
		
		redactedView.redactedLayer.redactions = [
			Redaction(type: .Pixelate, rect: CGRectZero),
		]
	}


	// MARK: - Actions

	func shareImage(fromView sender: NSView) {
		if let image = renderedImage {
			let sharingServicePicker = NSSharingServicePicker(items: [image])
			let edge = NSRectEdge(CGRectEdge.MinYEdge.rawValue)
			sharingServicePicker.showRelativeToRect(NSZeroRect, ofView: sender, preferredEdge: edge)
		}
	}

	func panned(sender: NSPanGestureRecognizer) {
		let bounds = redactedView.redactedLayer.imageRect
		var point = sender.locationInView(view)

		// Convert point
		point = point.flippedInRect(bounds)
		point.x = (point.x - bounds.origin.x) / bounds.size.width
		point.y = (point.y - bounds.origin.y) / bounds.size.height

		// Start
		if sender.state == .Began {
			let redaction = Redaction(type: mode, rect: CGRect(origin: point, size: CGSizeZero))
			editingUUID = redaction.UUID
			redactedView.redactedLayer.redactions.append(redaction)
		}

		// Find the currently dragging redaction
		if let editingUUID = editingUUID, index = find(redactedView.redactedLayer.redactions.map({ $0.UUID }), editingUUID) {
			var redaction = redactedView.redactedLayer.redactions[index]
			let startPoint = redaction.rect.origin
			redaction.rect = CGRect(
				x: startPoint.x,
				y: startPoint.y,
				width: point.x - startPoint.x,
				height: point.y - startPoint.y
			)

			redactedView.redactedLayer.redactions[index] = redaction
		}

		// Finished dragging
		if sender.state == .Ended {
			// TODO: Check for too small of a rect
			editingUUID = nil
		}
	}
}
