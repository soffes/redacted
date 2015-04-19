//
//  AboutViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 4/7/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import RedactedKit

class AboutViewController: NSViewController {

	// MARK: - Properties

	@IBOutlet var versionLabel: NSTextField!
	@IBOutlet var creditsLabel: NSTextField!
	@IBOutlet var copyrightLabel: NSTextField!


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let bundle = NSBundle.mainBundle()
		let info = bundle.localizedInfoDictionary ?? bundle.infoDictionary!
		let shortVersion = info["CFBundleShortVersionString"] as! String
		let version = info["CFBundleVersion"] as! String

		versionLabel.stringValue = NSString(format: string("VERSION_FORMAT"), locale: nil, "\(shortVersion) (\(version))") as String
		creditsLabel.stringValue = string("CREDITS")
		copyrightLabel.stringValue = info["NSHumanReadableCopyright"] as! String
	}
}
