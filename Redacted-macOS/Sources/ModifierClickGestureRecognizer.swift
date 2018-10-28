import AppKit

final class ModifierClickGestureRecognizer: NSClickGestureRecognizer {
	var modifier: NSEvent.ModifierFlags?

	override func mouseDown(with event: NSEvent) {
		if let modifier = modifier {
			if event.modifierFlags.contains(modifier) {
				super.mouseDown(with: event)
			}
			return
		}

		super.mouseDown(with: event)
	}
}
