//
//  Mixpanel.swift
//  Redacted
//
//  Created by Sam Soffes on 7/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import Mixpanel

let mixpanel: Mixpanel = {
	var mp = Mixpanel(token: Secrets.mixpanelToken)

	#if DEBUG
		mp.enabled = false
	#endif

	if let identifier = UIDevice.current.identifierForVendor?.uuidString {
		mp.identify(identifier: identifier)
	} else {
		let key = "Identifier"
		if let identifier = UserDefaults.standard.string(forKey: key) {
			mp.identify(identifier: identifier)
		} else {
			let identifier = UUID().uuidString
			UserDefaults.standard.set(identifier, forKey: key)
			mp.identify(identifier: identifier)
		}
	}

	return mp
}()
