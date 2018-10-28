import UIKit

final class EmptyView: UIStackView {

	// MARK: - Types

	private final class Button: UIButton {
		private let padding: CGFloat = 16

		override init(frame: CGRect) {
			super.init(frame: frame)

			contentHorizontalAlignment = .left
			imageEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
			titleEdgeInsets = UIEdgeInsets(top: 0, left: padding * 2, bottom: 0, right: 0)

			titleLabel?.font = .systemFont(ofSize: 17, weight:  .medium)
			setTitleColor(UIColor(white: 1, alpha: 0.8), for: .normal)
			setTitleColor(UIColor(white: 1, alpha: 0.7), for: .highlighted)

			adjustsImageWhenHighlighted = false

			updateColors()
		}

		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override var intrinsicContentSize: CGSize {
			var size = super.intrinsicContentSize
			size.width += padding * 3
			size.height = 48
			return size
		}

		override var isHighlighted: Bool {
			didSet {
				updateColors()
			}
		}

		private func updateColors() {
			let color = titleColor(for: isHighlighted ? .highlighted : .normal)
			imageView?.tintColor = color
		}
	}

	// MARK: - Properties

	let choosePhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Photo"), for: .normal)
		view.setTitle(LocalizedString.choosePhoto.string, for: .normal)
		return view
	}()

	let lastPhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Library"), for: .normal)
		view.setTitle(LocalizedString.chooseLastPhoto.string, for: .normal)
		return view
	}()

	let takePhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Camera"), for: .normal)
		view.setTitle(LocalizedString.takePhoto.string, for: .normal)
		return view
	}()

	let pastePhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Paste"), for: .normal)
		view.setTitle(LocalizedString.pastePhoto.string, for: .normal)
		view.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .disabled)
		return view
	}()

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		axis = .vertical
		spacing = 8
		alignment = .fill

		addArrangedSubview(choosePhotoButton)
		addArrangedSubview(lastPhotoButton)
		addArrangedSubview(takePhotoButton)
		addArrangedSubview(pastePhotoButton)

        NotificationCenter.default.addObserver(self, selector: #selector(pasteboardDidChange),
                                               name: UIPasteboard.changedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(pasteboardDidChange),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
		pasteboardDidChange()
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private

	@objc private func pasteboardDidChange() {
		pastePhotoButton.isEnabled = UIPasteboard.general.hasImage
	}
}
