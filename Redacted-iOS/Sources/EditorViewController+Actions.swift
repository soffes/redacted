import UIKit
import RedactedKit

#if !REDACTED_APP_EXTENSION
	import SVProgressHUD
#endif

extension EditorViewController {
	@objc func usePixelate() {
		toolbarView.modeControl.selectedIndex = 0
		modeDidChange()
	}

	@objc func useBlur() {
		toolbarView.modeControl.selectedIndex = 1
		modeDidChange()
	}

	@objc func useBlackBar() {
		toolbarView.modeControl.selectedIndex = 2
		modeDidChange()
	}

	@objc func deleteRedaction() {
		redactedView.deleteRedaction()
	}

	@objc func selectAllRedactions() {
		redactedView.selectAllRedactions()
	}

	@objc func undoEdit() {
		_undoManager.undo()
	}

	@objc func redoEdit() {
		_undoManager.redo()
	}

	#if !REDACTED_APP_EXTENSION
		@objc func share() {
			guard let originalImage = originalImage else { return }

			let item = ImageActivityItemProvider(originalImage: originalImage, redactions: redactedView.redactions)

			let viewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
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
				presentationController.sourceView = toolbarView.shareButton
			}

			present(viewController, animated: true)
		}
	#endif

	@objc func copyImage() {
		UIPasteboard.general.image = renderedImage

		mixpanel.track(event: "Share image", parameters: [
			"service": "Copy",
			"redactions_count": redactedView.redactions.count
		])
	}

	#if !REDACTED_APP_EXTENSION
		@objc func saveImage() {
			PhotosController.savePhoto(context: self, photoProvider: { [weak self] in return self?.renderedImage })

			mixpanel.track(event: "Share image", parameters: [
				"service": "Save",
				"redactions_count": redactedView.redactions.count
			])
		}
	#endif

	@objc func panned(_ sender: UIPanGestureRecognizer) {
		redactedView.drag(point: sender.location(in: view), state: sender.state)

		if sender.state == .ended && redactedView.redactions.count > 0 {
			hideTutorial()
			Preferences.shared.completedTutorial = true
		}
	}

	@objc func tapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view))
		}
	}

	@objc func twoFingerTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view), exclusive: false)
		}
	}

	@objc func longPressed(_ sender: UILongPressGestureRecognizer) {
		if sender.state != .began {
			return
		}
		
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

	@objc func clear() {
		originalImage = nil
	}

	@objc func modeDidChange() {
		guard let mode = RedactionType(rawValue: toolbarView.modeControl.selectedIndex) else { return }
		redactedView.mode = mode
	}
}
