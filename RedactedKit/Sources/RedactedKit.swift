//
//  RedactedKit.swift
//  Redacted
//
//  Created by Sam Soffes on 4/14/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import X

func bundle() -> Bundle? {
	return Bundle(for: RedactedLayer.self)
}

public func string(_ key: String) -> String {
	if let bundle = bundle() {
		return bundle.localizedString(forKey: key, value: nil, table: nil)
	}
	return key
}
