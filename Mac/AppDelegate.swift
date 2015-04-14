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

	@IBOutlet var pixelateMenuItem: NSMenuItem!
	@IBOutlet var blurMenuItem: NSMenuItem!

	// MARK: - Actions

	@IBAction func showHelp(sender: AnyObject?) {
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://useredacted.com/help")!)
	}
}


extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(notification: NSNotification) {
		pixelateMenuItem.title = string("PIXELATE")
		blurMenuItem.title = string("BLUR")
	}

	func application(sender: NSApplication, openFile filename: String) -> Bool {
		let windowController = NSApplication.sharedApplication().windows.first?.windowController() as? EditorWindowController
		if let windowController = windowController {
			return windowController.openURL(NSURL(fileURLWithPath: filename))
		}
		return false
	}
}