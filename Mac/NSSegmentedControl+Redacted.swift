//
//  NSSegmentedControl+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 4/19/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

extension NSSegmentedControl {
	func setToolTip(toolTip: String?, forSegment segment: Int) {
		segmentedCell?.setToolTip(toolTip, forSegment: segment)
	}

	func toolTipForSegment(segment: Int) -> String? {
		return segmentedCell?.toolTip(forSegment: segment)
	}

	var segmentedCell: NSSegmentedCell? {
		return cell as? NSSegmentedCell
	}
}
