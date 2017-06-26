//
//  UIAlertAction+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit

extension UIAlertAction {
	static let ok = UIAlertAction(title: LocalizedString.ok.string, style: .cancel)

	static let cancel = UIAlertAction(title: LocalizedString.cancel.string, style: .cancel)

	static let openSettings = UIAlertAction(title: LocalizedString.openSettingsButton.string, style: .default) { _ in
		guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
		UIApplication.shared.open(url)
	}
}
