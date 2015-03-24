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

	// MARK: - Properties

	@IBOutlet var redactedView: RedactedView!

	var mode: RedactionType = .Pixelate {
		didSet {
			println("Mode: \(mode)")
		}
	}

	var image: NSImage? {
		didSet {
			redactedView.originalImage = image
			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.imageDidChangeNotification, object: image)
		}
	}

	class var imageDidChangeNotification: String {
		return "EditorViewController.imageDidChangeNotification"
	}

	private var startPoint: CGPoint = CGPointZero

	var renderedImage: NSImage? {
		if let ciImage = redactedView.originalCIImage {
			return redact(image: ciImage, withRedactions: redactedView.redactions).renderedImage
		}
		return nil
	}


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let pan = NSPanGestureRecognizer(target: self, action: "panned:")
		view.addGestureRecognizer(pan)

		if let view = view as? ImageDragDestinationView {
			view.delegate = self
		}
		
		redactedView.redactions = [
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
		let bounds = redactedView.imageRect
		var point = sender.locationInView(view)

		point = point.flippedInRect(bounds)
		point.x -= bounds.origin.x
		point.y -= bounds.origin.y

		if sender.state == .Began {
			startPoint = point
		}

		let rect = CGRect(
			x: startPoint.x / bounds.size.width,
			y: startPoint.y / bounds.size.height,
			width: (point.x / bounds.size.width) - (startPoint.x / bounds.size.width),
			height: (point.y / bounds.size.height) - (startPoint.y / bounds.size.height)
		)

		redactedView.redactions = [
			Redaction(type: mode, rect: rect),
		]
	}
}


extension EditorViewController: ImageDragDestinationViewDelegate {
	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptImage image: NSImage) {
		self.image = image
	}
}
