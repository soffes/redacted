//
//  UIApplicationShortcutItem+Redacted.swift
//  Redacted
//
//  Created by Sam Soffes on 6/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit

extension UIApplicationShortcutItem {
	convenience init(type: String, title: String, subtitle: String? = nil, iconName: String? = nil, userInfo: [AnyHashable: Any]? = nil) {
		self.init(type: type, localizedTitle: title, localizedSubtitle: subtitle, icon: iconName.flatMap(UIApplicationShortcutIcon.init), userInfo: userInfo)
	}
}
