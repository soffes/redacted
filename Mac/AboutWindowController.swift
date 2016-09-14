//
//  AboutWindowController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/7/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

class AboutWindowController: NSWindowController {

	// MARK: - NSResponder

	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)

		// Support ⌘W
		if (event.characters ?? "") == "w" && event.modifierFlags.contains(.command) {
			close()
		}
	}


	// MARK: - NSWindowController

	override func showWindow(_ sender: Any?) {
		window?.center()
		super.showWindow(sender)
	}
}
