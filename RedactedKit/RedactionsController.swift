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

open class RedactionsController {

	// MARK: - Properties

	open var redactions = [Redaction]()

	open var image: Image? {
		didSet {
			if let image = image {
				ciImage = CIImage(cgImage: image.cgImage!)
			} else {
				ciImage = nil
			}
		}
	}

	fileprivate var ciImage: CIImage? {
		didSet {
			updateImages()
		}
	}


	// MARK: - Rendering

	open func process() -> CIImage? {
		if let ciImage = ciImage {
			var outputImage = ciImage

			if redactions.count > 0 {
				let chain = ChainFilter()
				chain.inputImage = ciImage
				chain.inputFilters = redactions.map({ $0.filter(ciImage, preprocessor: self.preprocess) })
				outputImage = chain.outputImage!
			}
			
			return outputImage.cropping(to: ciImage.extent)
		}
		return nil
	}


	// MARK: - Private

	fileprivate var pixelatedImage: CIImage?
	fileprivate var blurredImage: CIImage?

	fileprivate func updateImages() {
		if let ciImage = ciImage {
			pixelatedImage = Redaction.preprocess(ciImage, type: .pixelate)
			blurredImage = Redaction.preprocess(ciImage, type: .blur)
		} else {
			pixelatedImage = nil
			blurredImage = nil
		}

	}

	fileprivate func preprocess(_ image: CIImage, type: RedactionType) -> CIImage {
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
