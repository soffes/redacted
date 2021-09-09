#if !os(macOS)
import CoreImage
import MetalKit
import UIKit

public class CoreImageView: MTKView {

	// MARK: - Properties

	var ciImage: CIImage? {
		didSet {
			setNeedsDisplay()
		}
	}

	private let ciContext: CIContext
	private let commandQueue: MTLCommandQueue

	// MARK: - Initializers

	public override init(frame: CGRect = .zero, device: MTLDevice? = nil) {
		guard let device = device ?? MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else {
			fatalError("Missing MTLDevice")
		}

		commandQueue = queue

		ciContext = CIContext(mtlDevice: device, options: [
			.workingColorSpace: NSNull()
		])

		super.init(frame: .zero, device: device)

		backgroundColor = .black
		clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
		framebufferOnly = false
		enableSetNeedsDisplay = true
		isPaused = true
	}

	@available(*, unavailable)
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIView

	public override var backgroundColor: UIColor? {
		didSet {
			let color = backgroundColor ?? .black

			var red: CGFloat = 0
			var green: CGFloat = 0
			var blue: CGFloat = 0
			var alpha: CGFloat = 0
			color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

			clearColor = MTLClearColor(red: red, green: green, blue: blue, alpha: alpha)
			setNeedsDisplay()
		}
	}

	public override func draw(_ rect: CGRect) {
		guard let commandBuffer = commandQueue.makeCommandBuffer() else {
			assertionFailure("Failed to create command buffer")
			return
		}

		guard let drawable = currentDrawable else {
			print("Failed to get current drawable")
			return
		}

		clear(to: drawable, commandBuffer: commandBuffer)

		if var image = ciImage {
			// Transform to expected coordinates
			image = image.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
			image = image.transformed(by: CGAffineTransform(translationX: 0, y: image.extent.height))

			let rect = pixelImageRect(for: drawable.texture)
			let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
			ciContext.render(image, to: drawable.texture, commandBuffer: commandBuffer, bounds: rect,
							 colorSpace: colorSpace)
		}

		commandBuffer.present(drawable)
		commandBuffer.commit()
	}

	// MARK: - Configuration

	func imageRectForBounds(_ bounds: CGRect) -> CGRect {
		var rect = bounds

		if let ciImage = ciImage {
			rect = rect.aspectFit(ciImage.extent.size)
		}

		return rect
	}

	// MARK: - Private

	private func pixelImageRect(for texture: MTLTexture) -> CGRect {
		var rect = imageRectForBounds(bounds)
		rect.origin.x *= contentScaleFactor
		rect.origin.y *= -contentScaleFactor
		rect.size.width *= contentScaleFactor
		rect.size.height *= contentScaleFactor
		return rect
	}

	private func clear(to drawable: MTLDrawable, commandBuffer: MTLCommandBuffer) {
		guard let renderPassDescriptor = currentRenderPassDescriptor else {
			assertionFailure("Missing render pass descriptor")
			return
		}

		let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
		renderEncoder.endEncoding()

//		commandBuffer.present(drawable)
//		commandBuffer.commit()
	}
}
#endif
