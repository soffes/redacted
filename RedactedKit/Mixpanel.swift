//
//  Mixpanel.swift
//  Redacted
//
//  Created by Sam Soffes on 4/21/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation

public class Mixpanel {

	// MARK: - Types

	public typealias Completion = (success: Bool) -> ()

	
	// MARK: - Properties

	private var token: String
	private var URLSession: NSURLSession
	private let endpoint = "http://api.mixpanel.com/track/"
	private var distinctId: String?


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
		var properties: [String: AnyObject] = parameters ?? [String: AnyObject]()
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
