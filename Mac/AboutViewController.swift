//
//  AboutViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/7/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class AboutViewController: NSViewController {

	// MARK: - Properties

	@IBOutlet var versionLabel: NSTextField!


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let info = NSBundle.mainBundle().infoDictionary!
		let shortVersion = (info["CFBundleShortVersionString"] as! String)
		let version = (info["CFBundleVersion"] as! String)
		versionLabel.stringValue = NSString(format: string("VERSION_FORMAT"), locale: nil, "\(shortVersion) (\(version))") as String
	}
}
