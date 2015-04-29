//
//  RedactionController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/11/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

#if os(iOS)
	import CoreImage
#else
	import QuartzCore
#endif

public class RedactionsController {

	// MARK: - Properties

	public var redactions = [Redaction]()

	public var image: Image? {
		didSet {
			if let image = image {
				ciImage = CIImage(CGImage: image.CGImage)
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
				chain.inputFilters = redactions.map({ $0.filter(ciImage, preprocessor: self.preprocess) })
				outputImage = chain.outputImage!
			}
			
			return outputImage.imageByCroppingToRect(ciImage.extent())
		}
		return nil
	}


	// MARK: - Private

	private var pixelatedImage: CIImage?
	private var blurredImage: CIImage?

	private func updateImages() {
		if let ciImage = ciImage {
			pixelatedImage = Redaction.preprocess(ciImage, type: .Pixelate)
			blurredImage = Redaction.preprocess(ciImage, type: .Blur)
		} else {
			pixelatedImage = nil
			blurredImage = nil
		}

	}

	private func preprocess(image: CIImage, type: RedactionType) -> CIImage {
		switch type {
		case .Pixelate:
			return pixelatedImage!
		case .Blur:
			return blurredImage!
		default:
			return Redaction.preprocess(image, type: type)
		}
	}
}
