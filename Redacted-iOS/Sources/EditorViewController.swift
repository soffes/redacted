//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit
import X

class EditorViewController: UIViewController {

	// MARK: - Properties

	private let redactedView: RedactedView = {
		let view = RedactedView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let toolbarView: ToolbarView = {
		let view = ToolbarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let emptyView: EmptyView = {
		let view = EmptyView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		redactedView.backgroundColor = UIColor(white: 43 / 255, alpha: 1)
		view.addSubview(redactedView)
		view.addSubview(emptyView)
		view.addSubview(toolbarView)

		NSLayoutConstraint.activate([
			redactedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			redactedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			redactedView.topAnchor.constraint(equalTo: view.topAnchor),
			redactedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		// TODO: Remove
//		redactedView.originalImage = #imageLiteral(resourceName: "ScreenShot")

		let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
		view.addGestureRecognizer(pan)

		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		view.addGestureRecognizer(tap)

		let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTapped))
		twoFingerTap.numberOfTouchesRequired = 2
		view.addGestureRecognizer(twoFingerTap)

//		placeholderLabel.stringValue = string("DRAG_TO_GET_STARTED")
//
//		if !UserDefaults.standard.bool(forKey: "CreatedRedaction") {
//			setupTutorial()
//		}
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}


	// MARK: - Actions

	//	func shareImage(fromView sender: NSView) {
	//		if let image = renderedImage {
	//			let sharingServicePicker = NSSharingServicePicker(items: [image])
	//			sharingServicePicker.delegate = self
	//			sharingServicePicker.show(relativeTo: CGRect.zero, of: sender, preferredEdge: .minY)
	//		}
	//	}

	func panned(sender: UIPanGestureRecognizer) {
		redactedView.drag(point: sender.location(in: view), state: sender.state)

		//		if sender.state == .ended && redactedView.redactions.count > 0 {
		//			hideTutorial()
		//		}
	}

	func tapped(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view))
		}
	}

	func twoFingerTapped(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view), exclusive: false)
		}
	}
}
