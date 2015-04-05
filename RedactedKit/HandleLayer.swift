//
//  HandleLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 4/4/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import QuartzCore

class HandleLayer: CAGradientLayer {

	// MARK: - Initializers

	override init() {
		super.init()
		initialize()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	override init!(layer: AnyObject!) {
		super.init(layer: layer)
		initialize()
	}


	// MARK: - Private

	private func initialize() {
		colors = [
			CGColorCreateGenericRGB(0.855, 0.855, 0.855, 1),
			CGColorCreateGenericRGB(0.992, 0.992, 0.992, 1)
		]

		shadowPath = CGPathCreateWithRect(CGRect(x: 0, y: 0, width: 6, height: 6), nil)
		shadowColor = CGColorCreateGenericRGB(0, 0, 0, 1)
		shadowOffset = CGSize(width: 0, height: -1)
		shadowRadius = 5
		shadowOpacity = 0.7
		shadowRadius = 1
	}
}
