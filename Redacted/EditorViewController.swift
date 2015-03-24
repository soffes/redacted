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


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let image = NSImage(named: "test")!
		redactedView.image = image

		let pan = NSPanGestureRecognizer(target: self, action: "panned:")
		view.addGestureRecognizer(pan)

		redactedView.redactions = [
			Redaction(type: .Pixelate, rect: CGRectMake(0.1, 0.1, 0.3, 0.5)),
			Redaction(type: .Blur, rect: CGRectMake(0.7, 0.3, 0.2, 0.2))
		]
	}


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
