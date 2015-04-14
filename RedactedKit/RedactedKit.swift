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
#else
	public let bundleIdentifier = "com.nothingmagical.redacted-mac.redactedkit"
#endif

public func string(key: String) -> String {
	if let bundle = NSBundle(identifier: bundleIdentifier) {
		return bundle.localizedStringForKey(key, value: nil, table: nil)
	}
	return key
}
