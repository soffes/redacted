//
//  AboutViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/7/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

	// MARK: - Properties

	@IBOutlet var versionLabel: NSTextField!


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let info = NSBundle.mainBundle().infoDictionary!
		let shortVersion = (info["CFBundleShortVersionString"] as! String)
		let version = (info["CFBundleVersion"] as! String)
		versionLabel.stringValue = "Version \(shortVersion) (\(version))"
	}

//	override func viewDidAppear() {
//		super.viewDidAppear()
//		view.window?.styleMask = NSTitledWindowMask | NSClosableWindowMask
//	}
}
