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
			imageDidChange()
		}
	}

	var renderedImage: UIImage? {
		return redactedView.renderedImage()
	}

	private let _undoManager = UndoManager()


	// MARK: - UIResponder

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var undoManager: UndoManager? {
		return _undoManager
	}

	override var keyCommands: [UIKeyCommand]? {
		var commands = super.keyCommands ?? []

		if image != nil {
			commands += [
				UIKeyCommand(input: "1", modifierFlags: .command, action: #selector(usePixelate), discoverabilityTitle: string("PIXELATE")),
				UIKeyCommand(input: "2", modifierFlags: .command, action: #selector(useBlur), discoverabilityTitle: string("BLUR")),
				UIKeyCommand(input: "3", modifierFlags: .command, action: #selector(useBlackBar), discoverabilityTitle: string("BLACK_BAR")),
				UIKeyCommand(input: "\u{8}", modifierFlags: [], action: #selector(deleteRedaction), discoverabilityTitle: string("DELETE_REDACTION")),
				UIKeyCommand(input: "a", modifierFlags: .command, action: #selector(selectAllRedactions), discoverabilityTitle: string("SELECT_ALL_REDACTIONS")),
				UIKeyCommand(input: "\u{8}", modifierFlags: .command, action: #selector(clear), discoverabilityTitle: string("CLEAR_IMAGE")),
				UIKeyCommand(input: "e", modifierFlags: .command, action: #selector(share), discoverabilityTitle: string("SHARE")),
			]

			if _undoManager.canUndo {
				commands.append(UIKeyCommand(input: "z", modifierFlags: .command, action: #selector(undoEdit), discoverabilityTitle: "Undo"))
			}

			if _undoManager.canRedo {
				commands.append(UIKeyCommand(input: "z", modifierFlags: [.command, .shift], action: #selector(redoEdit), discoverabilityTitle: "Redo"))
			}

		} else {
			commands += [
				UIKeyCommand(input: "o", modifierFlags: .command, action: #selector(choosePhoto), discoverabilityTitle: localizedString("CHOOSE_PHOTO")),
				UIKeyCommand(input: "o", modifierFlags: [.command, .shift], action: #selector(chooseLastPhoto), discoverabilityTitle: localizedString("CHOOSE_LAST_PHOTO")),
				UIKeyCommand(input: "o", modifierFlags: [.command, .alternate], action: #selector(takePhoto), discoverabilityTitle: localizedString("TAKE_PHOTO"))
			]
		}

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		redactedView.backgroundColor = UIColor(white: 43 / 255, alpha: 1)
		redactedView.undoManager = _undoManager
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

		imageDidChange()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}


	// MARK: - Actions

	@objc private func usePixelate() {
		toolbarView.modeControl.selectedIndex = 0
		modeDidChange()
	}

	@objc private func useBlur() {
		toolbarView.modeControl.selectedIndex = 1
		modeDidChange()
	}

	@objc private func useBlackBar() {
		toolbarView.modeControl.selectedIndex = 2
		modeDidChange()
	}

	@objc private func deleteRedaction() {
		redactedView.deleteRedaction()
	}

	@objc private func selectAllRedactions() {
		redactedView.selectAllRedactions()
	}

	@objc private func undoEdit() {
		_undoManager.undo()
	}

	@objc private func redoEdit() {
		_undoManager.redo()
	}

	@objc private func share(_ sender: UIView) {
		// TODO: Add SVProgressHUD
		guard let image = renderedImage else { return }

		let viewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		viewController.completionWithItemsHandler = { type, completed, _, _ in
			// TODO: Report to Mixpanel
		}

		if let presentationController = viewController.popoverPresentationController {
			presentationController.sourceView = sender
		}

		present(viewController, animated: true)
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

	func clear() {
		image = nil
	}

	@objc private func modeDidChange() {
		guard let mode = RedactionType(rawValue: toolbarView.modeControl.selectedIndex) else { return }
		redactedView.mode = mode
	}

	func choosePhoto() {
		AuthorizationsController.ensurePhotosAuthorization(context: self) { [weak self] in
			let viewController = UIImagePickerController()
			viewController.sourceType = .savedPhotosAlbum
			viewController.modalPresentationStyle = .formSheet
			viewController.mediaTypes = [kUTTypeImage as String]
			viewController.delegate = self
			self?.present(viewController, animated: true, completion: nil)
		}
	}

	func chooseLastPhoto() {
		AuthorizationsController.ensurePhotosAuthorization(context: self) { [weak self] in
			let manager = PHImageManager.default()
			let options = PHFetchOptions()
			options.fetchLimit = 1
			options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

			let result = PHAsset.fetchAssets(with: .image, options: options)

			guard let last = result.firstObject else {
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

	func takePhoto() {
		AuthorizationsController.ensureCameraAuthorization(context: self) { [weak self] in
			AuthorizationsController.ensurePhotosAuthorization(context: self) {
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

	private func imageDidChange() {
		redactedView.originalImage = image

		let hasImage = image != nil
		emptyView.isHidden = hasImage
		toolbarView.isEnabled = hasImage

//		if !hasImage {
//			showTutorial()
//		}
	}
}



extension EditorViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true, completion: nil)

		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
		self.image = image
	}
}
