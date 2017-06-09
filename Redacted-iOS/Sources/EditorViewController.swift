//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 5/1/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit
import X
import Photos
import MobileCoreServices

class EditorViewController: UIViewController {

	// MARK: - Properties

	private let redactedView: RedactedView = {
		let view = RedactedView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let toolbarView: ToolbarView = {
		let view = ToolbarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let emptyView: EmptyView = {
		let view = EmptyView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	var image: UIImage? {
		didSet {
			redactedView.originalImage = image
			emptyView.isHidden = image != nil

			if image == nil {
				return
			}

//			showTutorial()
		}
	}

	var renderedImage: UIImage? {
		return redactedView.renderedImage()
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		redactedView.backgroundColor = UIColor(white: 43 / 255, alpha: 1)
		view.addSubview(redactedView)

		emptyView.choosePhotoButton.addTarget(self, action: #selector(choosePhoto), for: .primaryActionTriggered)
		emptyView.lastPhotoButton.addTarget(self, action: #selector(chooseLastPhoto), for: .primaryActionTriggered)
		emptyView.takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .primaryActionTriggered)
		view.addSubview(emptyView)

		toolbarView.modeControl.addTarget(self, action: #selector(modeDidChange), for: .primaryActionTriggered)
		toolbarView.clearButton.addTarget(self, action: #selector(clear), for: .primaryActionTriggered)
		toolbarView.shareButton.addTarget(self, action: #selector(share), for: .primaryActionTriggered)
		view.addSubview(toolbarView)

		NSLayoutConstraint.activate([
			redactedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			redactedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			redactedView.topAnchor.constraint(equalTo: view.topAnchor),
			redactedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
		view.addGestureRecognizer(pan)

		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		view.addGestureRecognizer(tap)

		let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTapped))
		twoFingerTap.numberOfTouchesRequired = 2
		view.addGestureRecognizer(twoFingerTap)

//		placeholderLabel.stringValue = string("DRAG_TO_GET_STARTED")
//
//		if !UserDefaults.standard.bool(forKey: "CreatedRedaction") {
//			setupTutorial()
//		}
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}


	// MARK: - Actions

	@objc private func share(_ sender: UIView) {
		guard let image = renderedImage else { return }

//		let sharingServicePicker = NSSharingServicePicker(items: [image])
//		sharingServicePicker.delegate = self
//		sharingServicePicker.show(relativeTo: CGRect.zero, of: sender, preferredEdge: .minY)
	}

	@objc private func panned(sender: UIPanGestureRecognizer) {
		redactedView.drag(point: sender.location(in: view), state: sender.state)

//		if sender.state == .ended && redactedView.redactions.count > 0 {
//			hideTutorial()
//		}
	}

	@objc private func tapped(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view))
		}
	}

	@objc private func twoFingerTapped(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view), exclusive: false)
		}
	}

	@objc private func clear() {
		image = nil
	}

	@objc private func modeDidChange() {
		guard let mode = RedactionType(rawValue: toolbarView.modeControl.selectedIndex) else { return }
		redactedView.mode = mode
	}

	@objc private func choosePhoto() {
		ensurePhotosAuthorization { [weak self] in
			let viewController = UIImagePickerController()
			viewController.sourceType = .savedPhotosAlbum
			viewController.modalPresentationStyle = .formSheet
			viewController.mediaTypes = [kUTTypeImage as String]
			viewController.delegate = self
			self?.present(viewController, animated: true, completion: nil)
		}
	}

	@objc private func chooseLastPhoto() {
		ensurePhotosAuthorization { [weak self] in
			let manager = PHImageManager.default()
			let options = PHFetchOptions()
			options.fetchLimit = 1
			options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

			let result = PHAsset.fetchAssets(with: .image, options: options)

			guard let last = result.lastObject else {
				self?.choosePhoto()
				return
			}

			let size = CGSize(width: last.pixelWidth, height: last.pixelHeight)
			manager.requestImage(for: last, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
				guard let image = image else {
					self?.choosePhoto()
					return
				}

				DispatchQueue.main.async {
					self?.image = image
				}
			})
		}
	}

	@objc private func takePhoto() {
		ensureCameraAuthorization { [weak self] in
			self?.ensurePhotosAuthorization {
				let viewController = UIImagePickerController()
				viewController.sourceType = .camera
				viewController.modalPresentationStyle = .formSheet
				viewController.mediaTypes = [kUTTypeImage as String]
				viewController.delegate = self
				self?.present(viewController, animated: true, completion: nil)
			}
		}
	}


	// MARK: - Private

	// TODO: Localize
	private func ensurePhotosAuthorization(_ completion: @escaping () -> Void) {
		switch PHPhotoLibrary.authorizationStatus() {
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization { [weak self] _ in
				DispatchQueue.main.async {
					self?.ensurePhotosAuthorization(completion)
				}
			}

		case .restricted:
			let alert = UIAlertController(title: "Restricted", message: "You don‘t have permission to allow Redacted to use your photos. This is probably due to parental controls.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
			present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: "Access Denied", message: "Please allow access to photos.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
				guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
				UIApplication.shared.openURL(url)
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
			present(alert, animated: true, completion: nil)

		case .authorized:
			completion()
		}
	}

	private func ensureCameraAuthorization(_ completion: @escaping () -> Void) {
		switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
		case .notDetermined:
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { [weak self] _ in
				DispatchQueue.main.async {
					self?.ensureCameraAuthorization(completion)
				}
			}

		case .restricted:
			let alert = UIAlertController(title: "Restricted", message: "You don‘t have permission to allow Redacted to use your camera. This is probably due to parental controls.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .cancel))
			present(alert, animated: true, completion: nil)

		case .denied:
			let alert = UIAlertController(title: "Access Denied", message: "Please allow camera access.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
				guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
				UIApplication.shared.openURL(url)
			})
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
			present(alert, animated: true, completion: nil)

		case .authorized:
			completion()
		}
	}
}



extension EditorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true, completion: nil)

		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
		self.image = image
	}
}
