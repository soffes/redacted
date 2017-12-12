//
//  PasteboardType+Redacted.swift
//  Redacted-macOS
//
//  Created by Sam Soffes on 12/11/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import AppKit

extension NSPasteboard.PasteboardType {
	static let filenames: NSPasteboard.PasteboardType = {
		// #yolo
		return NSPasteboard.PasteboardType("NSFilenamesPboardType")
	} ()
}
