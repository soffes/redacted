//
//  EditorViewController+Actions.swift
//  Redacted
//
//  Created by Sam Soffes on 6/14/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import RedactedKit

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
		image = data.flatMap(UIImage.init)
	}

	func share(_ sender: UIView) {
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

	func panned(sender: UIPanGestureRecognizer) {
		redactedView.drag(point: sender.location(in: view), state: sender.state)

		//		if sender.state == .ended && redactedView.redactions.count > 0 {
		//			hideTutorial()
		//		}
	}

	func tapped(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view))
		}
	}

	func twoFingerTapped(sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view), exclusive: false)
		}
	}

	func clear() {
		image = nil
	}

	func modeDidChange() {
		guard let mode = RedactionType(rawValue: toolbarView.modeControl.selectedIndex) else { return }
		redactedView.mode = mode
	}

	func choosePhoto() {
		haptics.prepare()
		PhotosController.choosePhoto(context: self) { [weak self] image in
			self?.image = image
		}
	}

	func chooseLastPhoto() {
		haptics.prepare()
		PhotosController.getLastPhoto(context: self) { [weak self] image in
			self?.image = image
		}
	}

	func takePhoto() {
		haptics.prepare()
		PhotosController.takePhoto(context: self) { [weak self] image in
			self?.image = image
		}
	}
}
