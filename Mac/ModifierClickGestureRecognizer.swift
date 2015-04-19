//
//  ModifierClickGestureRecognizer.swift
//  Redacted
//
//  Created by Sam Soffes on 4/3/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

class ModifierClickGestureRecognizer: NSClickGestureRecognizer {
	var modifier: NSEventModifierFlags?

	override func mouseDown(event: NSEvent) {
		if let modifier = modifier {
			if event.modifierFlags & modifier != nil {
				super.mouseDown(event)
			}
			return
		}

		super.mouseDown(event)
	}
}
