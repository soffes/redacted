#if os(macOS)
import AppKit
import QuartzCore

public class CoreImageView: NSView {

    // MARK: - Properties

    var ciImage: CIImage? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }

    // MARK: - Initializers

    public override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }

    // MARK: - View

    public override func draw(_ rect: CGRect) {
        guard let context = NSGraphicsContext.current?.cgContext,
            let image = ciImage
        else { return }

        let options: [CIContextOption: Any] = [
            .useSoftwareRenderer: false,
            .workingColorSpace: NSNull()
        ]

        let ciContext = CIContext(cgContext: context, options: options)
        ciContext.draw(image, in: imageRectForBounds(bounds), from: image.extent)
    }

    // MARK: - Configuration

    func imageRectForBounds(_ bounds: CGRect) -> CGRect {
        var rect = bounds

        if let ciImage = ciImage {
            rect = rect.aspectFit(ciImage.extent.size)
        }

        return rect
    }
}
#endif
