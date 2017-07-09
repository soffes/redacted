//
//  PhotosController.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices
import RedactedKit

private final class ImagePickerDelegate: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	var completion: ((UIImage) -> Void)?

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			completion?(image)
		}

		completion = nil
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		completion = nil
		picker.dismiss(animated: true, completion: nil)
	}
}

struct PhotosController {

	// MARK: - Properties

	private static let imagePickerDelegate = ImagePickerDelegate()


	// MARK: - Initializers

	private init() {}


	// MARK: - Authorization

	static func ensurePhotosAuthorization(context: UIViewController?, _ completion: @escaping () -> Void) {
		switch PHPhotoLibrary.authorizationStatus() {
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization { _ in
				DispatchQueue.main.async {
					self.ensurePhotosAuthorization(context: context, completion)
				}
			}

		case .restricted:
			let alert = UIAlertController(title: LocalizedString.restrictedPhotosTitle.string, message: LocalizedString.restrictedPhotosMessage.string, preferredStyle: .alert)
			alert.addAction(.ok)
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: LocalizedString.accessDeniedPhotosTitle.string, message: LocalizedString.accessDeniedPhotosMessage.string, preferredStyle: .alert)
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
			let alert = UIAlertController(title: LocalizedString.restrictedCameraTitle.string, message: LocalizedString.restrictedCameraMessage.string, preferredStyle: .alert)
			alert.addAction(.ok)
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: LocalizedString.accessDeniedCameraTitle.string, message: LocalizedString.accessDeniedCameraMessage.string, preferredStyle: .alert)
			alert.addAction(.openSettings)
			alert.addAction(.cancel)
			context?.present(alert, animated: true, completion: nil)

		case .authorized:
			completion()
		}
	}


	// MARK: - Reading Photos

	static func choosePhoto(context: UIViewController, completion: @escaping (UIImage) -> Void) {
		ensurePhotosAuthorization(context: context) {
			let viewController = UIImagePickerController()
			viewController.sourceType = .savedPhotosAlbum
			viewController.modalPresentationStyle = .formSheet
			viewController.mediaTypes = [kUTTypeImage as String]
			viewController.delegate = imagePickerDelegate
			imagePickerDelegate.completion = completion
			context.present(viewController, animated: true, completion: nil)
		}
	}

	static func getLastPhoto(context: UIViewController, completion: @escaping (PHContentEditingInput?) -> Void) {
		ensurePhotosAuthorization(context: context) {

			let fetchOptions = PHFetchOptions()
			fetchOptions.fetchLimit = 1
			fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

			let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)

			guard let asset = result.firstObject else { return }

			let inputOptions = PHContentEditingInputRequestOptions()
			inputOptions.canHandleAdjustmentData = { adjustmentData in
				do {
					_ = try RedactionSerialization.redactions(from: adjustmentData)
					return true
				} catch {
					print("Failed to check adjustment data: \(error)")
					return false
				}
			}

			inputOptions.isNetworkAccessAllowed = true
			inputOptions.progressHandler = { progress, _ in
				print("Download progress: \(progress)")
			}
			
			asset.requestContentEditingInput(with: inputOptions) { input, _ in
				completion(input)
			}
		}
	}

	static func takePhoto(context: UIViewController, completion: @escaping (UIImage) -> Void) {
		ensureCameraAuthorization(context: context) {
			self.ensurePhotosAuthorization(context: context) {
				let viewController = UIImagePickerController()
				viewController.sourceType = .camera
				viewController.modalPresentationStyle = .fullScreen
				viewController.mediaTypes = [kUTTypeImage as String]
				viewController.delegate = imagePickerDelegate
				imagePickerDelegate.completion = { image in
					self.savePhoto(context: context, photoProvider: {
						return image
					})
					completion(image)
				}
				context.present(viewController, animated: true, completion: nil)
			}
		}
	}


	// MARK: - Writing Photos

	static func savePhoto(context: UIViewController, photoProvider: @escaping () -> UIImage?) {
		ensurePhotosAuthorization(context: context) {
			PHPhotoLibrary.shared().performChanges({
				guard let image = photoProvider() else { return }
				PHAssetChangeRequest.creationRequestForAsset(from: image)
			}, completionHandler: nil)
		}
	}
}
