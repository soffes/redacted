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
		let windowController = NSApplication.sharedApplication().windows.first?.windowController() as? WindowController
		if let windowController = windowController, image = NSImage(contentsOfFile: filename) {
			windowController.editorViewController.image = image
			return true
		}
		return false
	}
}
