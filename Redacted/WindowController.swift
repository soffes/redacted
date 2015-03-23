//
//  WindowController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

	// MARK: - Properties

	@IBOutlet var shareItem: NSToolbarItem!
	var editorViewController: EditorViewController!


	// MARK: - NSWindowController

	override func windowDidLoad() {
		super.windowDidLoad()

		editorViewController = contentViewController as? EditorViewController

		if let button = shareItem.view as? NSButton {
			button.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
		}
	}


	// MARK: - Actions

	@IBAction func shareImage(sender: AnyObject?) {
		editorViewController.shareImage(fromView: shareItem.view!)
	}
}
