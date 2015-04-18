//
//  Colors.swift
//  Redacted
//
//  Created by Sam Soffes on 4/18/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

#if os(iOS)
	import UIKit.UIColor
	typealias Color = UIColor
#else
	import AppKit.NSColor
	typealias Color = NSColor

	extension NSColor {
		convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
			self.init(SRGBRed: red, green: green, blue: blue, alpha: alpha)
		}
	}
#endif

public let blueColor = Color(red:0.298, green:0.757, blue:0.988, alpha: 1)

#if os(iOS)
	public let selectionColor = blueColor
#else
	public let selectionColor = NSColor.selectedControlColor()
#endif