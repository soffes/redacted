#if os(iOS)
	import CoreImage
#else
	import QuartzCore
#endif

final class ChainFilter: CIFilter {

	var inputImage: CIImage?
	var inputFilters: [CIFilter]?

	override var outputImage: CIImage? {
		if var image = inputImage, let filters = inputFilters {
			for filter in filters {
				filter.setValue(image, forKey: "inputBackgroundImage")
				image = filter.value(forKey: "outputImage") as! CIImage
			}
			return image
		}
		return nil
	}
}
