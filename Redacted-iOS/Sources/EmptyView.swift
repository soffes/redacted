//
//  EmptyView.swift
//  Redacted
//
//  Created by Sam Soffes on 6/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

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

			titleLabel?.font = .systemFont(ofSize: 17, weight:  UIFontWeightMedium)
			setTitleColor(UIColor(white: 1, alpha: 0.6), for: .normal)
			setTitleColor(UIColor(white: 1, alpha: 0.5), for: .highlighted)

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
			let color = isHighlighted ? UIColor(white: 1, alpha: 0.5) : UIColor(white: 1, alpha: 0.6)
			imageView?.tintColor = color
		}
	}


	// MARK: - Properties

	let choosePhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Photo"), for: .normal)
		view.setTitle("Choose Photo", for: .normal)
		return view
	}()

	let lastPhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Library"), for: .normal)
		view.setTitle("Last Photo Taken", for: .normal)
		return view
	}()

	let takePhotoButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Camera"), for: .normal)
		view.setTitle("Take a Photo", for: .normal)
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
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
