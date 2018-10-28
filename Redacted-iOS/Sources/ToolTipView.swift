import UIKit
import RedactedKit
import X

final class ToolTipView: UIView {

	// MARK: - Properties

	let textLabel: UILabel = {
		let label = Label()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = toolTipTextColor
		label.contentInsets = EdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 16, weight: UIFont.Weight.medium)


		label.shadowColor = UIColor(white: 1, alpha: 0.25)
		label.shadowOffset = CGSize(width: 0, height: 1)

		label.layer.backgroundColor = toolTipColor.cgColor
		label.layer.cornerRadius = 10

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

	override init(frame: CGRect) {
		super.init(frame: frame)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}


	// MARK: - NSView

	override func layoutSubviews() {
		super.layoutSubviews()

		let layer = textLabel.layer
		shadowLayer.frame = layer.frame

		var rect = shadowLayer.bounds
		rect = rect.insetBy(dx: 8, dy: 8)

		shadowLayer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
	}


	// MARK: - Private

	private func initialize() {
		layer.addSublayer(shadowLayer)
		addSubview(textLabel)

		NSLayoutConstraint.activate([
			textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
			textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
			textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
			textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
		])
	}
}
