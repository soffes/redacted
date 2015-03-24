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
			redactedView.image = image
			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.imageDidChangeNotification, object: image)
		}
	}

	class var imageDidChangeNotification: String {
		return "EditorViewController.imageDidChangeNotification"
	}


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let pan = NSPanGestureRecognizer(target: self, action: "panned:")
		view.addGestureRecognizer(pan)

		redactedView.delegate = self
		redactedView.redactions = [
			Redaction(type: .Pixelate, rect: CGRectMake(0.1, 0.1, 0.3, 0.5)),
			Redaction(type: .Blur, rect: CGRectMake(0.7, 0.3, 0.2, 0.2))
		]
	}

//	override func viewDidAppear() {
//		super.viewDidAppear()
//		view.registerForDraggedTypes([NSFilenamesPboardType])
//	}


	// MARK: - Actions

	func shareImage(fromView sender: NSView) {
		// TODO: Get image
		let image = NSImage(named: "test")!

		let sharingServicePicker = NSSharingServicePicker(items: [image])
		let edge = NSRectEdge(CGRectEdge.MinYEdge.rawValue)

		sharingServicePicker.showRelativeToRect(NSZeroRect, ofView: sender, preferredEdge: edge)
	}

	func panned(sender: NSPanGestureRecognizer) {
		if sender.state == .Began {
			println("Start: \(sender.locationInView(view))")
		} else if sender.state == .Ended {
			println("End: \(sender.locationInView(view))")
		}
	}
}


extension EditorViewController: ImageDragDestinationViewDelegate {
	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptImage image: NSImage) {
		self.image = image
	}
}
