//
//  Redaction.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import CoreGraphics
import X

#if os(iOS)
	import CoreImage
#else
	import QuartzCore
#endif

public typealias Preprocessor = (_ image: CIImage, _ type: RedactionType) -> CIImage

public enum RedactionType: Int, CustomStringConvertible {
	case pixelate, blur, blackBar

	public var description: String {
		switch self {
		case .pixelate:
			return string("PIXELATE")
		case .blur:
			return string("BLUR")
		case .blackBar:
			return string("BLACK_BAR")
		}
	}

	public static var allTypes: [RedactionType] {
		return [.pixelate, .blur, .blackBar]
	}
}

public struct Redaction: Hashable, Equatable {

	public let UUID: String
	public let type: RedactionType
	public var rect: CGRect

	public init(UUID: String = Foundation.UUID().uuidString, type: RedactionType, rect: CGRect) {
		self.UUID = UUID
		self.type = type
		self.rect = rect
	}

	public var hashValue: Int {
		return UUID.hashValue
	}

	public func rectForBounds(_ bounds: CGRect) -> CGRect {
		return CGRect(
			x: bounds.origin.x + (rect.origin.x * bounds.size.width),
			y: bounds.origin.y + (rect.origin.y * bounds.size.height),
			width: rect.size.width * bounds.size.width,
			height: rect.size.height * bounds.size.height
		)
	}

	public func filter(_ image: CIImage, preprocessor: Preprocessor = Redaction.preprocess) -> CIFilter {
		let extent = image.extent
		let scaledRect = rectForBounds(extent).flippedInRect(extent)
		let processed = preprocessor(image, type)

		return CIFilter(name: "CISourceOverCompositing", withInputParameters: [
			"inputImage": processed.cropping(to: scaledRect)
		])!
	}

	public static func preprocess(_ image: CIImage, type: RedactionType) -> CIImage {
		let extent = image.extent
		let edge = max(extent.size.width, extent.size.height)

		switch type {
		case .pixelate:
			return CIFilter(name: "CIPixellate", withInputParameters: [
				"inputScale": edge * 0.01,
				"inputCenter": CIVector(cgPoint: extent.center),
				"inputImage": image
			])!.outputImage!

		case .blur:
			#if os(iOS)
				let transform = NSValue(cgAffineTransform: CGAffineTransform.identity)
			#else
				let transform = NSAffineTransform()
			#endif

			let clamp = CIFilter(name: "CIAffineClamp", withInputParameters: [
				"inputTransform": transform,
				"inputImage": image
			])

			return CIFilter(name: "CIGaussianBlur", withInputParameters: [
				"inputRadius": edge * 0.01,
				"inputImage": clamp!.outputImage!
			])!.outputImage!

		case .blackBar:
			return CIFilter(name: "CIConstantColorGenerator", withInputParameters: [
				"inputColor": CIColor(red: 0, green: 0, blue: 0, alpha: 1)
			])!.outputImage!
		}
	}
}


extension Redaction {
	var dictionaryRepresentation: [String: Any] {
		return [
			"UUID": UUID as Any,
			"type": type.rawValue as Any,
			"rect": rect.stringRepresentation
		]
	}

	init?(dictionary: [String: Any]) {
		if let UUID = dictionary["UUID"] as? String, let typeString = dictionary["type"] as? Int, let type = RedactionType(rawValue: typeString), let rectString = dictionary["rect"] as? String {
			self.UUID = UUID
			self.type = type
			self.rect = CGRect(dictionaryRepresentation: rectString as! CFDictionary)!
			return
		}
		return nil
	}
}


public func ==(lhs: Redaction, rhs: Redaction) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
