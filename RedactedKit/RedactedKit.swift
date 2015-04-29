//
//  RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 4/14/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation

func bundle() -> NSBundle? {
	return NSBundle(forClass: RedactedLayer.self)
}

public func string(key: String) -> String {
	if let bundle = bundle() {
		return bundle.localizedStringForKey(key, value: nil, table: nil)
	}
	return key
}
