//
//  WindowController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class WindowController: NSWindowController {

	// MARK: - Properties

	@IBOutlet var toolbar: NSToolbar!
	@IBOutlet var shareItem: NSToolbarItem!
	@IBOutlet var modeControl: NSSegmentedControl!

	var editorViewController: EditorViewController!


	// MARK: - Initializers

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


	// MARK: - NSWindowController

	override func windowDidLoad() {
		super.windowDidLoad()

		window?.delegate = self

		editorViewController = contentViewController as? EditorViewController

		if let view = editorViewController.view as? ImageDragDestinationView {
			view.delegate = self
		}

		// Setup share button
		if let button = shareItem.view as? NSButton {
			button.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
		}

		// Validate toolbar
		validateToolbar()

		// Notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDidChange:", name: EditorViewController.imageDidChangeNotification, object: nil)
	}


	// MARK: - Actions

	func openDocument(sender: AnyObject?) {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = false
		openPanel.canCreateDirectories = false
		openPanel.canChooseFiles = true
		openPanel.beginSheetModalForWindow(window!) { result in
			if let URL = openPanel.URL where result == NSFileHandlingPanelOKButton {
				self.openURL(URL)
			}
		}
	}

	func save(sender: AnyObject?) {
		if let window = window, image = editorViewController.renderedImage {
			let savePanel = NSSavePanel()
			savePanel.allowedFileTypes = ["png"]
			savePanel.beginSheetModalForWindow(window) {
				if $0 == NSFileHandlingPanelOKButton {
					if let path = savePanel.URL?.path, cgImage = image.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeUnretainedValue() {
						let rep = NSBitmapImageRep(CGImage: cgImage)
						let data = rep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [NSObject: AnyObject]())
						data?.writeToFile(path, atomically: true)
					}
				}
			}
		}
	}

	func copy(sender: AnyObject?) {
		if let image = editorViewController.renderedImage {
			let pasteboard = NSPasteboard.generalPasteboard()
			pasteboard.clearContents()
			pasteboard.writeObjects([image])
		}
	}

	func paste(sender: AnyObject?) {
		if let data = NSPasteboard.generalPasteboard().dataForType(String(kUTTypeTIFF)) {
			editorViewController.image = NSImage(data: data)
		}
	}

	@IBAction func changeMode(sender: AnyObject?) {
		if let mode = RedactionType(rawValue: modeControl.integerValue) where editorViewController.mode != mode {
			editorViewController.mode = mode
		}
	}

	@IBAction func clearImage(sender: AnyObject?) {
		editorViewController.image = nil
	}

	@IBAction func shareImage(sender: AnyObject?) {
		editorViewController.shareImage(fromView: shareItem.view!)
	}


	// MARK: - Public

	func openURL(URL: NSURL?) -> Bool {
		if let URL = URL, image = NSImage(contentsOfURL: URL) {
			NSDocumentController.sharedDocumentController().noteNewRecentDocumentURL(URL)
			self.editorViewController.image = image
			return true
		}
		return false
	}


	// MARK: - Private

	func imageDidChange(notification: NSNotification?) {
		validateToolbar()

//		if let window = window, image = editorViewController.image {
//			var frame = window.frame
//			frame.size.height = round(frame.size.width) * image.size.height / image.size.width
//			window.setFrame(frame, display: true)
//		}
	}
}


extension WindowController: NSWindowDelegate {
	func windowWillClose(notification: NSNotification) {
		NSApplication.sharedApplication().terminate(window)
	}

//	func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
//		var size = frameSize
//		if let image = editorViewController.image {
//			size.height = round(size.width) * image.size.height / image.size.width
//		}
//		return size
//	}
}


extension WindowController {
	private func validateToolbar() {
		if let items = toolbar.visibleItems as? [NSToolbarItem] {
			for item in items {
				item.enabled = validateToolbarItem(item)
			}
		}
	}

	override func validateToolbarItem(theItem: NSToolbarItem) -> Bool {
		if contains(["mode", "clear", "share"], theItem.itemIdentifier) {
			return editorViewController.image != nil
		}
		return true
	}
}


extension WindowController: ImageDragDestinationViewDelegate {
	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptImage image: NSImage) {
		editorViewController.image = image
		NSApplication.sharedApplication().activateIgnoringOtherApps(true)
	}

	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptURL URL: NSURL) {
		openURL(URL)
		NSApplication.sharedApplication().activateIgnoringOtherApps(true)
	}
}
