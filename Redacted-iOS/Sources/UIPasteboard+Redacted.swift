//
//  UIPasteboard+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit

extension UIPasteboard {
	var hasImage: Bool {
		return contains(pasteboardTypes: ["public.image"])
	}
}
