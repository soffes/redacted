//
//  Colors.swift
//  Redacted
//
//  Created by Sam Soffes on 4/18/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

#if os(iOS)
	import UIKit.UIColor
	public typealias Color = UIColor
#else
	import AppKit.NSColor
	public typealias Color = NSColor

	extension NSColor {
		convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
			self.init(SRGBRed: red, green: green, blue: blue, alpha: alpha)
		}
	}
#endif

public let blueColor = Color(red:0.298, green:0.757, blue:0.988, alpha: 1.0)
public let toolTipColor = Color(red: 1.0, green: 0.918, blue: 0.286, alpha: 1.0)
public let toolTipTextColor = Color(red: 0.451, green: 0.302, blue: 0.071, alpha: 1)

#if os(iOS)
	public let selectionColor = blueColor
#else
	public let selectionColor = NSColor.selectedControlColor()
#endif
