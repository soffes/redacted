//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController {

	// MARK: - Properties

	@IBOutlet var redactedView: RedactedView!


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let image = NSImage(named: "test")!
		self.redactedView.image = image
	}


	// MARK: - Actions

	func shareImage(fromView sender: NSView) {
		// TODO: Get image
		let image = NSImage(named: "test")!

		let sharingServicePicker = NSSharingServicePicker(items: [image])
		let edge = NSRectEdge(CGRectEdge.MinYEdge.rawValue)

		sharingServicePicker.showRelativeToRect(NSZeroRect, ofView: sender, preferredEdge: edge)
	}
}
