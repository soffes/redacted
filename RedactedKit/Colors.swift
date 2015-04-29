//
//  Colors.swift
//  Redacted
//
//  Created by Sam Soffes on 4/18/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import X

public let blueColor = Color(red:0.298, green:0.757, blue:0.988, alpha: 1.0)
public let toolTipColor = Color(red: 1.0, green: 0.918, blue: 0.286, alpha: 1.0)
public let toolTipTextColor = Color(red: 0.451, green: 0.302, blue: 0.071, alpha: 1)

#if os(iOS)
	public let selectionColor = blueColor
#else
	import AppKit.NSColor
	public let selectionColor = NSColor.selectedControlColor()
#endif
