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

	let textLabel: Label = {
		let label = Label()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = toolTipTextColor
		label.contentInsets = NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		label.wantsLayer = true
		if let layer = label.layer {
			layer.backgroundColor = toolTipColor.CGColor
			layer.cornerRadius = 10
		}

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
		addSubview(textLabel)

		let views = [ "textLabel": textLabel ]
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-8-[textLabel]-8-|", options: nil, metrics: nil, views: views))
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[textLabel]-8-|", options: nil, metrics: nil, views: views))
	}
}
