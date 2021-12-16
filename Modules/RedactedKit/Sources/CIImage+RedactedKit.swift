import X

#if os(iOS)
import CoreImage
#else
import QuartzCore
#endif

extension CIImage {
	public var renderedImage: Image {
		let image = self

		let colorSpace = CGColorSpaceCreateDeviceRGB()
        let options: [CIContextOption: Any] = [
			.workingColorSpace: colorSpace,
			.outputColorSpace: colorSpace
        ]

		let extent = image.extent

		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let cgContext = CGContext(
			data: nil,
			width: Int(extent.width),
			height: Int(extent.height),
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: bitmapInfo.rawValue,
			releaseCallback: nil,
			releaseInfo: nil
		)!
		let ciContext = CIContext(cgContext: cgContext, options: options)

		let cgImage = ciContext.createCGImage(image, from: extent)!

#if os(iOS)
        return Image(cgImage: cgImage)
#else
        return Image(cgImage: cgImage)!
#endif
	}
}
