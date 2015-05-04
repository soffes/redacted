//
//  AppDelegate.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import IOKit
import RedactedKit
import Mixpanel

let mixpanel = Mixpanel(token: "8a64b11c12312da3bead981a4ad7e30b")

@NSApplicationMain class AppDelegate: NSObject {

	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - Properties

	@IBOutlet var exportMenuItem: NSMenuItem!
	@IBOutlet var copyMenuItem: NSMenuItem!
	@IBOutlet var pasteMenuItem: NSMenuItem!
	@IBOutlet var deleteMenuItem: NSMenuItem!
	@IBOutlet var selectAllMenuItem: NSMenuItem!
	@IBOutlet var modeMenuItem: NSMenuItem!
	@IBOutlet var pixelateMenuItem: NSMenuItem!
	@IBOutlet var blurMenuItem: NSMenuItem!
	@IBOutlet var blackBarMenuItem: NSMenuItem!
	@IBOutlet var clearMenuItem: NSMenuItem!

	var uniqueIdentifier: String {
		let key = "Identifier"
		if let identifier = NSUserDefaults.standardUserDefaults().stringForKey(key) {
			return identifier
		}

		let identifier = NSUUID().UUIDString
		NSUserDefaults.standardUserDefaults().setObject(identifier, forKey: key)
		return identifier
	}


	// MARK: - Actions

	@IBAction func showHelp(sender: AnyObject?) {
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://useredacted.com/help")!)
	}


	// MARK: - Private

	private var windowController: EditorWindowController? {
		return NSApplication.sharedApplication().windows.first?.windowController() as? EditorWindowController
	}

	@objc private func modeDidChange(notification: NSNotification?) {
		if let view = notification?.object as? RedactedView {
			updateMode(view)
		}
	}

	private func updateMode(view: RedactedView) {
		let mode = view.mode
		pixelateMenuItem.state = mode == .Pixelate ? NSOnState : NSOffState
		blurMenuItem.state = mode == .Blur ? NSOnState : NSOffState
		blackBarMenuItem.state = mode == .BlackBar ? NSOnState : NSOffState
	}

	@objc private func selectionDidChange(notification: NSNotification?) {
		if let view = notification?.object as? RedactedView {
			deleteMenuItem.title = view.selectionCount == 1 ? string("DELETE_REDACTION") : string("DELETE_REDACTIONS")
		}
	}
}


extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(notification: NSNotification) {
		#if DEBUG
			mixpanel.enabled = false
			println("Mixpanel disabled")
		#endif

		mixpanel.identify(uniqueIdentifier)
		mixpanel.track("Launch")

		exportMenuItem.title = string("EXPORT_IMAGE")
		copyMenuItem.title = string("COPY_IMAGE")
		pasteMenuItem.title = string("PASTE_IMAGE")
		deleteMenuItem.title = string("DELETE_REDACTION")
		selectAllMenuItem.title = string("SELECT_ALL_REDACTIONS")
		modeMenuItem.title = string("MODE")
		pixelateMenuItem.title = string("PIXELATE")
		blurMenuItem.title = string("BLUR")
		blackBarMenuItem.title = string("BLACK_BAR")
		clearMenuItem.title = string("CLEAR_IMAGE")

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectionDidChange:", name: RedactedView.selectionDidChangeNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "modeDidChange:", name: RedactedView.modeDidChangeNotificationName, object: nil)

		if let view = windowController?.editorViewController.redactedView {
			updateMode(view)
		}
	}

	func application(sender: NSApplication, openFile filename: String) -> Bool {
		if let windowController = windowController {
			return windowController.openURL(NSURL(fileURLWithPath: filename), source: "App icon")
		}
		return false
	}
}
