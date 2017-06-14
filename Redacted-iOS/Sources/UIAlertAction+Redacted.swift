//
//  UIAlertAction+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit

extension UIAlertAction {
	static let ok = UIAlertAction(title: localizedString("OK"), style: .cancel)

	static let cancel = UIAlertAction(title: localizedString("CANCEL"), style: .cancel)

	static let openSettings = UIAlertAction(title: localizedString("OPEN_SETTINGS"), style: .default) { _ in
		guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
		UIApplication.shared.open(url)
	}
}
