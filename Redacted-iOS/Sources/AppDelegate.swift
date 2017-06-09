//
//  AppDelegate.swift
//  Redacted
//
//  Created by Sam Soffes on 4/4/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit

@UIApplicationMain final class AppDelegate: UIResponder {

	// MARK: - Properties
	
	var window: UIWindow? = UIWindow()

	fileprivate let viewController = EditorViewController()

	fileprivate let choosePhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-photo"
	fileprivate let chooseLastPhotoType = "com.nothingmagical.redacted-ios.shortcut.choose-last-photo"
	fileprivate let takePhotoType = "com.nothingmagical.redacted-ios.shortcut.take-photo"
}


extension AppDelegate: UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		application.shortcutItems = [
			UIApplicationShortcutItem(type: choosePhotoType, title: localizedString("CHOOSE_PHOTO"), iconName: "Photo"),
			UIApplicationShortcutItem(type: chooseLastPhotoType, title: localizedString("LAST_PHOTO_TAKEN"), iconName: "Library"),
			UIApplicationShortcutItem(type: takePhotoType, title: localizedString("TAKE_PHOTO"), iconName: "Camera")
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
