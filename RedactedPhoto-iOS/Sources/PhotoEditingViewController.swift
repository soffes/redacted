//
//  PhotoEditingViewController.swift
//  RedactedPhoto-iOS
//
//  Created by Sam Soffes on 7/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import Mixpanel
import RedactedKit

class PhotoEditingViewController: EditorViewController {

	// MARK: - Properties

    fileprivate var input: PHContentEditingInput?

	fileprivate var queuedRedactions = [Redaction]()


	// MARK: - EditorViewController

	override func imageDidChange() {
		super.imageDidChange()

		redactedView.redactions = queuedRedactions
		queuedRedactions.removeAll()
	}
}


extension PhotoEditingViewController: PHContentEditingController {

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
		do {
			_ = try RedactionSerialization.redactions(from: adjustmentData)
			return true
		} catch {
			print("Failed to check adjustment data: \(error)")
			return false
		}
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
		mixpanel.track(event: "Photo Extension Launch")

		input = contentEditingInput

		do {
			if let adjustmentData = contentEditingInput.adjustmentData {
				let redactions = try RedactionSerialization.redactions(from: adjustmentData)
				queuedRedactions = redactions
			}
		} catch {
			print("Failed to deserialize redaction adjustment data: \(error)")
		}

		originalImage = contentEditingInput.displaySizeImage
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // TODO: Update UI to reflect that editing has finished and output is being rendered.

		let redactions = redactedView.redactions
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async { [weak self] in
			// let imageData = self?.renderedImage.flatMap({ UIImageJPEGRepresentation($0, 1) })

			// Get image data
			guard let input = self?.input,
				let url = input.fullSizeImageURL,
				let data = try? Data(contentsOf: url),
				let image = UIImage(data: data)
			else {
				print("Failed to load full size image")
				completionHandler(nil)
				return
			}

			let controller = RedactionsController()
			controller.image = image
			controller.redactions = redactions

			guard let renderedImage = controller.process()?.renderedImage,
				let imageData = UIImageJPEGRepresentation(renderedImage, 1)
			else {
				print("Failed to render full size image")
				completionHandler(nil)
				return
			}

            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: input)

			// Add adjustment data
			do {
				output.adjustmentData = try RedactionSerialization.adjustmentData(for: redactions)
			} catch {
				print("Failed to serialize redaction adjustment data: \(error)")
			}

			// Write image data
			do {
				try imageData.write(to: output.renderedContentURL, options: [])
			} catch {
				print("Failed to write image: \(error)")
				completionHandler(nil)
				return
			}

			mixpanel.track(event: "Photo Extension Save")

            // Commit edit to Photos
            completionHandler(output)
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        return !redactedView.redactions.isEmpty
    }
    
    func cancelContentEditing() {
		mixpanel.track(event: "Photo Extension Cancel")
	}
}
