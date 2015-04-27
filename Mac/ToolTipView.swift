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

	private let shadowLayer: CALayer = {
		let layer = CALayer()
		layer.shadowColor = Color.blackColor().CGColor
		layer.shadowOffset = CGSizeZero
		layer.shadowRadius = 8
		layer.shadowOpacity = 1
		return layer
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


	// MARK: - NSView

	override func layout() {
		super.layout()

		if let layer = textLabel.layer {
			shadowLayer.frame = layer.frame

			var rect = shadowLayer.bounds
			rect.inset(dx: 8, dy: 8)

			shadowLayer.shadowPath = NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10).CGPath
		}
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true
		layer?.addSublayer(shadowLayer)
		addSubview(textLabel)

		let views = [ "textLabel": textLabel ]
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-8-[textLabel]-8-|", options: nil, metrics: nil, views: views))
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[textLabel]-8-|", options: nil, metrics: nil, views: views))
	}
}
