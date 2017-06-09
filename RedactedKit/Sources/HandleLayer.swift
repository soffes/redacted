//
//  HandleLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 4/4/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import QuartzCore
import X

final class HandleLayer: CAGradientLayer {

	// MARK: - Initializers

	override init() {
		super.init()
		initialize()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	override init(layer: Any) {
		super.init(layer: layer)
		initialize()
	}


	// MARK: - Private

	private func initialize() {
		colors = [
			Color(white: 0.855, alpha: 1).cgColor,
			Color(white: 0.992, alpha: 1).cgColor
		]

		shadowPath = CGPath(rect: CGRect(x: 0, y: 0, width: 6, height: 6), transform: nil)
		shadowOffset = CGSize(width: 0, height: -1)
		shadowRadius = 5
		shadowOpacity = 0.7
		shadowRadius = 1
	}
}
