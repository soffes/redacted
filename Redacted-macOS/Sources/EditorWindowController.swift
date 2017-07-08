//
//  EditorWindowController.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit
import RedactedKit
import X

final class EditorWindowController: NSWindowController {

	// MARK: - Types

	fileprivate enum MenuItem: Int {
		case open = 900
		case deleteRedaction = 901
		case pasteImage = 902
	}

	// MARK: - Properties

	@IBOutlet var toolbar: NSToolbar!
	@IBOutlet var modeItem: NSToolbarItem!
	@IBOutlet var modeControl: NSSegmentedControl!
	@IBOutlet var touchBarModeControl: NSSegmentedControl!
	@IBOutlet var clearItem: NSToolbarItem!
	@IBOutlet var shareItem: NSToolbarItem!

	var editorViewController: EditorViewController!
	var modeIndex: Int = 0 {
		didSet {
			invalidateRestorableState()

			modeControl.selectedSegment = modeIndex
			touchBarModeControl.selectedSegment = modeIndex

			if let mode = RedactionType(rawValue: modeIndex) {
				editorViewController.redactedView.mode = mode
			}
		}
	}

	fileprivate var imageURL: URL? = nil
	fileprivate let _undoManager = UndoManager()


	// MARK: - Initializers

	deinit {
		NotificationCenter.default.removeObserver(self)
	}


	// MARK: - NSResponder

	override func encodeRestorableState(with coder: NSCoder) {
		super.encodeRestorableState(with: coder)
		coder.encode(modeControl.selectedSegment, forKey: "modeIndex")
	}


	override func restoreState(with coder: NSCoder) {
		super.restoreState(with: coder)
		modeIndex = coder.decodeInteger(forKey: "modeIndex")
	}

	override func performKeyEquivalent(with event: NSEvent) -> Bool {
		// Support ⌘W
		if (event.characters ?? "") == "w" && event.modifierFlags.contains(.command) {
			window?.close()
			return true
		}

		return super.performKeyEquivalent(with: event)
	}


	// MARK: - NSWindowController

