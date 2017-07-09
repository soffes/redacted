//
//  ImageActivityItemProvider.swift
//  Redacted
//
//  Created by Sam Soffes on 7/9/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit

final class ImageActivityItemProvider: UIActivityItemProvider {

	// MARK: - Properties

	private var originalImage: UIImage
	private var redactions: [Redaction]


	// MARK: - Initializers

	init(originalImage: UIImage, redactions: [Redaction]) {
		self.originalImage = originalImage
		self.redactions = redactions
		super.init(placeholderItem: UIImage())
	}


	// MARK: - UIActivityItemProvider

	override var item: Any {
		let controller = RedactionsController()
		controller.image = originalImage
		controller.redactions = redactions
		return controller.process()?.renderedImage ?? originalImage
	}
}
