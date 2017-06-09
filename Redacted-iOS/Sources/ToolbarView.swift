//
//  ToolbarView.swift
//  Redacted
//
//  Created by Sam Soffes on 6/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit

final class ToolbarView: UIView {

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

	let modeControl: UIControl = SegmentedControl()

	let clearButton: UIButton = ToolbarButton(image: #imageLiteral(resourceName: "Clear"))

	let shareButton: UIButton = {
		let view = ToolbarButton(image: #imageLiteral(resourceName: "Share"))
		view.imageEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
		return view
	}()
	

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		stackView.addArrangedSubview(modeControl)
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

			stackView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 4),
			stackView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -4),
			stackView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor),

			modeControl.heightAnchor.constraint(equalTo: stackView.heightAnchor),

			clearButton.widthAnchor.constraint(equalToConstant: 40),
			clearButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),

			shareButton.widthAnchor.constraint(equalToConstant: 40),
			shareButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),

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
