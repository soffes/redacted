import Mixpanel
import UIKit

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties

	var window: UIWindow? = UIWindow()

	private let viewController = OpenViewController()

	private let choosePhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-photo"
	private let chooseLastPhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-last-photo"
	private let takePhotoType = "com.nothingmagical.redacted-ios.shortcut.take-photo"
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
		mixpanel.track(event: "Launch")

		application.shortcutItems = [
			UIApplicationShortcutItem(type: choosePhotoType, title: LocalizedString.choosePhoto.string,
                                      iconName: "Photo"),
			UIApplicationShortcutItem(type: chooseLastPhotoType, title: LocalizedString.chooseLastPhoto.string,
                                      iconName: "Library"),
			UIApplicationShortcutItem(type: takePhotoType, title: LocalizedString.takePhoto.string, iconName: "Camera")
		]

		window?.rootViewController = viewController
		window?.makeKeyAndVisible()

		return true
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void)
    {
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
