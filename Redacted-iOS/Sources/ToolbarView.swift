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
		view.spacing = 4
		return view
	}()

	private let visualEffectView: UIVisualEffectView = {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let modeControl = SegmentedControl()

	let clearButton: UIButton = ToolbarButton(image: #imageLiteral(resourceName: "Clear"))

	let shareButton: UIButton = {
		let view = ToolbarButton(image: #imageLiteral(resourceName: "Share"))
		view.imageEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
		return view
	}()

	var isEnabled = true {
		didSet {
			modeControl.isEnabled = isEnabled
			clearButton.isEnabled = isEnabled
			shareButton.isEnabled = isEnabled
		}
	}

	private let haptics = UIImpactFeedbackGenerator(style: .medium)
	

	// MARK: - Initializers

	override init(frame: CGRect) {
		super.init(frame: frame)

		stackView.addArrangedSubview(modeControl)
		stackView.addArrangedSubview(UIView())

		#if !REDACTED_APP_EXTENSION
			clearButton.addTarget(haptics, action: #selector(UIImpactFeedbackGenerator.impactOccurred), for: .primaryActionTriggered)
			shareButton.addTarget(haptics, action: #selector(UIImpactFeedbackGenerator.impactOccurred), for: .primaryActionTriggered)
			stackView.addArrangedSubview(clearButton)
			stackView.addArrangedSubview(shareButton)
		#endif

		visualEffectView.contentView.addSubview(stackView)
		addSubview(visualEffectView)

		let stackBottom: NSLayoutAnchor<NSLayoutYAxisAnchor>

		if #available(iOS 11.0, *) {
			stackBottom = visualEffectView.safeAreaLayoutGuide.bottomAnchor
		} else {
			stackBottom = visualEffectView.bottomAnchor
		}

		var constraints = [
			visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
			visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
			visualEffectView.topAnchor.constraint(equalTo: topAnchor),
			visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

			stackView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 4),
			stackView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -4),
			stackView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: stackBottom),

			modeControl.heightAnchor.constraint(equalTo: stackView.heightAnchor),
			stackView.heightAnchor.constraint(equalToConstant: 44)
		]

		#if !REDACTED_APP_EXTENSION
			constraints += [
				clearButton.widthAnchor.constraint(equalToConstant: 40),
				clearButton.heightAnchor.constraint(equalTo: stackView.heightAnchor),

				shareButton.widthAnchor.constraint(equalToConstant: 40),
				shareButton.heightAnchor.constraint(equalTo: stackView.heightAnchor)
			]
		#endif

		NSLayoutConstraint.activate(constraints)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class var layerClass: AnyClass {
		return CATransformLayer.self
	}
}
