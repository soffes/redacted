//
//  ImageDragDestinationView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa

@objc protocol ImageDragDestinationViewDelegate: AnyObject {
	func imageDragDestinationView(imageDragDestinationView: ImageDragDestinationView, didAcceptImage image: NSImage)
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

	override func viewDidMoveToSuperview() {
		if superview != nil {
			registerForDraggedTypes([NSFilenamesPboardType]) // TODO: Add NSTIFFPboardType
		}
	}
	

	// MARK: - Private

	private func initialize() {
		wantsLayer = true
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

		if let types = pasteboard.types as? [String], paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] where contains(types, NSFilenamesPboardType) {
			for path in paths {
				if let utiType = workspace.typeOfFile(path, error: nil) where !workspace.type(utiType, conformsToType: String(kUTTypeImage)) {
					showingSelection = false
					return NSDragOperation.None
				}
			}
		}

		showingSelection = true
		return NSDragOperation.Every
	}

	override func draggingExited(sender: NSDraggingInfo?) {
		showingSelection = false
	}

	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		return delegate != nil
	}

	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		showingSelection = false

		let pasteboard = sender.draggingPasteboard()
		if let paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String], path = paths.first, URL = NSURL(fileURLWithPath: path) {
			if let delegate = delegate, image = NSImage(contentsOfURL: URL) {
				delegate.imageDragDestinationView(self, didAcceptImage: image)
			}
		}
		return true
	}
}
