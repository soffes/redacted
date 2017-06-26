//
//  AppDelegate.swift
//  Redacted
//
//  Created by Sam Soffes on 4/4/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit
import Mixpanel

var mixpanel = Mixpanel(token: "58ae93d9875496de97dbdc4cd7f0d927")

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties
	
	var window: UIWindow? = UIWindow()

	fileprivate var uniqueIdentifier: String {
		if let identifier = UIDevice.current.identifierForVendor?.uuidString {
			return identifier
		}

		let key = "Identifier"
		if let identifier = UserDefaults.standard.string(forKey: key) {
			return identifier
		}

		let identifier = UUID().uuidString
		UserDefaults.standard.set(identifier, forKey: key)
		return identifier
	}


	fileprivate let viewController = EditorViewController()

	fileprivate let choosePhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-photo"
	fileprivate let chooseLastPhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-last-photo"
	fileprivate let takePhotoType = "com.nothingmagical.redacted-ios.shortcut.take-photo"
}


extension AppDelegate: UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		#if DEBUG
			mixpanel.enabled = false
		#endif

		mixpanel.identify(identifier: uniqueIdentifier)
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
