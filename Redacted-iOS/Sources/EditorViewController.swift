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

	let redactedView: RedactedView = {
		let view = RedactedView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let modeControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: [
			image("Pixelate")!,
			image("Blur")!,
			image("BlackBar")!
		])
		segmentedControl.selectedSegmentIndex = 0
		return segmentedControl
	}()


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		toolbarItems = [
			UIBarButtonItem(customView: modeControl),
			UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
			UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
		]

		view.addSubview(redactedView)

		NSLayoutConstraint.activate([
			redactedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			redactedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			redactedView.topAnchor.constraint(equalTo: view.topAnchor),
			redactedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		redactedView.originalImage = #imageLiteral(resourceName: "ScreenShot")
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
		navigationController?.setToolbarHidden(false, animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
		navigationController?.setToolbarHidden(true, animated: animated)
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}
}
