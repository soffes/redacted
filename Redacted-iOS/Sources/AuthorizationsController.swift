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
			let alert = UIAlertController(title: localizedString("RESTRICTED_PHOTOS_TITLE"), message: localizedString("RESTRICTED_PHOTOS_MESSAGE"), preferredStyle: .alert)
			alert.addAction(.ok)
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: localizedString("ACCESS_DENIED_PHOTOS_TITLE"), message: localizedString("ACCESS_DENIED_PHOTOS_MESSAGE"), preferredStyle: .alert)
			alert.addAction(.openSettings)
			alert.addAction(.cancel)
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
			let alert = UIAlertController(title: localizedString("RESTRICTED_CAMERA_TITLE"), message: localizedString("RESTRICTED_CAMERA_MESSAGE"), preferredStyle: .alert)
			alert.addAction(.ok)
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: localizedString("ACCESS_DENIED_CAMERA_TITLE"), message: localizedString("ACCESS_DENIED_CAMERA_MESSAGE"), preferredStyle: .alert)
			alert.addAction(.openSettings)
			alert.addAction(.cancel)
			context?.present(alert, animated: true, completion: nil)

		case .authorized:
			completion()
		}
	}
}
