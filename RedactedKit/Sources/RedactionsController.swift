//
//  RedactionController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/11/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import X

#if os(iOS)
	import CoreImage
#else
	import QuartzCore
#endif

public final class RedactionsController {

	// MARK: - Properties

	public var redactions = [Redaction]()

	public  var image: Image? {
		didSet {
			if let image = image {
				#if os(OSX)
					ciImage = CIImage(cgImage: image.cgImage!)
				#else
					var img = CIImage(cgImage: image.cgImage!)
					img = img.applying(CGAffineTransform(scaleX: 1, y: -1).concatenating(CGAffineTransform(translationX: 0, y: img.extent.height)))

					switch image.imageOrientation {
					case .up:
						break

					case .down:
						img = img.applying(CGAffineTransform(rotationAngle: .pi))

					case .left:
						img = img.applying(CGAffineTransform(rotationAngle: .pi / -2))

					case .right:
						img = img.applying(CGAffineTransform(rotationAngle: .pi / 2))

					case .upMirrored:
						img = img.applying(CGAffineTransform(scaleX: -1, y: 1).concatenating(CGAffineTransform(translationX: img.extent.width, y: 0)))

					case .downMirrored:
						img = img.applying(CGAffineTransform(rotationAngle: .pi))
						img = img.applying(CGAffineTransform(scaleX: -1, y: 1).concatenating(CGAffineTransform(translationX: img.extent.width, y: 0)))

					case .leftMirrored:
						img = img.applying(CGAffineTransform(rotationAngle: .pi / -2))
						img = img.applying(CGAffineTransform(scaleX: -1, y: 1).concatenating(CGAffineTransform(translationX: img.extent.width, y: 0)))
						
					case .rightMirrored:
						img = img.applying(CGAffineTransform(rotationAngle: .pi / 2))
						img = img.applying(CGAffineTransform(scaleX: -1, y: 1).concatenating(CGAffineTransform(translationX: img.extent.width, y: 0)))
					}

					ciImage = img
				#endif
			} else {
				ciImage = nil
			}
		}
	}

	private var ciImage: CIImage? {
		didSet {
			updateImages()
		}
	}


	// MARK: - Rendering

	public func process() -> CIImage? {
		if let ciImage = ciImage {
			var outputImage = ciImage

			if redactions.count > 0 {
				let chain = ChainFilter()
				chain.inputImage = ciImage
				chain.inputFilters = redactions.map({ $0.filter(ciImage, preprocessor: preprocess) })
				outputImage = chain.outputImage!
			}
			
			return outputImage.cropping(to: ciImage.extent)
		}
		return nil
	}


	// MARK: - Private

	private var pixelatedImage: CIImage?
	private var blurredImage: CIImage?

	private func updateImages() {
		if let ciImage = ciImage {
			pixelatedImage = Redaction.preprocess(ciImage, type: .pixelate)
			blurredImage = Redaction.preprocess(ciImage, type: .blur)
		} else {
			pixelatedImage = nil
			blurredImage = nil
		}

	}

	private func preprocess(_ image: CIImage, type: RedactionType) -> CIImage {
		switch type {
		case .pixelate:
			return pixelatedImage!
		case .blur:
			return blurredImage!
		default:
			return Redaction.preprocess(image, type: type)
		}
	}
}
