import Photos
import PhotosUI
import RedactedKit
import UIKit

class PhotoEditingViewController: EditorViewController, PHContentEditingController {

	// MARK: - UIViewController

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		becomeFirstResponder()
	}

	// MARK: - PHContentEditingController

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
		return RedactionSerialization.canHandle(adjustmentData)
    }

    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
		input = contentEditingInput
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
				let imageData = renderedImage.jpegData(compressionQuality: 1)
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

            // Commit edit to Photos
            completionHandler(output)
        }
    }

    var shouldShowCancelConfirmation: Bool {
        return !redactedView.redactions.isEmpty
    }

    func cancelContentEditing() {}
}
