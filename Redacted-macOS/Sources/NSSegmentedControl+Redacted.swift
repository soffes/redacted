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
