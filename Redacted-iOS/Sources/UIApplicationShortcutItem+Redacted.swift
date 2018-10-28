import UIKit

extension UIApplicationShortcutItem {
	convenience init(type: String, title: String, subtitle: String? = nil, iconName: String? = nil,
                     userInfo: [String: NSSecureCoding]? = nil)
    {
        self.init(type: type, localizedTitle: title, localizedSubtitle: subtitle,
                  icon: iconName.flatMap(UIApplicationShortcutIcon.init), userInfo: userInfo)
	}
}
