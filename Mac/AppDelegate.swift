//
//  AppDelegate.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa

@NSApplicationMain class AppDelegate: NSObject, NSApplicationDelegate {
	func application(sender: NSApplication, openFile filename: String) -> Bool {
		let windowController = NSApplication.sharedApplication().windows.first?.windowController() as? EditorWindowController
		if let windowController = windowController {
			return windowController.openURL(NSURL(fileURLWithPath: filename))
		}
		return false
	}
}
