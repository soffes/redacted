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

class PhotoEditingViewController: EditorViewController, PHContentEditingController {

	// MARK: - Properties

    var input: PHContentEditingInput?


    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
		do {
			let redactions = try RedactionSerialization.redactions(from: adjustmentData)
			return !redactions.isEmpty
		} catch {
			print("Failed to check adjustment data: \(error)")
			return false
		}
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
		mixpanel.track(event: "Photo Extension Launch")

        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput

		originalImage = placeholderImage

//		DispatchQueue.global().async { [weak self] in
//			guard let url = self?.input?.fullSizeImageURL,
//				let data = try? Data(contentsOf: url),
//				let image = UIImage(data: data)
//			else {
//				print("Failed to load full size image")
//				return
//			}
//			self?.originalImage = image
//		}

		do {
			if let adjustmentData = contentEditingInput.adjustmentData {
				let redactions = try RedactionSerialization.redactions(from: adjustmentData)
				redactedView.redactions = redactions
			}
		} catch {
			print("Failed to deserialize redaction adjustment data: \(error)")
		}
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // TODO: Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async { [weak self] in
			// Get image data
			guard let input = self?.input,
				let imageData = self?.renderedImage.flatMap({ UIImageJPEGRepresentation($0, 1) })
			else {
				completionHandler(nil)
				return
			}

            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: input)

			if let redactions = self?.redactedView.redactions, !redactions.isEmpty {
				// Add adjustment data
				do {
					output.adjustmentData = try RedactionSerialization.adjustmentData(for: redactions)
				} catch {
					print("Failed to serialize redaction adjustment data: \(error)")
				}
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
