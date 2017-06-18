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

class EditorViewController: UIViewController {

	// MARK: - Properties

	let redactedView: RedactedView = {
		let view = RedactedView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let toolbarView: ToolbarView = {
		let view = ToolbarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private var toolbarBottomConstraint: NSLayoutConstraint? {
		willSet {
			toolbarBottomConstraint?.isActive = false
		}

		didSet {
			toolbarBottomConstraint?.isActive = true
		}
	}

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

	let _undoManager = UndoManager()

	let haptics = UISelectionFeedbackGenerator()

	private let toolTipView: ToolTipView = {
		let view = ToolTipView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.textLabel.text = localizedString("TAP_AND_DRAG")
		return view
	}()

	private var toolTipBottomConstraint: NSLayoutConstraint? {
		willSet {
			toolTipBottomConstraint?.isActive = false
		}

		didSet {
			toolTipBottomConstraint?.isActive = true
		}
	}


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
				UIKeyCommand(input: "c", modifierFlags: .command, action: #selector(copyImage), discoverabilityTitle: string("COPY_IMAGE")),
				UIKeyCommand(input: "s", modifierFlags: .command, action: #selector(saveImage), discoverabilityTitle: string("SAVE")),
			]

			if _undoManager.canUndo {
				let title = String(format: localizedString("UNDO_FORMAT"), _undoManager.undoActionName)
				commands.append(UIKeyCommand(input: "z", modifierFlags: .command, action: #selector(undoEdit), discoverabilityTitle: title))
			}

			if _undoManager.canRedo {
				let title = String(format: localizedString("REDO_FORMAT"), _undoManager.redoActionName)
				commands.append(UIKeyCommand(input: "z", modifierFlags: [.command, .shift], action: #selector(redoEdit), discoverabilityTitle: title))
			}

		} else {
			commands += [
				UIKeyCommand(input: "o", modifierFlags: .command, action: #selector(choosePhoto), discoverabilityTitle: localizedString("CHOOSE_PHOTO")),
				UIKeyCommand(input: "o", modifierFlags: [.command, .shift], action: #selector(chooseLastPhoto), discoverabilityTitle: localizedString("CHOOSE_LAST_PHOTO")),
				UIKeyCommand(input: "o", modifierFlags: [.command, .alternate], action: #selector(takePhoto), discoverabilityTitle: localizedString("TAKE_PHOTO")),
			]

			if UIPasteboard.general.hasImage {
				commands.append(UIKeyCommand(input: "v", modifierFlags: .command, action: #selector(pastePhoto), discoverabilityTitle: localizedString("PASTE_PHOTO")))
			}
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
		emptyView.pastePhotoButton.addTarget(self, action: #selector(pastePhoto), for: .primaryActionTriggered)

		view.addSubview(emptyView)

		toolbarView.modeControl.addTarget(self, action: #selector(modeDidChange), for: .primaryActionTriggered)
		toolbarView.clearButton.addTarget(self, action: #selector(clear), for: .primaryActionTriggered)
		toolbarView.shareButton.addTarget(self, action: #selector(share), for: .primaryActionTriggered)
		view.addSubview(toolbarView)

		let toolbarTopConstraint = toolbarView.topAnchor.constraint(equalTo: view.bottomAnchor)
		toolbarTopConstraint.priority = UILayoutPriorityDefaultLow

		NSLayoutConstraint.activate([
			redactedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			redactedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			redactedView.topAnchor.constraint(equalTo: view.topAnchor),
			redactedView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor),

			emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			toolbarTopConstraint
		])

		let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
		view.addGestureRecognizer(pan)

		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		view.addGestureRecognizer(tap)

		let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTapped))
		twoFingerTap.numberOfTouchesRequired = 2
		view.addGestureRecognizer(twoFingerTap)

		view.layoutIfNeeded()
		imageDidChange()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}


	// MARK: - Private

	private func imageDidChange() {
		redactedView.originalImage = image

		let hasImage = image != nil
		emptyView.isHidden = hasImage
		toolbarView.isEnabled = hasImage

		if hasImage {
			haptics.selectionChanged()

			toolbarBottomConstraint = toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

			if !UserDefaults.standard.bool(forKey: "CreatedRedaction") {
				showTutorial()
			}
		} else {
			hideTutorial()
			toolbarBottomConstraint = nil
		}

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2, options: [], animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}

	private func setupTutorial() {
		if toolTipView.superview != nil {
			return
		}

		view.addSubview(toolTipView)

		let bottomConstraint = toolTipView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 64)
		bottomConstraint.priority = UILayoutPriorityDefaultLow

		NSLayoutConstraint.activate([
			toolTipView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			bottomConstraint
		])

		view.layoutIfNeeded()
	}

	private func showTutorial() {
		setupTutorial()

		toolTipBottomConstraint = toolTipView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: -16)

		UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.2, options: [], animations: { [weak self] in
			self?.view.layoutIfNeeded()
		}, completion: nil)
	}

	func hideTutorial() {
		if toolTipView.superview == nil {
			return
		}

		toolTipBottomConstraint = nil

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.2, options: [], animations: { [weak self] in
			self?.view.layoutIfNeeded()
		}, completion: { [weak self] _ in
			self?.toolTipView.removeFromSuperview()
		})
	}
}
