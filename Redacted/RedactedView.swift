//
//  RedactedView.swift
//  Redacted
//
//  Created by Sam Soffes on 3/23/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Cocoa
import RedactedKit

class RedactedView: NSView {

	// MARK: - Properties

	var image: NSImage? {
		didSet {
			imageLayer.contents = image
		}
	}

	private let imageLayer = CALayer()
	private let dragHighlightLayer: CALayer = {
		let layer = CALayer()
		layer.borderWidth = 4
		layer.borderColor = NSColor.selectedControlColor().CGColor
		layer.hidden = true
		return layer
	}()


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

	override var flipped: Bool {
		return true
	}

	override func layout() {
		super.layout()
		layoutLayers()
	}


	// MARK: - Private

	private func initialize() {
		wantsLayer = true

		registerForDraggedTypes([NSFilenamesPboardType])

		imageLayer.contentsGravity = kCAGravityResizeAspect

		if let layer = layer {
			layer.addSublayer(imageLayer)
			layer.addSublayer(dragHighlightLayer)
			layoutLayers()
		}
	}

	private func layoutLayers() {
		if let layer = layer {
			CATransaction.begin()
			CATransaction.setDisableActions(true)
			imageLayer.frame = layer.bounds
			dragHighlightLayer.frame = layer.bounds
			CATransaction.commit()
		}
	}
}


extension RedactedView: NSDraggingDestination {

	override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
//		NSPasteboard *pboard = [sender draggingPasteboard];
//
//		if ([[pboard types] containsObject:NSFilenamesPboardType]) {
//
//			NSArray *paths = [pboard propertyListForType:NSFilenamesPboardType];
//			for (NSString *path in paths) {
//				NSError *error = nil;
//				NSString *utiType = [[NSWorkspace sharedWorkspace]
//					typeOfFile:path error:&error];
//				if (![[NSWorkspace sharedWorkspace]
//					type:utiType conformsToType:(id)kUTTypeMovie]) {
//
//						self.dragHighlightLayer.hidden = YES;
//						return NSDragOperationNone;
//				}
//			}
//		}

		dragHighlightLayer.hidden = false
		return NSDragOperation.Every
	}

	override func draggingExited(sender: NSDraggingInfo?) {
		dragHighlightLayer.hidden = true
	}

	override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
		return true
	}

	override func performDragOperation(sender: NSDraggingInfo) -> Bool {
		dragHighlightLayer.hidden = true

		let pasteboard = sender.draggingPasteboard()
		if let paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String], path = paths.first, URL = NSURL(fileURLWithPath: path) {
			image = NSImage(contentsOfURL: URL)
		}
		return true
	}
}

