import AVFoundation
import MobileCoreServices
import Photos
import RedactedKit
import UIKit

private final class ImagePickerController: UIImagePickerController {
	override var prefersStatusBarHidden: Bool {
		return true
	}

    override var childForStatusBarHidden: UIViewController? {
		return nil
	}
}

private final class ImagePickerDelegate: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	var pickCompletion: ((PHAsset?) -> Void)?
	var cameraCompletion: ((UIImage?) -> Void)?

	func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        if let completion = pickCompletion {
            let asset = info[.phAsset] as? PHAsset
			completion(asset)
		}

		if let completion = cameraCompletion {
			let image = info[.originalImage] as? UIImage
			completion(image)
		}

		dismiss(picker)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(picker)
	}

	private func dismiss(_ picker: UIImagePickerController) {
		pickCompletion = nil
		cameraCompletion = nil
		picker.dismiss(animated: true, completion: nil)
	}
}

struct PhotosController {

	// MARK: - Properties

	private static let imagePickerDelegate = ImagePickerDelegate()

	static let fetchOptions: PHFetchOptions = {
		let options = PHFetchOptions()
		options.fetchLimit = 1
		options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
		return options
	}()

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
			let alert = UIAlertController(title: LocalizedString.restrictedPhotosTitle.string,
                                          message: LocalizedString.restrictedPhotosMessage.string,
                                          preferredStyle: .alert)
			alert.addAction(.ok)
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: LocalizedString.accessDeniedPhotosTitle.string,
                                          message: LocalizedString.accessDeniedPhotosMessage.string,
                                          preferredStyle: .alert)
			alert.addAction(.openSettings)
			alert.addAction(.cancel)
			context?.present(alert, animated: true, completion: nil)

		case .authorized:
			completion()

		@unknown default:
			assertionFailure("Unknown authorization status")
		}
	}

	static func ensureCameraAuthorization(context: UIViewController?, _ completion: @escaping () -> Void) {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { _ in
				DispatchQueue.main.async {
					self.ensureCameraAuthorization(context: context, completion)
				}
			}

		case .restricted:
			let alert = UIAlertController(title: LocalizedString.restrictedCameraTitle.string,
                                          message: LocalizedString.restrictedCameraMessage.string,
                                          preferredStyle: .alert)
			alert.addAction(.ok)
			context?.present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: LocalizedString.accessDeniedCameraTitle.string,
                                          message: LocalizedString.accessDeniedCameraMessage.string,
                                          preferredStyle: .alert)
			alert.addAction(.openSettings)
			alert.addAction(.cancel)
			context?.present(alert, animated: true, completion: nil)

		case .authorized:
			completion()

		@unknown default:
			assertionFailure("Unknown authorization status")
		}
	}

	// MARK: - Reading Photos

	static func load(_ asset: PHAsset, completion: @escaping (PHContentEditingInput?) -> Void) {
		let inputOptions = PHContentEditingInputRequestOptions()
		inputOptions.canHandleAdjustmentData = { adjustmentData in
			return RedactionSerialization.canHandle(adjustmentData)
		}

		inputOptions.isNetworkAccessAllowed = true

		asset.requestContentEditingInput(with: inputOptions) { input, _ in
			completion(input)
		}
	}

	static func choosePhoto(context: UIViewController, completion: @escaping (PHAsset?) -> Void) {
		ensurePhotosAuthorization(context: context) {
			let viewController = ImagePickerController()
			viewController.sourceType = .savedPhotosAlbum
			viewController.modalPresentationStyle = .formSheet
			viewController.mediaTypes = [kUTTypeImage as String]
			viewController.delegate = imagePickerDelegate
			imagePickerDelegate.pickCompletion = completion
			context.present(viewController, animated: true, completion: nil)
		}
	}

	static func getLastPhoto(context: UIViewController, completion: @escaping (PHAsset?) -> Void) {
		ensurePhotosAuthorization(context: context) {
			let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
			completion(result.firstObject)
		}
	}

	static func takePhoto(context: UIViewController, completion: @escaping (UIImage?) -> Void) {
		ensureCameraAuthorization(context: context) {
			self.ensurePhotosAuthorization(context: context) {
				let viewController = ImagePickerController()
				viewController.sourceType = .camera
				viewController.modalPresentationStyle = .fullScreen
				viewController.mediaTypes = [kUTTypeImage as String]
				viewController.delegate = imagePickerDelegate
				imagePickerDelegate.cameraCompletion = { image in
					guard let image = image else {
						completion(nil)
						return
					}

					self.savePhoto(context: context) {
						return image
					}

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
				guard let image = photoProvider() else {
                    return
                }

				PHAssetChangeRequest.creationRequestForAsset(from: image)
			}, completionHandler: nil)
		}
	}
}
