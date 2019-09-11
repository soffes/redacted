import AppKit

extension NSPasteboard.PasteboardType {
	static let filenames: NSPasteboard.PasteboardType = {
		// #yolo
		return NSPasteboard.PasteboardType("NSFilenamesPboardType")
	} ()
}
