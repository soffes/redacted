import AppKit
import RedactedKit
import X

final class ToolTipView: NSView {

	// MARK: - Properties

	let textLabel: Label = {
		let label = Label()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = toolTipTextColor
		label.contentInsets = EdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

		label.wantsLayer = true
		if let layer = label.layer {
			layer.backgroundColor = toolTipColor.cgColor
			layer.cornerRadius = 10
		}

		return label
	}()

	private let shadowLayer: CALayer = {
		let layer = CALayer()
		layer.shadowColor = Color.black.cgColor
		layer.shadowOffset = .zero
		layer.shadowRadius = 8
		layer.shadowOpacity = 1
		return layer
	}()

	// MARK: - Initializers

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}

	// MARK: - NSView

	override func layout() {
		super.layout()

		if let layer = textLabel.layer {
			shadowLayer.frame = layer.frame

			var rect = shadowLayer.bounds
			rect = rect.insetBy(dx: 8, dy: 8)

			shadowLayer.shadowPath = NSBezierPath(roundedRect: rect, xRadius: 10, yRadius: 10).cgPath
		}
	}

	// MARK: - Private

	private func initialize() {
		wantsLayer = true
		layer?.addSublayer(shadowLayer)
		addSubview(textLabel)

		NSLayoutConstraint.activate([
			textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])
	}
}
