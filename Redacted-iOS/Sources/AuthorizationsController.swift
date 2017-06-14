//
//  AuthorizationsController.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import Photos
import AVFoundation

struct AuthorizationsController {

	private init() {}

	static func ensurePhotosAuthorization(context: UIViewController?, _ completion: @escaping () -> Void) {
		switch PHPhotoLibrary.authorizationStatus() {
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization { _ in
				DispatchQueue.main.async {
					self.ensurePhotosAuthorization(context: context, completion)
				}
			}

		case .restricted:
			let alert = UIAlertController(title: "Restricted", message: "You don‘t have permission to allow Redacted to use your photos. This is probably due to parental controls.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: "Access Denied", message: "Please allow access to photos.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
				guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
				UIApplication.shared.openURL(url)
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
			context?.present(alert, animated: true, completion: nil)

		case .authorized:
			completion()
		}
	}

	static func ensureCameraAuthorization(context: UIViewController?, _ completion: @escaping () -> Void) {
		switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
		case .notDetermined:
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { _ in
				DispatchQueue.main.async {
					self.ensureCameraAuthorization(context: context, completion)
				}
			}

		case .restricted:
			let alert = UIAlertController(title: "Restricted", message: "You don‘t have permission to allow Redacted to use your camera. This is probably due to parental controls.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: "Access Denied", message: "Please allow camera access.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
				guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
				UIApplication.shared.openURL(url)
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
			context?.present(alert, animated: true, completion: nil)

		case .authorized:
			completion()
		}
	}
}
