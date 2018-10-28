import UIKit

final class ToolbarButton: UIButton {

	// MARK: - Initializers

	convenience init(image: UIImage) {
		self.init(frame: .zero)
		setImage(image, for: .normal)
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		adjustsImageWhenHighlighted = false

		imageView?.layer.shadowColor = UIColor.white.cgColor
		imageView?.layer.shadowOffset = .zero
		imageView?.layer.shadowRadius = 4
		imageView?.layer.shadowOpacity = 0
		imageView?.clipsToBounds = false

		updateImageView()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIControl

	override var isHighlighted: Bool {
		didSet {
			updateImageView()
		}
	}

	override var isSelected: Bool {
		didSet {
			updateImageView()
		}
	}


	// MARK: - Private

	private func updateImageView() {
		if isSelected {
			imageView?.tintColor = .white
		} else if isHighlighted {
			imageView?.tintColor = UIColor(white: 1, alpha: 0.5)
		} else {
			imageView?.tintColor = UIColor(white: 1, alpha: 0.6)
		}

		imageView?.layer.shadowOpacity = isSelected ? 0.6 : 0
	}
}