	override func windowDidLoad() {
		super.windowDidLoad()

		window?.titleVisibility = .hidden
		window?.delegate = self

		editorViewController = contentViewController as? EditorViewController
		editorViewController.redactedView.customUndoManager = window?.undoManager

		if let view = editorViewController.view as? ImageDragDestinationView {
			view.delegate = self
		}

		// Notifications
		NotificationCenter.default.addObserver(self, selector: #selector(imageDidChange), name: NSNotification.Name(rawValue: EditorViewController.imageDidChangeNotification), object: nil)
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		// Setup share button
		if let button = shareItem.view as? NSButton {
			button.sendAction(on: .leftMouseDown)
		}

		// Setup toolbar
		modeItem.label = string("MODE")
		modeItem.paletteLabel = modeItem.label

		modeControl.setToolTip(toolTip: string("PIXELATE"), forSegment: 0)
		modeControl.setToolTip(toolTip: string("BLUR"), forSegment: 1)
		modeControl.setToolTip(toolTip: string("BLACK_BAR"), forSegment: 2)

		clearItem.label = string("CLEAR")
		clearItem.paletteLabel = string("CLEAR_IMAGE")
		clearItem.toolTip = clearItem.paletteLabel

		shareItem.label = string("SHARE")
		shareItem.paletteLabel = shareItem.label
		shareItem.toolTip = shareItem.paletteLabel

		// For some reason, this only works in `awakeFromNib`. Oh AppKit.
		validateToolbar()
	}


	// MARK: - Actions

	func openDocument(_ sender: Any?) {
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.canChooseDirectories = false
		openPanel.canCreateDirectories = false
		openPanel.canChooseFiles = true
		openPanel.beginSheetModal(for: window!) { [weak self] result in
			if let url = openPanel.url, result == NSFileHandlingPanelOKButton {
				DispatchQueue.main.async {
					self?.open(url: url, source: "Open")
				}
			}
		}
	}

	func save(_ sender: Any?) {
		if let URL = imageURL, let image = editorViewController.renderedImage {
			save(image: image, toURL: URL)
		} else {
			export(sender)
		}
	}

	func export(_ sender: Any?) {
		if let window = window, let image = editorViewController.renderedImage {
			let savePanel = NSSavePanel()
			savePanel.allowedFileTypes = ["png"]
			savePanel.beginSheetModal(for: window) { [weak self] in
				if $0 == NSFileHandlingPanelOKButton {
					if let url = savePanel.url {
						self?.save(image: image, toURL: url)
					}
				}
			}
		}
	}

	func copy(_ sender: Any?) {
		if let image = editorViewController.renderedImage {
			let pasteboard = NSPasteboard.general()
			pasteboard.clearContents()
			pasteboard.writeObjects([image])

			mixpanel.track(event: "Share image", parameters: [
				"service": "Copy",
				"redactions_count": editorViewController.redactedView.redactions.count
			])
		}
	}

	func paste(_ sender: Any?) {
		if let data = NSPasteboard.general().data(forType: String(kUTTypeTIFF)) {
			editorViewController.image = NSImage(data: data)

			mixpanel.track(event: "Import image", parameters: [
				"source": "Paste image"
			])
		}
	}

	func delete(_ sender: Any?) {
		editorViewController.redactedView.deleteRedaction()
	}

	override func selectAll(_ sender: Any?) {
		editorViewController.redactedView.selectAllRedactions()
	}

	@IBAction func changeMode(_ sender: NSSegmentedControl) {
		modeIndex = sender.selectedSegment
	}

	@IBAction func clearImage(_ sender: Any?) {
		editorViewController.image = nil
	}

	@IBAction func shareImage(_ sender: Any?) {
		editorViewController.shareImage(fromView: shareItem.view!)
	}

	@IBAction func usePixelate(_ sender: Any?) {
		modeIndex = RedactionType.pixelate.rawValue
	}

	@IBAction func useBlur(_ sender: Any?) {
		modeIndex = RedactionType.blur.rawValue
	}

	@IBAction func useBlackBar(_ sender: Any?) {
		modeIndex = RedactionType.blackBar.rawValue
	}


	// MARK: - Public

	@discardableResult func open(url: URL?, source: String) -> Bool {
		if let url = url, let image = NSImage(contentsOf: url) {
			imageURL = url
			NSDocumentController.shared().noteNewRecentDocumentURL(url)
			editorViewController.image = image

			mixpanel.track(event: "Import image", parameters: [
				"source": source
			])

			return true
		}
		return false
	}


	// MARK: - Private

	@objc private func imageDidChange(notification: NSNotification?) {
		NSRunningApplication.current().activate(options: .activateIgnoringOtherApps)
		validateToolbar()
	}

	@discardableResult private func save(image: Image, toURL url: URL) -> Bool {
		if let cgImage = image.cgImage {
			let rep = NSBitmapImageRep(cgImage: cgImage)
			if let data = rep.representation(using: .PNG, properties: [:]) {
				try? data.write(to: url)
				return true
			}
		}
		return false
	}
}


extension EditorWindowController: NSWindowDelegate {
	func windowWillClose(_ notification: Notification) {
		NSApplication.shared().terminate(window)
	}

	func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
		return _undoManager
	}
}


// NSToolbarValidation
extension EditorWindowController {
	fileprivate func validateToolbar() {
		for item in toolbar.items {
			item.isEnabled = validateToolbarItem(item)
		}
	}

	override func validateToolbarItem(_ theItem: NSToolbarItem) -> Bool {
		if ["mode", "clear", "share"].contains(theItem.itemIdentifier) {
			return editorViewController.image != nil
		}
		return true
	}
}


// NSMenuItemValidation
extension EditorWindowController {
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		if menuItem.tag == MenuItem.open.rawValue || menuItem.tag == MenuItem.pasteImage.rawValue {
			return true
		}

		if menuItem.tag == MenuItem.deleteRedaction.rawValue {
			return editorViewController.redactedView.selectionCount > 0
		}

		return editorViewController.image != nil
	}
}


extension EditorWindowController: ImageDragDestinationViewDelegate {
	func imageDragDestinationView(_ view: ImageDragDestinationView, didAcceptImage image: NSImage) {
		imageURL = nil
		editorViewController.image = image

		mixpanel.track(event: "Import image", parameters: [
			"source": "Drag image"
		])
	}

	func imageDragDestinationView(_ view: ImageDragDestinationView, didAcceptURL url: URL) {
		open(url: url, source: "Drag URL")
	}
}

@available(OSX 10.12.2, *)
extension EditorWindowController: NSSharingServicePickerTouchBarItemDelegate {
	func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
		guard let image = editorViewController.renderedImage else { return [] }
		return [image]
	}
}

extension EditorWindowController: NSSharingServicePickerDelegate {
	func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
		editorViewController.sharingServicePicker(sharingServicePicker, didChoose: service)
	}
}
