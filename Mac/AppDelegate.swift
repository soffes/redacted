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


	// MARK: - Actions

	@IBAction func showHelp(sender: AnyObject?) {
		NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://useredacted.com/help")!)
	}


	// MARK: - Private

	private var windowController: EditorWindowController? {
		return NSApplication.sharedApplication().windows.first?.windowController() as? EditorWindowController
	}

	@objc private func modeDidChange(notification: NSNotification?) {
		if let layer = notification?.object as? RedactedLayer {
			updateMode(layer)
		}
	}

	private func updateMode(layer: RedactedLayer) {
		pixelateMenuItem.state = layer.mode == .Pixelate ? NSOnState : NSOffState
		blurMenuItem.state = layer.mode == .Blur ? NSOnState : NSOffState
		blackBarMenuItem.state = layer.mode == .BlackBar ? NSOnState : NSOffState
	}

	@objc private func selectionDidChange(notification: NSNotification?) {
		if let layer = notification?.object as? RedactedLayer {
			deleteMenuItem.title = layer.selectionCount == 1 ? string("DELETE_REDACTION") : string("DELETE_REDACTIONS")
		}
	}
}


extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(notification: NSNotification) {
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

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectionDidChange:", name: RedactedLayer.selectionDidChangeNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "modeDidChange:", name: RedactedLayer.modeDidChangeNotificationName, object: nil)

		if let layer = windowController?.editorViewController.redactedLayer {
			updateMode(layer)
		}
	}

	func application(sender: NSApplication, openFile filename: String) -> Bool {
		if let windowController = windowController {
			return windowController.openURL(NSURL(fileURLWithPath: filename))
		}
		return false
	}
}