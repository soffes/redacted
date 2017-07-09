//
//  OpenViewController+Actions.swift
//  Redacted
//
//  Created by Sam Soffes on 7/9/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

extension OpenViewController {
	func usePixelate() {
		editorViewController.usePixelate()
	}

	func useBlur() {
		editorViewController.useBlur()
	}

	func useBlackBar() {
		editorViewController.useBlackBar()
	}

	func deleteRedaction() {
		editorViewController.deleteRedaction()
	}

	func selectAllRedactions() {
		editorViewController.selectAllRedactions()
	}

	func undoEdit() {
		editorViewController.undoManager?.undo()
	}

	func redoEdit() {
		editorViewController.undoManager?.redo()
	}

	#if !REDACTED_APP_EXTENSION
		func share() {
			editorViewController.share()
		}
	#endif

	func copyImage() {
		editorViewController.copyImage()
	}

	#if !REDACTED_APP_EXTENSION
		func saveImage() {
			editorViewController.saveImage()
		}
	#endif

	func clear() {
		editorViewController.clear()
	}
}
