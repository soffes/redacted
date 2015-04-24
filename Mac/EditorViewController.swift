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

	var redactedLayer: RedactedLayer {
		return redactedView.redactedLayer
	}
	
	var image: NSImage? {
		didSet {
			redactedLayer.originalImage = image
			NSNotificationCenter.defaultCenter().postNotificationName(self.dynamicType.imageDidChangeNotification, object: image)

			placeholderLabel.hidden = image != nil
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

		view.addSubview(toolTipView)
		view.addConstraint(NSLayoutConstraint(item: toolTipView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: toolTipView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -32))
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
}


extension EditorViewController: NSSharingServicePickerDelegate {
	func sharingServicePicker(sharingServicePicker: NSSharingServicePicker, didChooseSharingService service: NSSharingService) {
		if let service = service.title {
			mixpanel.track("Share image", parameters: [
				"service": service
			])
		}
	}
}