//
//  Redaction.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public enum RedactionType: Int, Printable {
	case Pixelate, Blur

	public var description: String {
		switch self {
		case .Pixelate:
			return "pixelate"
		case .Blur:
			return "blur"
		}
	}
}

public struct Redaction: Hashable, Equatable {

	public let UUID: String
	public let type: RedactionType
	public var rect: CGRect

	public init(UUID: String = NSUUID().UUIDString, type: RedactionType, rect: CGRect) {
		self.UUID = UUID
		self.type = type
		self.rect = rect
	}

	public var hashValue: Int {
		return UUID.hashValue
	}

	public func filter(image: CIImage) -> CIFilter {
		let extent = image.extent()
		let scaledRect = CGRect(
			x: rect.origin.x * extent.size.width,
			y: rect.origin.y * extent.size.height,
			width: rect.size.width * extent.size.width,
			height: rect.size.height * extent.size.height
		).flippedInRect(extent)

		let edge = max(extent.size.width, extent.size.height)

		let processed: CIImage

		switch type {
		case .Pixelate:
			processed = CIFilter(name: "CIPixellate", withInputParameters: [
				"inputScale": edge * 0.015,
				"inputCenter": CIVector(CGPoint: extent.center),
				"inputImage": image
			])!.outputImage

		case .Blur:
			let clamp = CIFilter(name: "CIAffineClamp", withInputParameters: [
				"inputTransform": NSAffineTransform(),
				"inputImage": image
			])

			processed = CIFilter(name: "CIGaussianBlur", withInputParameters: [
				"inputRadius": edge * 0.015,
				"inputImage": clamp.outputImage
			])!.outputImage
		}

		return CIFilter(name: "CISourceOverCompositing", withInputParameters: [
			"inputImage": processed.imageByCroppingToRect(scaledRect)
		])
	}
}


public func ==(lhs: Redaction, rhs: Redaction) -> Bool {
	return lhs.hashValue == rhs.hashValue
}


public func redact(image ciImage: CIImage, withRedactions redactions: [Redaction]) -> CIImage {
	let chain = ChainFilter()
	chain.inputImage = ciImage
	chain.inputFilters = redactions.map({ $0.filter(ciImage) })
	return chain.outputImage!.imageByCroppingToRect(ciImage.extent())
}
