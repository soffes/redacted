//
//  ToolbarView.swift
//  Redacted
//
//  Created by Sam Soffes on 6/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit

final class ToolbarView: UIView {

	// MARK: - Types

	private final class Button: UIButton {
		override init(frame: CGRect) {
			super.init(frame: frame)
			adjustsImageWhenHighlighted = false
			updateColors()
		}

		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}

		override var isHighlighted: Bool {
			didSet {
				updateColors()
			}
		}

		private func updateColors() {
			let color = isHighlighted ? UIColor(white: 1, alpha: 0.5) : UIColor(white: 1, alpha: 0.7)
			imageView?.tintColor = color
		}
	}


	// MARK: - Properties

	private let stackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let visualEffectView: UIVisualEffectView = {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let clearButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Clear"), for: .normal)
		return view
	}()

	let shareButton: UIButton = {
		let view = Button(type: .custom)
		view.setImage(#imageLiteral(resourceName: "Share"), for: .normal)
		view.imageEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
		return view
	}()


	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		stackView.addArrangedSubview(UIView())
		stackView.addArrangedSubview(clearButton)
		stackView.addArrangedSubview(shareButton)
		visualEffectView.contentView.addSubview(stackView)
		addSubview(visualEffectView)

		NSLayoutConstraint.activate([
			visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
			visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
			visualEffectView.topAnchor.constraint(equalTo: topAnchor),
			visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

			stackView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),

			clearButton.widthAnchor.constraint(equalToConstant: 33),
			clearButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),

			shareButton.widthAnchor.constraint(equalTo: stackView.heightAnchor),
			shareButton.heightAnchor.constraint(equalTo: shareButton.widthAnchor),

			heightAnchor.constraint(equalToConstant: 44)
		])
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class var layerClass: AnyClass {
		return CATransformLayer.self
	}
}
