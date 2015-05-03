//
//  AppDelegate.swift
//  Redacted
//
//  Created by Sam Soffes on 4/4/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

	// MARK: - Properties
	
	lazy var window: UIWindow? = {
		let window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window.rootViewController = UINavigationController(rootViewController: EditorViewController())
		return window
	}()
}


extension AppDelegate: UIApplicationDelegate {
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		window?.makeKeyAndVisible()
		return true
	}
}
