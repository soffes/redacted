//
//  AboutWindowController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/7/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

	// MARK: - NSResponder

	override func keyDown(theEvent: NSEvent) {
		super.keyDown(theEvent)

		// Support ⌘W
		if (theEvent.characters ?? "") == "w" && (theEvent.modifierFlags & .CommandKeyMask) == .CommandKeyMask {
			close()
		}
	}


	// MARK: - NSWindowController

	override func showWindow(sender: AnyObject?) {
		window?.center()
		super.showWindow(sender)
	}
}
