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
	@IBOutlet var placeholderLabel: NSTextField!

	var redactedLayer: RedactedLayer {
		return redactedView.redactedLayer
	}
	
	var image: NSImage? {
		didSet {
			redactedLayer.originalImage = image
			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.imageDidChangeNotification, object: image)

			placeholderLabel.hidden = image != nil
		}
	}

	var renderedImage: NSImage? {
		return redactedLayer.renderedImage()
	}


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let pan = NSPanGestureRecognizer(target: self, action: "panned:")
		view.addGestureRecognizer(pan)

		let click = NSClickGestureRecognizer(target: self, action: "clicked:")
		view.addGestureRecognizer(click)

		let shiftClick = ModifierClickGestureRecognizer(target: self, action: "shiftClicked:")
		shiftClick.modifier = .ShiftKeyMask
		view.addGestureRecognizer(shiftClick)
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
		redactedLayer.drag(point: sender.locationInView(view), state: sender.state)
	}

	func clicked(sender: NSClickGestureRecognizer) {
		if sender.state == .Ended {
			redactedLayer.tap(point: sender.locationInView(view))
		}
	}

	func shiftClicked(sender: NSClickGestureRecognizer) {
		if sender.state == .Ended {
			redactedLayer.tap(point: sender.locationInView(view), exclusive: false)
		}
	}
}
