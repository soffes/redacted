//
//  AppDelegate.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

@NSApplicationMain class AppDelegate: NSObject {

	// MARK: - Properties

	@IBOutlet var exportMenuItem: NSMenuItem!
	@IBOutlet var copyMenuItem: NSMenuItem!
	@IBOutlet var pasteMenuItem: NSMenuItem!
	@IBOutlet var deleteMenuItem: NSMenuItem!
	@IBOutlet var selectAllMenuItem: NSMenuItem!
	@IBOutlet var pixelateMenuItem: NSMenuItem!
	@IBOutlet var blurMenuItem: NSMenuItem!
	@IBOutlet var clearMenuItem: NSMenuItem!

	// MARK: - Actions

	@IBAction func showHelp(sender: AnyObject?) {
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://useredacted.com/help")!)
	}
}


extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(notification: NSNotification) {
		exportMenuItem.title = string("EXPORT_IMAGE")
		copyMenuItem.title = string("COPY_IMAGE")
		pasteMenuItem.title = string("PASTE_IMAGE")
		deleteMenuItem.title = string("DELETE_REDACTION")
		selectAllMenuItem.title = string("SELECT_ALL_REDACTIONS")
		pixelateMenuItem.title = string("PIXELATE")
		blurMenuItem.title = string("BLUR")
		clearMenuItem.title = string("CLEAR_IMAGE")
	}

	func application(sender: NSApplication, openFile filename: String) -> Bool {
		let windowController = NSApplication.sharedApplication().windows.first?.windowController() as? EditorWindowController
		if let windowController = windowController {
			return windowController.openURL(NSURL(fileURLWithPath: filename))
		}
		return false
	}
}