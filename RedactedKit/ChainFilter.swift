//
//  ChainFilter.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import QuartzCore

public class ChainFilter: CIFilter {

	public var inputImage: CIImage?
	public var inputFilters: [CIFilter]?

	public override var outputImage: CIImage? {
		if var image = inputImage, let filters = inputFilters {
			for filter in filters {
				filter.setValue(image, forKey: "inputBackgroundImage")
				image = filter.valueForKey("outputImage") as! CIImage
			}
			return image
		}
		return nil
	}
}
