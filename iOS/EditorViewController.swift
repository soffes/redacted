//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit

class EditorViewController: UIViewController {

	// MARK: - Properties

	let redactedView: RedactedView = {
		let view = RedactedView()
		view.setTranslatesAutoresizingMaskIntoConstraints(false)
		return view
	}()
	

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(redactedView)

		let views = [ "redactedView": redactedView ]
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[redactedView]|", options: nil, metrics: nil, views: views))
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[redactedView]|", options: nil, metrics: nil, views: views))
	}
}
