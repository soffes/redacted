import AppKit

final class AboutWindowController: NSWindowController {

	// MARK: - NSResponder

	override func keyDown(with event: NSEvent) {
		super.keyDown(with: event)

		// Support ⌘W
		if (event.characters ?? "") == "w" && event.modifierFlags.contains(.command) {
			close()
		}
	}


	// MARK: - NSWindowController

	override func showWindow(_ sender: Any?) {
		window?.center()
		super.showWindow(sender)
	}
}
