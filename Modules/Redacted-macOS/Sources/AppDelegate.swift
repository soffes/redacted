import AppKit
import IOKit
import Mixpanel
import RedactedKit

var mixpanel = Mixpanel(token: "8a64b11c12312da3bead981a4ad7e30b")

@NSApplicationMain final class AppDelegate: NSObject {

	// MARK: - Initializers

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - Properties

	@IBOutlet private var saveMenuItem: NSMenuItem!
	@IBOutlet private var exportMenuItem: NSMenuItem!
	@IBOutlet private var copyMenuItem: NSMenuItem!
	@IBOutlet private var pasteMenuItem: NSMenuItem!
	@IBOutlet private var deleteMenuItem: NSMenuItem!
	@IBOutlet private var selectAllMenuItem: NSMenuItem!
	@IBOutlet private var modeMenuItem: NSMenuItem!
	@IBOutlet private var pixelateMenuItem: NSMenuItem!
	@IBOutlet private var blurMenuItem: NSMenuItem!
	@IBOutlet private var blackBarMenuItem: NSMenuItem!
	@IBOutlet private var clearMenuItem: NSMenuItem!

	private var uniqueIdentifier: String {
		let key = "Identifier"
		if let identifier = UserDefaults.standard.string(forKey: key) {
			return identifier
		}

		let identifier = UUID().uuidString
		UserDefaults.standard.set(identifier, forKey: key)
		return identifier
	}

	// MARK: - Actions

	@IBAction private func showHelp(_ sender: Any?) {
		NSWorkspace.shared.open(URL(string: "http://useredacted.com/help")!)
	}

	// MARK: - Private

	private var windowController: EditorWindowController? {
		return NSApplication.shared.windows.first?.windowController as? EditorWindowController
	}

	@objc private func modeDidChange(notification: NSNotification?) {
		if let view = notification?.object as? RedactedView {
			updateMode(view: view)
		}
	}

	private func updateMode(view: RedactedView) {
		let mode = view.mode
		pixelateMenuItem.state = mode == .pixelate ? .on : .off
		blurMenuItem.state = mode == .blur ? .on : .off
		blackBarMenuItem.state = mode == .blackBar ? .on : .off
	}

	@objc private func selectionDidChange(notification: NSNotification?) {
		if let view = notification?.object as? RedactedView {
			deleteMenuItem.title = view.selectionCount == 1 ? string("DELETE_REDACTION") : string("DELETE_REDACTIONS")
		}
	}
}

extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
#if DEBUG
        mixpanel.enabled = false
#endif

		mixpanel.identify(identifier: uniqueIdentifier)
		mixpanel.track(event: "Launch")

		saveMenuItem.title = string("SAVE")
		exportMenuItem.title = string("EXPORT")
		copyMenuItem.title = string("COPY_IMAGE")
		pasteMenuItem.title = string("PASTE_IMAGE")
		deleteMenuItem.title = string("DELETE_REDACTION")
		selectAllMenuItem.title = string("SELECT_ALL_REDACTIONS")
		modeMenuItem.title = string("MODE")
		pixelateMenuItem.title = string("PIXELATE")
		blurMenuItem.title = string("BLUR")
		blackBarMenuItem.title = string("BLACK_BAR")
		clearMenuItem.title = string("CLEAR_IMAGE")

		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(selectionDidChange),
                           name: RedactedView.selectionDidChangeNotification, object: nil)
		center.addObserver(self, selector: #selector(modeDidChange), name: RedactedView.modeDidChangeNotification,
                           object: nil)

		if let view = windowController?.editorViewController?.redactedView {
			updateMode(view: view)
		}
	}

	func application(_ sender: NSApplication, openFile filename: String) -> Bool {
		if let windowController = windowController {
			return windowController.open(url: URL(fileURLWithPath: filename), source: "App icon")
		}
		return false
	}
}
