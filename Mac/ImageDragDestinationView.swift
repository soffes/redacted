//
//  ImageDragDestinationView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import AppKit

@objc protocol ImageDragDestinationViewDelegate: Any {
	func imageDragDestinationView(_ view: ImageDragDestinationView, didAcceptImage image: NSImage)
	func imageDragDestinationView(_ view: ImageDragDestinationView, didAcceptURL url: URL)
}

final class ImageDragDestinationView: NSView {

	// MARK: - Properties

	@IBOutlet weak var delegate: ImageDragDestinationViewDelegate?

	private let selectionLayer: CALayer = {
		let layer = CALayer()
		layer.borderWidth = 4
		layer.borderColor = NSColor.selectedControlColor.cgColor
		layer.isHidden = true
		return layer
	}()

	fileprivate var showingSelection: Bool = false {
		didSet {
			if showingSelection {
				// Move to front
				CATransaction.begin()
				CATransaction.setDisableActions(true)
				layer?.addSublayer(selectionLayer)
				CATransaction.commit()

				selectionLayer.isHidden = false
			} else {
				selectionLayer.isHidden = true
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
		register(forDraggedTypes: [String(kUTTypeTIFF), NSFilenamesPboardType])
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


// NSDraggingDestination
extension ImageDragDestinationView {
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		if delegate == nil {
			showingSelection = false
			return []
		}

		let pasteboard = sender.draggingPasteboard()
		let workspace = NSWorkspace.shared()
		var accept = false

		if let types = pasteboard.types {
			// TIFF data
			if let data = pasteboard.data(forType: String(kUTTypeTIFF)), types.contains(NSTIFFPboardType), NSImage(data: data) != nil {
				accept = true
			}

			// File path
			if let paths = pasteboard.propertyList(forType: NSFilenamesPboardType) as? [String], let path = paths.first, !accept && types.contains(NSFilenamesPboardType) {
				if let utiType = try? workspace.type(ofFile: path), workspace.type(utiType, conformsToType: String(kUTTypeImage)) {
					accept = true
				}
			}
		}

		showingSelection = accept
		return accept ? .every : []
	}

	override func draggingExited(_ sender: NSDraggingInfo?) {
		showingSelection = false
	}

	override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
		return delegate != nil
	}

	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		showingSelection = false
		if let delegate = delegate {
			let pasteboard = sender.draggingPasteboard()

			// TIFF data
			if let data = pasteboard.data(forType: String(kUTTypeTIFF)), let image = NSImage(data: data) {
				delegate.imageDragDestinationView(self, didAcceptImage: image)
				return true
			}

			// File path
			if let paths = pasteboard.propertyList(forType: NSFilenamesPboardType) as? [String], let path = paths.first {
				let url = URL(fileURLWithPath: path)
				delegate.imageDragDestinationView(self, didAcceptURL: url)
				return true
			}
		}

		return false
	}
}
