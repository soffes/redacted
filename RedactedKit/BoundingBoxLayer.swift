//
//  BoundingBoxLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 4/4/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import QuartzCore

class BoundingBoxLayer: CALayer {

	// MARK: - Properties

	let border = CALayer()
//	let topLeft = HandleLayer()
//	let topCenter = HandleLayer()
//	let topRight = HandleLayer()
//	let middleLeft = HandleLayer()
//	let middleRight = HandleLayer()
//	let bottomLeft = HandleLayer()
//	let bottomCenter = HandleLayer()
//	let bottomRight = HandleLayer()


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


	// MARK: - CALayer

	override func layoutSublayers() {
		super.layoutSublayers()

		CATransaction.begin()
		CATransaction.setDisableActions(true)

		border.frame = bounds

//		topLeft.frame = CGRect(x: bounds.minX - 3, y: bounds.maxY - 3, width: 6, height: 6)
//		topCenter.frame = CGRect(x: bounds.midX - 3, y: bounds.maxY - 3, width: 6, height: 6)
//		topRight.frame = CGRect(x: bounds.maxX - 3, y: bounds.maxY - 3, width: 6, height: 6)
//
//		middleLeft.frame = CGRect(x: bounds.minX - 3, y: bounds.midY - 3, width: 6, height: 6)
//		middleRight.frame = CGRect(x: bounds.maxX - 3, y: bounds.midY - 3, width: 6, height: 6)
//
//		bottomLeft.frame = CGRect(x: bounds.minX - 3, y: bounds.minY - 3, width: 6, height: 6)
//		bottomCenter.frame = CGRect(x: bounds.midX - 3, y: bounds.minY - 3, width: 6, height: 6)
//		bottomRight.frame = CGRect(x: bounds.maxX - 3, y: bounds.minY - 3, width: 6, height: 6)

		CATransaction.commit()
	}


	// MARK: - Private

	private func initialize() {
		border.borderWidth = 1
		border.borderColor = CGColorCreateGenericRGB(0.788, 0.788, 0.788, 1)
		addSublayer(border)
		
//		addSublayer(topLeft)
//		addSublayer(topCenter)
//		addSublayer(topRight)
//
//		addSublayer(middleLeft)
//		addSublayer(middleRight)
//
//		addSublayer(bottomLeft)
//		addSublayer(bottomCenter)
//		addSublayer(bottomRight)
	}
}
