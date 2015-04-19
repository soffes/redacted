//
//  ImageDragDestinationView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

@objc protocol ImageDragDestinationViewDelegate: AnyObject {
	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptImage image: NSImage)
	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptURL URL: NSURL)
}

class ImageDragDestinationView: NSView {

	// MARK: - Properties

	@IBOutlet weak var delegate: ImageDragDestinationViewDelegate?

	private let selectionLayer: CALayer = {
		let layer = CALayer()
		layer.borderWidth = 4
		layer.borderColor = NSColor.selectedControlColor().CGColor
		layer.hidden = true
		return layer
	}()

	private var showingSelection: Bool = false {
		didSet {
			if showingSelection {
				// Move to front
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				layer?.addSublayer(selectionLayer)
				CATransaction.commit()

				selectionLayer.hidden = false
			} else {
				selectionLayer.hidden = true
			}
		}
	}
	

	// MARK: - Initializers

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		initialize()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		initialize()
	}


	// MARK: - NSView

	override func layout() {
		super.layout()
		layoutLayers()
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true
		registerForDraggedTypes([String(kUTTypeTIFF), NSFilenamesPboardType])
	}

	private func layoutLayers() {
		if let layer = layer {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			selectionLayer.frame = layer.bounds
			CATransaction.commit()
		}
	}
}


extension ImageDragDestinationView: NSDraggingDestination {
	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
		if delegate == nil {
			showingSelection = false
			return NSDragOperation.None
		}

		let pasteboard = sender.draggingPasteboard()
		let workspace = NSWorkspace.sharedWorkspace()
		var accept = false

		if let types = pasteboard.types as? [String] {
			// TIFF data
			if let data = pasteboard.dataForType(String(kUTTypeTIFF)), image = NSImage(data: data) where contains(types, NSTIFFPboardType) {
				accept = true
			}

			// File path
			if let paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String], path = paths.first where !accept && contains(types, NSFilenamesPboardType) {
				if let utiType = workspace.typeOfFile(path, error: nil) where workspace.type(utiType, conformsToType: String(kUTTypeImage)) {
					accept = true
				}
			}
		}

		showingSelection = accept
		return accept ? NSDragOperation.Every : NSDragOperation.None
	}

	override func draggingExited(sender: NSDraggingInfo?) {
		showingSelection = false
	}

	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		return delegate != nil
	}

	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		showingSelection = false
		if let delegate = delegate {
			let pasteboard = sender.draggingPasteboard()

			// TIFF data
			if let data = pasteboard.dataForType(String(kUTTypeTIFF)), image = NSImage(data: data) {
				delegate.imageDragDestinationView(self, didAcceptImage: image)
				return true
			}

			// File path
			if let paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String], path = paths.first, URL = NSURL(fileURLWithPath: path) {
				delegate.imageDragDestinationView(self, didAcceptURL: URL)
				return true
			}
		}

		return false
	}
}
