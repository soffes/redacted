import UIKit

extension UIPasteboard {
	var hasImage: Bool {
		return contains(pasteboardTypes: ["public.image"])
	}
}
