//
//  OpenViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 7/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit
import X
import AVFoundation

final class OpenViewController: UIViewController {

	// MARK: - Properties

	fileprivate let emptyView: EmptyView = {
		let view = EmptyView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let haptics = UISelectionFeedbackGenerator()

	private let editorViewController = EditorViewController()

	private var hasImage: Bool {
		return editorViewController.originalImage != nil
	}


	// MARK: - UIResponder

	override var undoManager: UndoManager? {
		return editorViewController.undoManager
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand]? {
		var commands = super.keyCommands ?? []

		if !hasImage {
			commands += [
				UIKeyCommand(input: "o", modifierFlags: .command, action: #selector(choosePhoto), discoverabilityTitle: LocalizedString.choosePhoto.string),
				UIKeyCommand(input: "o", modifierFlags: [.command, .shift], action: #selector(chooseLastPhoto), discoverabilityTitle: LocalizedString.chooseLastPhoto.string),
				UIKeyCommand(input: "o", modifierFlags: [.command, .alternate], action: #selector(takePhoto), discoverabilityTitle: LocalizedString.takePhoto.string),
			]

			if UIPasteboard.general.hasImage {
				commands.append(UIKeyCommand(input: "v", modifierFlags: .command, action: #selector(pastePhoto), discoverabilityTitle: LocalizedString.pastePhoto.string))
			}
		}

		return commands
	}


	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		editorViewController.delegate = self
		addChildViewController(editorViewController)
		editorViewController.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(editorViewController.view)

		emptyView.choosePhotoButton.addTarget(self, action: #selector(choosePhoto), for: .primaryActionTriggered)
		emptyView.lastPhotoButton.addTarget(self, action: #selector(chooseLastPhoto), for: .primaryActionTriggered)
		emptyView.takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .primaryActionTriggered)
		emptyView.pastePhotoButton.addTarget(self, action: #selector(pastePhoto), for: .primaryActionTriggered)
		view.addSubview(emptyView)

		NSLayoutConstraint.activate([
			editorViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			editorViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			editorViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
			editorViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}


	// MARK: - Actions

	func clear() {
		editorViewController.clear()
	}

	func choosePhoto() {
		haptics.prepare()
		PhotosController.choosePhoto(context: self) { [weak self] image in
			self?.editorViewController.originalImage = image

			mixpanel.track(event: "Import image", parameters: [
				"source": "Library"
			])
		}
	}

	func chooseLastPhoto() {
		haptics.prepare()
		PhotosController.getLastPhoto(context: self) { [weak self] image in
			self?.editorViewController.originalImage = image

			mixpanel.track(event: "Import image", parameters: [
				"source": "Last Photo Taken"
			])
		}
	}

	func takePhoto() {
		haptics.prepare()
		PhotosController.takePhoto(context: self) { [weak self] image in
			self?.editorViewController.originalImage = image

			mixpanel.track(event: "Import image", parameters: [
				"source": "Camera"
			])
		}
	}

	func pastePhoto() {
		let data = UIPasteboard.general.data(forPasteboardType: "public.image")
		editorViewController.originalImage = data.flatMap(UIImage.init)

		mixpanel.track(event: "Import image", parameters: [
			"source": "Paste"
		])
	}
}


extension OpenViewController: EditorViewControllerDelegate {
	func editorViewController(_ viewController: EditorViewController, didChangeImage image: UIImage?) {
		emptyView.isHidden = image != nil
	}
}
