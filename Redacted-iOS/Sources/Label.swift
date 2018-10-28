import UIKit

class Label: UILabel {

	var contentInsets: UIEdgeInsets = .zero

	override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize
		size.width += contentInsets.left + contentInsets.right
		size.height += contentInsets.top + contentInsets.bottom
		return size
	}
}
