import CoreGraphics

extension CGRect {
	var center: CGPoint {
		return CGPoint(x: midX, y: midY)
	}

	func flippedInRect(_ bounds: CGRect) -> CGRect {
		return CGRect(
			x: origin.x,
			y: bounds.size.height - size.height - origin.y,
			width: size.width,
			height: size.height
		)
	}
}

extension CGPoint {
	func flippedInRect(_ bounds: CGRect) -> CGPoint {
		return CGPoint(
			x: x,
			y: bounds.size.height - y
		)
	}

    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - lhs.x)
    }
}
