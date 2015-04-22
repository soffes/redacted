//
//  RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 4/14/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation

#if os(iOS)
	public let bundleIdentifier = "com.nothingmagical.redacted-ios.redactedkit"
	public let mixpanel = Mixpanel(token: "58ae93d9875496de97dbdc4cd7f0d927")
#else
	public let bundleIdentifier = "com.nothingmagical.redacted-mac.redactedkit"
	public let mixpanel = Mixpanel(token: "8a64b11c12312da3bead981a4ad7e30b")
#endif

public func string(key: String) -> String {
	if let bundle = NSBundle(identifier: bundleIdentifier) {
		return bundle.localizedStringForKey(key, value: nil, table: nil)
	}
	return key
}
