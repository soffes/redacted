//
//  Mixpanel.swift
//  Redacted
//
//  Created by Sam Soffes on 4/21/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation

#if os(iOS)
	import UIKit
#else
	import AppKit
#endif

public class Mixpanel {

	// MARK: - Types

	public typealias Completion = (success: Bool) -> ()

	
	// MARK: - Properties

	private var token: String
	private var URLSession: NSURLSession
	private let endpoint = "http://api.mixpanel.com/track/"
	private var distinctId: String?

	private var deviceModel: String? {
		var size : Int = 0
		sysctlbyname("hw.machine", nil, &size, nil, 0)
		var machine = [CChar](count: Int(size), repeatedValue: 0)
		sysctlbyname("hw.machine", &machine, &size, nil, 0)
		return String.fromCString(machine)
	}

	private var defaultProperties: [String: AnyObject] {
		var properties: [String: AnyObject] = [
			"$manufacturer": "Apple"
		]

		if let info = NSBundle.mainBundle().infoDictionary {
			if let version = info["CFBundleVersion"] as? String {
				properties["$app_version"] = version
			}

			if let shortVersion = info["CFBundleShortVersionString"] as? String {
				properties["$app_release"] = shortVersion
			}
		}

		if let deviceModel = deviceModel {
			properties["$model"] = deviceModel
		}

		#if os(iOS)
			properties["mp_lib"] = "iphone"

			let device = UIDevice.currentDevice()
			properties["$os"] = device.systemName
			properties["$os_version"] = device.systemVersion

			let size = UIScreen.mainScreen().bounds.size
			properties["$screen_width"] = UInt(size.width)
			properties["$screen_height"] = UInt(size.height)
		#else
			properties["mp_lib"] = "mac"

			let processInfo = NSProcessInfo()
			properties["$os"] = "Mac OS X"
			properties["$os_version"] = processInfo.operatingSystemVersionString

			if let size = NSScreen.mainScreen()?.frame.size {
				properties["$screen_width"] = UInt(size.width)
				properties["$screen_height"] = UInt(size.height)
			}
		#endif

		return properties
	}


	// MARK: - Initializers

	public init(token: String, URLSession: NSURLSession = NSURLSession.sharedSession()) {
		self.token = token
		self.URLSession = URLSession
	}


	// MARK: - Tracking

	public func identify(identifier: String?) {
		distinctId = identifier
	}


	public func track(event: String, parameters: [String: AnyObject]? = nil, time: NSDate = NSDate(), completion: Completion? = nil) {
		var properties = defaultProperties

		if let parameters = parameters {
			for (key, value) in parameters {
				properties[key] = value
			}
		}

		properties["token"] = token
		properties["time"] = time.timeIntervalSince1970

		if let distinctId = distinctId {
			properties["distinct_id"] = distinctId
		}

		let payload = [
			"event": event,
			"properties": properties
		]

		if let json = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: nil) {
			let base64 = json.base64EncodedStringWithOptions(nil).stringByReplacingOccurrencesOfString("\n", withString: "")
			if let url = NSURL(string: "\(endpoint)?data=\(base64)") {
				let request = NSURLRequest(URL: url)
				let task = URLSession.dataTaskWithRequest(request, completionHandler: { data, response, error in
					if let completion = completion, string = NSString(data: data, encoding: NSUTF8StringEncoding) {
						completion(success: string == "1")
					}
				})
				task.resume()
			}
		}
	}
}
