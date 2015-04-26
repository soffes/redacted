//
//  ToolTipView.swift
//  Redacted
//
//  Created by Sam Soffes on 4/19/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import RedactedKit

class ToolTipView: NSView {

	// MARK: - Properties

	let textLabel: NSTextField = {
		let label = NSTextField()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = toolTipTextColor
		return label
	}()

	// MARK: - Initializers

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true

		if let layer = layer {
			layer.backgroundColor = toolTipColor.CGColor
			layer.cornerRadius = 10
			layer.shadowColor = Color.blackColor().CGColor
			layer.shadowOffset = CGSize(width: 16, height: 16)
			layer.shadowOpacity = 0.5
		}

		addSubview(textLabel)

		let padding: CGFloat = 0
		addConstraints([
			NSLayoutConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: padding),
			NSLayoutConstraint(item: textLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0),
			NSLayoutConstraint(item: textLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: padding)
		])
	}
}
