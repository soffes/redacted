//
//  WindowController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class WindowController: NSWindowController {

	// MARK: - Properties

	@IBOutlet var toolbar: NSToolbar!
	@IBOutlet var shareItem: NSToolbarItem!
	@IBOutlet var modeControl: NSSegmentedControl!

	var editorViewController: EditorViewController!


	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - NSWindowController

	override func windowDidLoad() {
		super.windowDidLoad()

		window?.delegate = self

		editorViewController = contentViewController as? EditorViewController

		// Setup share button
		if let button = shareItem.view as? NSButton {
			button.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
		}

		// Validate toolbar
		validateToolbar()

		// Notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDidChange:", name: EditorViewController.imageDidChangeNotification, object: nil)
	}


	// MARK: - Actions

	@IBAction func changeMode(sender: AnyObject?) {
		if let mode = RedactionType(rawValue: modeControl.integerValue) where editorViewController.mode != mode {
			editorViewController.mode = mode
		}
	}

	@IBAction func clearImage(sender: AnyObject?) {
		editorViewController.image = nil
	}

	@IBAction func shareImage(sender: AnyObject?) {
		editorViewController.shareImage(fromView: shareItem.view!)
	}


	// MARK: - Private

	func imageDidChange(notification: NSNotification?) {
		validateToolbar()
	}
}


extension WindowController: NSWindowDelegate {
	func windowWillClose(notification: NSNotification) {
		NSApplication.sharedApplication().terminate(window)
	}
}


extension WindowController {
	private func validateToolbar() {
		if let items = toolbar.visibleItems as? [NSToolbarItem] {
			for item in items {
				item.enabled = validateToolbarItem(item)
			}
		}
	}

	override func validateToolbarItem(theItem: NSToolbarItem) -> Bool {
		if contains(["mode", "clear", "share"], theItem.itemIdentifier) {
			return editorViewController.image != nil
		}
		return true
	}
}
