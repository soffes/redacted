//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import RedactedKit

final class EditorViewController: NSViewController {

	// MARK: - Constants

	class var imageDidChangeNotification: String {
		return "EditorViewController.imageDidChangeNotification"
	}


	// MARK: - Properties

	@IBOutlet var redactedView: RedactedView!
	@IBOutlet var placeholderLabel: NSTextField!

	let toolTipView: ToolTipView = {
		let view = ToolTipView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.textLabel.stringValue = string("CLICK_AND_DRAG")
		return view
	}()

	private var toolTipBottomConstraint: NSLayoutConstraint?
	
	var image: NSImage? {
		didSet {
			redactedView.originalImage = image
			NotificationCenter.default.post(name: NSNotification.Name(rawValue: type(of: self).imageDidChangeNotification), object: image)

			placeholderLabel.isHidden = image != nil

			if image == nil {
				return
			}

			showTutorial()
		}
	}

	var renderedImage: NSImage? {
		return redactedView.renderedImage()
	}


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let pan = NSPanGestureRecognizer(target: self, action: #selector(panned))
		view.addGestureRecognizer(pan)

		let click = NSClickGestureRecognizer(target: self, action: #selector(clicked))
		view.addGestureRecognizer(click)

		let shiftClick = ModifierClickGestureRecognizer(target: self, action: #selector(shiftClicked))
		shiftClick.modifier = .shift
		view.addGestureRecognizer(shiftClick)

		placeholderLabel.stringValue = string("DRAG_TO_GET_STARTED")

		if !UserDefaults.standard.bool(forKey: "CreatedRedaction") {
			setupTutorial()
		}
	}


	// MARK: - Actions

	func shareImage(fromView sender: NSView) {
		if let image = renderedImage {
			let sharingServicePicker = NSSharingServicePicker(items: [image])
			sharingServicePicker.delegate = self
			sharingServicePicker.show(relativeTo: CGRect.zero, of: sender, preferredEdge: .minY)
		}
	}

	func panned(sender: NSPanGestureRecognizer) {
		redactedView.drag(point: sender.location(in: view), state: sender.state)

		if sender.state == .ended && redactedView.redactions.count > 0 {
			hideTutorial()
		}
	}

	func clicked(sender: NSClickGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view))
		}
	}

	func shiftClicked(sender: NSClickGestureRecognizer) {
		if sender.state == .ended {
			redactedView.tap(point: sender.location(in: view), exclusive: false)
		}
	}


	// MARK: - Private

	private func setupTutorial() {
		view.addSubview(toolTipView)

		let bottomConstraint = toolTipView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 64)
		toolTipBottomConstraint = bottomConstraint

		NSLayoutConstraint.activate([
			toolTipView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			bottomConstraint
		])
	}

	private func showTutorial() {
		if let constraint = toolTipBottomConstraint {
			constraint.constant = -16
			NSAnimationContext.runAnimationGroup({ [weak self] context in
				context.duration = 0.3
				context.allowsImplicitAnimation = true
				self?.view.layoutSubtreeIfNeeded()
			}, completionHandler: nil)
		}
	}

	private func hideTutorial() {
		if let constraint = toolTipBottomConstraint {
			constraint.constant = 64
			NSAnimationContext.runAnimationGroup({ [weak self] context in
				context.duration = 0.3
				context.allowsImplicitAnimation = true
				self?.view.layoutSubtreeIfNeeded()
				self?.toolTipView.alphaValue = 0
			}, completionHandler: { [weak self] in
				UserDefaults.standard.set(true, forKey: "CreatedRedaction")
				self?.toolTipBottomConstraint = nil
				self?.toolTipView.removeFromSuperview()
			})
		}
	}
}


extension EditorViewController: NSSharingServicePickerDelegate {
	func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
		guard let title = service?.title else { return }

		mixpanel.track(event: "Share image", parameters: [
			"service": title,
			"redactions_count": redactedView.redactions.count
		])
	}
}
