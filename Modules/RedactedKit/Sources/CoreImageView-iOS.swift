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

		let texture = drawable.texture
		clear(commandBuffer: commandBuffer)

		if var image = ciImage {
			// Transform to unflipped
			image = image.transformed(by: CGAffineTransform(scaleX: 1, y: -1))
			image = image.transformed(by: CGAffineTransform(translationX: 0, y: image.extent.height))

			// Aspect fit
			let textureBounds = CGRect(x: 0, y: 0, width: texture.width, height: texture.height)
			let rect = imageRectForBounds(textureBounds)
			image = image.transformed(by: CGAffineTransform(scaleX: rect.width / image.extent.width,
															y: rect.height / image.extent.height))
			image = image.transformed(by: CGAffineTransform(translationX: rect.origin.x, y: rect.origin.y))

			// Draw
			let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB()
			ciContext.render(image, to: texture, commandBuffer: commandBuffer, bounds: textureBounds,
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

	private func clear(commandBuffer: MTLCommandBuffer) {
		guard let renderPassDescriptor = currentRenderPassDescriptor else {
			assertionFailure("Missing render pass descriptor")
			return
		}

		let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
		renderEncoder.endEncoding()
	}
}
#endif
