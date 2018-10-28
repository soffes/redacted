import UIKit
import Mixpanel

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties
	
	var window: UIWindow? = UIWindow()

	fileprivate let viewController = OpenViewController()

	fileprivate let choosePhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-photo"
	fileprivate let chooseLastPhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-last-photo"
	fileprivate let takePhotoType = "com.nothingmagical.redacted-ios.shortcut.take-photo"
}


extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		mixpanel.track(event: "Launch")

		application.shortcutItems = [
			UIApplicationShortcutItem(type: choosePhotoType, title: LocalizedString.choosePhoto.string, iconName: "Photo"),
			UIApplicationShortcutItem(type: chooseLastPhotoType, title: LocalizedString.chooseLastPhoto.string, iconName: "Library"),
			UIApplicationShortcutItem(type: takePhotoType, title: LocalizedString.takePhoto.string, iconName: "Camera")
		]

		window?.rootViewController = viewController
		window?.makeKeyAndVisible()

		return true
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		if shortcutItem.type == choosePhotoType {
			viewController.clear()
			viewController.choosePhoto()
			completionHandler(true)
			return
		} else if shortcutItem.type == chooseLastPhotoType {
			viewController.clear()
			viewController.chooseLastPhoto()
			completionHandler(true)
			return
		} else if shortcutItem.type == takePhotoType {
			viewController.clear()
			viewController.takePhoto()
			completionHandler(true)
			return
		}

		completionHandler(false)
	}
}
