import AVFoundation
import Photos
import RedactedKit
import UIKit
import X

protocol EditorViewControllerDelegate: class {
	func editorViewController(_ viewController: EditorViewController, didChangeImage image: UIImage?)
}

class EditorViewController: UIViewController {

	// MARK: - Properties

	weak var delegate: EditorViewControllerDelegate?

	let redactedView: RedactedView = {
		let view = RedactedView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	let toolbarView: ToolbarView = {
		let view = ToolbarView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private var toolbarBottomConstraint: NSLayoutConstraint? {
		willSet {
			toolbarBottomConstraint?.isActive = false
		}

		didSet {
			toolbarBottomConstraint?.isActive = true
		}
	}

	var input: PHContentEditingInput? {
		didSet {
			if let input = input {
				do {
					if let adjustmentData = input.adjustmentData {
						let redactions = try RedactionSerialization.redactions(from: adjustmentData)
						queuedRedactions = redactions
					}
				} catch {
					print("Failed to deserialize redaction adjustment data: \(error)")
				}

				originalImage = input.displaySizeImage
			} else {
				originalImage = nil
			}
		}
	}

	private var queuedRedactions = [Redaction]()

	var originalImage: UIImage? {
		didSet {
			guard let originalImage = originalImage else {
				image = nil
				return
			}

			let bounds = view.bounds

			DispatchQueue.global(qos: .userInitiated).async { [weak self] in
				let size = AVMakeRect(aspectRatio: originalImage.size, insideRect: bounds).size
				UIGraphicsBeginImageContextWithOptions(size, false, 0)
				originalImage.draw(in: CGRect(origin: .zero, size: size))
				let image = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()

				DispatchQueue.main.async {
					self?.image = image
				}
			}
		}
	}

	private var image: UIImage? {
		didSet {
			imageDidChange()
		}
	}

	var renderedImage: UIImage? {
		let controller = RedactionsController()
		controller.image = originalImage
		controller.redactions = redactedView.redactions
		return controller.process()?.renderedImage
	}

	let _undoManager = UndoManager()

	let haptics = UISelectionFeedbackGenerator()

	private let toolTipView: ToolTipView = {
		let view = ToolTipView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.textLabel.text = LocalizedString.tapAndDrag.string
		return view
	}()

	private var toolTipBottomConstraint: NSLayoutConstraint? {
		willSet {
			toolTipBottomConstraint?.isActive = false
		}

		didSet {
			toolTipBottomConstraint?.isActive = true
		}
	}

	var longPressedRedaction: Redaction?

	// MARK: - UIResponder

	override var canBecomeFirstResponder: Bool {
		return true
	}

	override var undoManager: UndoManager? {
		return _undoManager
	}

	override var keyCommands: [UIKeyCommand]? {
		var commands = super.keyCommands ?? []

		if image != nil {
			commands += [
				UIKeyCommand(input: "1", modifierFlags: .command, action: #selector(usePixelate),
                             discoverabilityTitle: string("PIXELATE")),
				UIKeyCommand(input: "2", modifierFlags: .command, action: #selector(useBlur),
                             discoverabilityTitle: string("BLUR")),
				UIKeyCommand(input: "3", modifierFlags: .command, action: #selector(useBlackBar),
                             discoverabilityTitle: string("BLACK_BAR")),
				UIKeyCommand(input: "\u{8}", modifierFlags: [], action: #selector(deleteRedaction),
                             discoverabilityTitle: string("DELETE_REDACTION")),
				UIKeyCommand(input: "a", modifierFlags: .command, action: #selector(selectAllRedactions),
                             discoverabilityTitle: string("SELECT_ALL_REDACTIONS"))
			]

#if !REDACTED_APP_EXTENSION
            commands += [
                UIKeyCommand(input: "\u{8}", modifierFlags: .command, action: #selector(clear),
                             discoverabilityTitle: string("CLEAR_IMAGE")),
                UIKeyCommand(input: "e", modifierFlags: .command, action: #selector(share),
                             discoverabilityTitle: string("SHARE")),
                UIKeyCommand(input: "c", modifierFlags: .command, action: #selector(copyImage),
                             discoverabilityTitle: string("COPY_IMAGE")),
                UIKeyCommand(input: "s", modifierFlags: .command, action: #selector(saveImage),
                             discoverabilityTitle: string("SAVE"))
            ]
#endif

			if undoManager?.canUndo == true {
				let title = String(format: LocalizedString.undoFormat.string, _undoManager.undoActionName)
				commands.append(UIKeyCommand(input: "z", modifierFlags: .command, action: #selector(undoEdit),
                                             discoverabilityTitle: title))
			}

			if undoManager?.canRedo == true {
				let title = String(format: LocalizedString.redoFormat.string, _undoManager.redoActionName)
				commands.append(UIKeyCommand(input: "z", modifierFlags: [.command, .shift], action: #selector(redoEdit),
                                             discoverabilityTitle: title))
			}
		}

		return commands
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = UIColor(white: 43 / 255, alpha: 1)

		redactedView.backgroundColor = view.backgroundColor
		redactedView.customUndoManager = _undoManager
		view.addSubview(redactedView)

		toolbarView.modeControl.addTarget(self, action: #selector(modeDidChange), for: .primaryActionTriggered)

#if !REDACTED_APP_EXTENSION
        toolbarView.clearButton.addTarget(self, action: #selector(clear), for: .primaryActionTriggered)
        toolbarView.shareButton.addTarget(self, action: #selector(share), for: .primaryActionTriggered)
#endif

		let spacerView = UIView()
		spacerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(spacerView)
		spacerView.addSubview(toolbarView)

		let toolbarTopConstraint = toolbarView.topAnchor.constraint(equalTo: spacerView.bottomAnchor)
		toolbarTopConstraint.priority = UILayoutPriority.defaultLow

		NSLayoutConstraint.activate([
			redactedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			redactedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			redactedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			redactedView.bottomAnchor.constraint(equalTo: spacerView.topAnchor, constant: -16),

			spacerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			spacerView.heightAnchor.constraint(equalTo: toolbarView.heightAnchor),

			toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			toolbarTopConstraint,

			toolbarView.leadingAnchor.constraint(equalTo: spacerView.leadingAnchor),
			toolbarView.trailingAnchor.constraint(equalTo: spacerView.trailingAnchor)
		])

		let pan = UIPanGestureRecognizer(target: self, action: #selector(panned))
		view.addGestureRecognizer(pan)

		let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
		view.addGestureRecognizer(tap)

		let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTapped))
		twoFingerTap.numberOfTouchesRequired = 2
		view.addGestureRecognizer(twoFingerTap)

		let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
		longPress.minimumPressDuration = 0.3
		view.addGestureRecognizer(longPress)

		view.layoutIfNeeded()
		imageDidChange()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	// MARK: - Private

	/// You should not call this directly
	func imageDidChange() {
		redactedView.originalImage = image
		redactedView.redactions = queuedRedactions
		queuedRedactions.removeAll()

		let hasImage = image != nil
		delegate?.editorViewController(self, didChangeImage: image)
		toolbarView.isEnabled = hasImage

		if hasImage {
			haptics.selectionChanged()

			toolbarBottomConstraint = toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

			if !Preferences.shared.completedTutorial {
				showTutorial()
			}
		} else {
			hideTutorial()
			toolbarBottomConstraint = nil
		}

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.2,
                       animations:
        { [weak self] in
            self?.view.layoutIfNeeded()
		}, completion: nil)
	}

	private func setupTutorial() {
		if toolTipView.superview != nil {
			return
		}

		view.addSubview(toolTipView)

		let bottomConstraint = toolTipView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 64)
		bottomConstraint.priority = UILayoutPriority.defaultLow

		NSLayoutConstraint.activate([
			toolTipView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			bottomConstraint
		])

		view.layoutIfNeeded()
	}

	private func showTutorial() {
		setupTutorial()

		toolTipBottomConstraint = toolTipView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: -16)

		UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.2,
                       animations:
        { [weak self] in
			self?.view.layoutIfNeeded()
		}, completion: nil)
	}

	func hideTutorial() {
		if toolTipView.superview == nil {
			return
		}

		toolTipBottomConstraint = nil

		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.2,
                       animations:
        { [weak self] in
			self?.view.layoutIfNeeded()
		}, completion: { [weak self] _ in
			self?.toolTipView.removeFromSuperview()
		})
	}
}
