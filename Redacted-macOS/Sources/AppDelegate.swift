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

var mixpanel = Mixpanel(token: "8a64b11c12312da3bead981a4ad7e30b")

@NSApplicationMain final class AppDelegate: NSObject {

	// MARK: - Initializers

	deinit {
		NotificationCenter.default.removeObserver(self)
	}


	// MARK: - Properties

	@IBOutlet var saveMenuItem: NSMenuItem!
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

	fileprivate var uniqueIdentifier: String {
		let key = "Identifier"
		if let identifier = UserDefaults.standard.string(forKey: key) {
			return identifier
		}

		let identifier = UUID().uuidString
		UserDefaults.standard.set(identifier, forKey: key)
		return identifier
	}


	// MARK: - Actions

	@IBAction func showHelp(_ sender: Any?) {
		NSWorkspace.shared.open(URL(string: "http://useredacted.com/help")!)
	}


	// MARK: - Private

	fileprivate var windowController: EditorWindowController? {
		return NSApplication.shared.windows.first?.windowController as? EditorWindowController
	}

	@objc fileprivate func modeDidChange(notification: NSNotification?) {
		if let view = notification?.object as? RedactedView {
			updateMode(view: view)
		}
	}

	fileprivate func updateMode(view: RedactedView) {
		let mode = view.mode
		pixelateMenuItem.state = mode == .pixelate ? .on : .off
		blurMenuItem.state = mode == .blur ? .on : .off
		blackBarMenuItem.state = mode == .blackBar ? .on : .off
	}

	@objc fileprivate func selectionDidChange(notification: NSNotification?) {
		if let view = notification?.object as? RedactedView {
			deleteMenuItem.title = view.selectionCount == 1 ? string("DELETE_REDACTION") : string("DELETE_REDACTIONS")
		}
	}
}


extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		#if DEBUG
			mixpanel.enabled = false
		#endif

		mixpanel.identify(identifier: uniqueIdentifier)
		mixpanel.track(event: "Launch")

		saveMenuItem.title = string("SAVE")
		exportMenuItem.title = string("EXPORT")
		copyMenuItem.title = string("COPY_IMAGE")
		pasteMenuItem.title = string("PASTE_IMAGE")
		deleteMenuItem.title = string("DELETE_REDACTION")
		selectAllMenuItem.title = string("SELECT_ALL_REDACTIONS")
		modeMenuItem.title = string("MODE")
		pixelateMenuItem.title = string("PIXELATE")
		blurMenuItem.title = string("BLUR")
		blackBarMenuItem.title = string("BLACK_BAR")
		clearMenuItem.title = string("CLEAR_IMAGE")

		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(selectionDidChange), name: NSNotification.Name(rawValue: RedactedView.selectionDidChangeNotificationName), object: nil)
		center.addObserver(self, selector: #selector(modeDidChange), name: NSNotification.Name(rawValue: RedactedView.modeDidChangeNotificationName), object: nil)

		if let view = windowController?.editorViewController.redactedView {
			updateMode(view: view)
		}
	}

	func application(_ sender: NSApplication, openFile filename: String) -> Bool {
		if let windowController = windowController {
			return windowController.open(url: URL(fileURLWithPath: filename), source: "App icon")
		}
		return false
	}
}
