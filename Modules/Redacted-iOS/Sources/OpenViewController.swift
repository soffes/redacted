import AVFoundation
import Photos
import RedactedKit
import UIKit
import X

final class OpenViewController: UIViewController {

	// MARK: - Properties

	private let emptyView: EmptyView = {
		let view = EmptyView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let haptics = UISelectionFeedbackGenerator()

	let editorViewController = EditorViewController()

	private var hasImage: Bool {
		return editorViewController.originalImage != nil
	}

	private let activityIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .white)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.hidesWhenStopped = true
		return view
	}()

	// MARK: - UIResponder

	override var undoManager: UndoManager? {
		return editorViewController.undoManager
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var keyCommands: [UIKeyCommand]? {
		var commands = super.keyCommands ?? []

		if !hasImage {
			commands += [
				UIKeyCommand(input: "o", modifierFlags: .command, action: #selector(choosePhoto),
                             discoverabilityTitle: LocalizedString.choosePhoto.string),
				UIKeyCommand(input: "o", modifierFlags: [.command, .shift], action: #selector(chooseLastPhoto),
                             discoverabilityTitle: LocalizedString.chooseLastPhoto.string),
				UIKeyCommand(input: "o", modifierFlags: [.command, .alternate], action: #selector(takePhoto),
                             discoverabilityTitle: LocalizedString.takePhoto.string)
			]

			if UIPasteboard.general.hasImage {
				commands.append(UIKeyCommand(input: "v", modifierFlags: .command, action: #selector(pastePhoto),
                                             discoverabilityTitle: LocalizedString.pastePhoto.string))
			}
		}

		if let additionalCommands = editorViewController.keyCommands {
			commands += additionalCommands
		}

		return commands
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		editorViewController.delegate = self
		addChild(editorViewController)
		editorViewController.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(editorViewController.view)

		view.addSubview(activityIndicator)

		emptyView.choosePhotoButton.addTarget(self, action: #selector(choosePhoto), for: .primaryActionTriggered)
		emptyView.lastPhotoButton.addTarget(self, action: #selector(chooseLastPhoto), for: .primaryActionTriggered)
		emptyView.takePhotoButton.addTarget(self, action: #selector(takePhoto), for: .primaryActionTriggered)
		emptyView.pastePhotoButton.addTarget(self, action: #selector(pastePhoto), for: .primaryActionTriggered)
		view.addSubview(emptyView)

		NSLayoutConstraint.activate([
			editorViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			editorViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			editorViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
			editorViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	// MARK: - Actions

	@objc func choosePhoto() {
		haptics.prepare()
		PhotosController.choosePhoto(context: self) { [weak self] asset in
			guard let asset = asset else {
				print("Failed to choose photo.")
				return
			}

			self?.load(asset)
		}
	}

	@objc func chooseLastPhoto() {
		haptics.prepare()
		PhotosController.getLastPhoto(context: self) { [weak self] asset in
			guard let asset = asset else {
				print("Failed to get last photo.")
				return
			}

			self?.load(asset)
		}
	}

	@objc func takePhoto() {
		haptics.prepare()
		PhotosController.takePhoto(context: self) { [weak self] image in
			self?.editorViewController.originalImage = image
		}
	}

	@objc func pastePhoto() {
		let data = UIPasteboard.general.data(forPasteboardType: "public.image")
		editorViewController.originalImage = data.flatMap(UIImage.init)
	}

	// MARK: - Private

	private func load(_ asset: PHAsset) {
		UIView.animate(withDuration: 0.2) { [weak self] in
			self?.emptyView.alpha = 0
			self?.activityIndicator.startAnimating()
		}

		PhotosController.load(asset) { [weak self] input in
			self?.editorViewController.input = input
		}
	}
}

extension OpenViewController: EditorViewControllerDelegate {
	func editorViewController(_ viewController: EditorViewController, didChangeImage image: UIImage?) {
		UIView.animate(withDuration: 0.2) { [weak self] in
			self?.emptyView.alpha = image == nil ? 1 : 0
			self?.activityIndicator.stopAnimating()
		}
	}
}
