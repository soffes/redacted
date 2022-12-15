import CoreImage

final class ChainFilter: CIFilter {

	var inputImage: CIImage?
	var inputFilters: [CIFilter]?

	override var outputImage: CIImage? {
		if var image = inputImage, let filters = inputFilters {
			for filter in filters {
				filter.setValue(image, forKey: "inputBackgroundImage")

                if let output = filter.outputImage {
                    image = output
                } else {
                    assertionFailure("Failed to get output of filter: \(filter)")
                }
			}

			return image
		}

		return nil
	}
}
