//
//  Redaction.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public struct Redaction: Hashable, Equatable {
	public let UUID: String
	public var rect: CGRect

	public init(UUID: String = NSUUID().UUIDString, rect: CGRect) {
		self.UUID = UUID
		self.rect = rect
	}

	public var hashValue: Int {
		return UUID.hashValue
	}
}


public func ==(lhs: Redaction, rhs: Redaction) -> Bool {
	return lhs.hashValue == rhs.hashValue
}


public func redact(image ciImage: CIImage, withRedactions redactions: [Redaction]) -> CIImage {
	let extent = ciImage.extent()
	var filters = [CIFilter]()

	for redaction in redactions {
		let rect = CGRect(
			x: redaction.rect.origin.x * extent.size.width,
			y: redaction.rect.origin.y * extent.size.height,
			width: redaction.rect.size.width * extent.size.width,
			height: redaction.rect.size.height * extent.size.width
		).flippedInRect(extent)

		let blur = CIFilter(name: "CIGaussianBlur")!
		blur.setValue(5, forKey: "inputRadius")
		blur.setValue(ciImage, forKey: "inputImage")

		let blurred = blur.outputImage.imageByCroppingToRect(rect)
		filters.append(CIFilter(name: "CISourceOverCompositing", withInputParameters: ["inputImage": blurred]))
	}

	let chain = ChainFilter()
	chain.inputImage = ciImage
	chain.inputFilters = filters
	return chain.outputImage!.imageByCroppingToRect(extent)
}
