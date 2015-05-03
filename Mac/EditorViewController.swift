//
//  EditorViewController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import RedactedKit

class EditorViewController: NSViewController {

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

	var redactedLayer: RedactedLayer {
		return redactedView.redactedLayer
	}
	
	var image: NSImage? {
		didSet {
			redactedLayer.originalImage = image
			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.imageDidChangeNotification, object: image)

			placeholderLabel.hidden = image != nil

			if image == nil {
				return
			}

			showTutorial()
		}
	}

	var renderedImage: NSImage? {
		return redactedLayer.renderedImage()
	}


	// MARK: - NSViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		let pan = NSPanGestureRecognizer(target: self, action: "panned:")
		view.addGestureRecognizer(pan)

		let click = NSClickGestureRecognizer(target: self, action: "clicked:")
		view.addGestureRecognizer(click)

		let shiftClick = ModifierClickGestureRecognizer(target: self, action: "shiftClicked:")
		shiftClick.modifier = .ShiftKeyMask
		view.addGestureRecognizer(shiftClick)

		placeholderLabel.stringValue = string("DRAG_TO_GET_STARTED")

		if !NSUserDefaults.standardUserDefaults().boolForKey("CreatedRedaction") {
			setupTutorial()
		}
	}


	// MARK: - Actions

	func shareImage(fromView sender: NSView) {
		if let image = renderedImage {
			let sharingServicePicker = NSSharingServicePicker(items: [image])
			sharingServicePicker.delegate = self
			let edge = NSRectEdge(CGRectEdge.MinYEdge.rawValue)
			sharingServicePicker.showRelativeToRect(NSZeroRect, ofView: sender, preferredEdge: edge)
		}
	}

	func panned(sender: NSPanGestureRecognizer) {
		redactedLayer.drag(point: sender.locationInView(view), state: sender.state)

		if sender.state == .Ended && redactedLayer.redactions.count > 0 {
			hideTutorial()
		}
	}

	func clicked(sender: NSClickGestureRecognizer) {
		if sender.state == .Ended {
			redactedLayer.tap(point: sender.locationInView(view))
		}
	}

	func shiftClicked(sender: NSClickGestureRecognizer) {
		if sender.state == .Ended {
			redactedLayer.tap(point: sender.locationInView(view), exclusive: false)
		}
	}


	// MARK: - Private

	private func setupTutorial() {
		view.addSubview(toolTipView)
		view.addConstraint(NSLayoutConstraint(item: toolTipView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))

		let constraint = NSLayoutConstraint(item: toolTipView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 64)
		view.addConstraint(constraint)
		toolTipBottomConstraint = constraint
	}

	private func showTutorial() {
		if let constraint = toolTipBottomConstraint {
			constraint.constant = -16
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.3
				context.allowsImplicitAnimation = true
				self.view.layoutSubtreeIfNeeded()
			}, completionHandler: nil)
		}
	}

	private func hideTutorial() {
		if let constraint = toolTipBottomConstraint {
			constraint.constant = 64
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = 0.3
				context.allowsImplicitAnimation = true
				self.view.layoutSubtreeIfNeeded()
				self.toolTipView.alphaValue = 0
			}, completionHandler: {
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: "CreatedRedaction")
				self.toolTipBottomConstraint = nil
				self.toolTipView.removeFromSuperview()
			})
		}
	}
}


extension EditorViewController: NSSharingServicePickerDelegate {
	func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, didChooseSharingService service: NSSharingService) {
		if let service = service.title {
			mixpanel.track("Share image", parameters: [
				"service": service,
				"redactions_count": redactedLayer.redactions.count
			])
		}
	}
}
