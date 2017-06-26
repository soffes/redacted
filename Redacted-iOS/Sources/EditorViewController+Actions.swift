//
//  EditorViewController+Actions.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit
import SVProgressHUD

extension EditorViewController {
	func usePixelate() {
		toolbarView.modeControl.selectedIndex = 0
		modeDidChange()
	}

	func useBlur() {
		toolbarView.modeControl.selectedIndex = 1
		modeDidChange()
	}

	func useBlackBar() {
		toolbarView.modeControl.selectedIndex = 2
		modeDidChange()
	}

	func deleteRedaction() {
		redactedView.deleteRedaction()
	}

	func selectAllRedactions() {
		redactedView.selectAllRedactions()
	}

	func undoEdit() {
		_undoManager.undo()
	}

	func redoEdit() {
		_undoManager.redo()
	}

	func pastePhoto() {
		let data = UIPasteboard.general.data(forPasteboardType: "public.image")
		originalImage = data.flatMap(UIImage.init)

		mixpanel.track(event: "Import image", parameters: [
			"source": "Paste"
		])
	}

	func share(_ sender: UIView) {
		guard let renderedImage = renderedImage else { return }

		let viewController = UIActivityViewController(activityItems: [renderedImage], applicationActivities: nil)
		viewController.completionWithItemsHandler = { [weak self] type, completed, _, error in
			if error != nil {
				SVProgressHUD.showError(withStatus: nil)
				SVProgressHUD.dismiss(withDelay: 1)
				return
			}

			guard completed,
				let title = type?.rawValue,
				let count = self?.redactedView.redactions.count
			else { return }

			if title == "com.apple.UIKit.activity.CopyToPasteboard" {
				SVProgressHUD.showSuccess(withStatus: nil)
				SVProgressHUD.dismiss(withDelay: 1)
			} else if title == "com.apple.UIKit.activity.SaveToCameraRoll" {
				SVProgressHUD.showSuccess(withStatus: nil)
				SVProgressHUD.dismiss(withDelay: 1)
			}

			mixpanel.track(event: "Share image", parameters: [
				"service": title,
				"redactions_count": count
			])
		}

		if let presentationController = viewController.popoverPresentationController {
			presentationController.sourceView = sender
		}

		present(viewController, animated: true)
	}

	func copyImage() {
		UIPasteboard.general.image = renderedImage

		mixpanel.track(event: "Share image", parameters: [
			"service": "Copy",
			"redactions_count": redactedView.redactions.count
		])
	}

	func saveImage() {
		PhotosController.savePhoto(context: self, photoProvider: { [weak self] in return self?.renderedImage} )

		mixpanel.track(event: "Share image", parameters: [
			"service": "Save",
			"redactions_count": redactedView.redactions.count
		])
	}

	func panned(_ sender: UIPanGestureRecognizer) {
		redactedView.drag(point: sender.location(in: view), state: sender.state)

		if sender.state == .ended && redactedView.redactions.count > 0 {
			hideTutorial()
			UserDefaults.standard.set(true, forKey: "CreatedRedaction")
		}
	}

	func tapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view))
		}
	}

	func twoFingerTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view), exclusive: false)
		}
	}

	func longPressed(_ sender: UILongPressGestureRecognizer) {
		let point = sender.location(in: redactedView)
		guard let redaction = redactedView.redaction(at: point) else { return }

		let controller = UIMenuController.shared

		if longPressedRedaction == redaction && controller.isMenuVisible {
			return
		}

		longPressedRedaction = redaction

		redactedView.select(redaction, isExclusive: true)

		let rect = redactedView.rect(for: redaction)
		controller.setTargetRect(rect, in: redactedView)

		controller.menuItems = [
			UIMenuItem(title: string("DELETE_REDACTION"), action: #selector(deleteRedaction))
		]

		controller.isMenuVisible = true
	}

	func clear() {
		originalImage = nil
	}

	func modeDidChange() {
		guard let mode = RedactionType(rawValue: toolbarView.modeControl.selectedIndex) else { return }
		redactedView.mode = mode
	}

	func choosePhoto() {
		haptics.prepare()
		PhotosController.choosePhoto(context: self) { [weak self] image in
			self?.originalImage = image

			mixpanel.track(event: "Import image", parameters: [
				"source": "Library"
			])
		}
	}

	func chooseLastPhoto() {
		haptics.prepare()
		PhotosController.getLastPhoto(context: self) { [weak self] image in
			self?.originalImage = image

			mixpanel.track(event: "Import image", parameters: [
				"source": "Last Photo Taken"
			])
		}
	}

	func takePhoto() {
		haptics.prepare()
		PhotosController.takePhoto(context: self) { [weak self] image in
			self?.originalImage = image

			mixpanel.track(event: "Import image", parameters: [
				"source": "Camera"
			])
		}
	}
}
