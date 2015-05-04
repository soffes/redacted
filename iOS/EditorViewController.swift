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
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		return view
	}()

	let modeControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: [
			Image(named: "pixelate")!,
			Image(named: "blur")!,
			Image(named: "black-bar")!
		])
		return segmentedControl
	}()


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		title = "Redacted"
		toolbarItems = [
			UIBarButtonItem(customView: modeControl),
			UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil),
			UIBarButtonItem(barButtonSystemItem: .Action, target: nil, action: nil)
		]

		view.addSubview(redactedView)

		let views = [ "redactedView": redactedView ]
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[redactedView]|", options: nil, metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[redactedView]|", options: nil, metrics: nil, views: views))
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setToolbarHidden(false, animated: animated)
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setToolbarHidden(true, animated: animated)
	}
}
