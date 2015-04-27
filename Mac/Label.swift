//
//  Label.swift
//  Redacted
//
//  Created by Sam Soffes on 4/26/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

class LabelCell: NSTextFieldCell {

	// MARK: - Properties

	var contentInsets: NSEdgeInsets = NSEdgeInsetsZero {
		didSet {
			controlView?.needsLayout = true
		}
	}


	// MARK: - NSCell

	override func drawingRectForBounds(theRect: NSRect) -> NSRect {
		var rect = super.drawingRectForBounds(theRect)
		rect.origin.x += contentInsets.left
		rect.origin.y += contentInsets.top
		return rect
	}
}


class Label: NSTextField {

	// MARK: - Properties

	var contentInsets: NSEdgeInsets {
		set {
			labelCell?.contentInsets = newValue
		}

		get {
			return labelCell?.contentInsets ?? NSEdgeInsetsZero
		}
	}


	// MARK: - Initializers

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}


	// MARK: - NSView

	override var intrinsicContentSize: NSSize {
		var size = super.intrinsicContentSize
		size.width += contentInsets.left + contentInsets.right
		size.height += contentInsets.top + contentInsets.bottom
		return size
	}


	// MARK: - NSControl

	override class func cellClass() -> AnyClass? {
		return LabelCell.self
	}


	// MARK: - Private

	var labelCell: LabelCell? {
		return cell() as? LabelCell
	}

	private func initialize() {
		if let cell = labelCell {
			cell.editable = false
			cell.drawsBackground = false
			cell.usesSingleLineMode = true
			cell.lineBreakMode = .ByTruncatingTail
			cell.scrollable = false
			cell.enabled = false
			cell.bezeled = false
		}
	}
}
