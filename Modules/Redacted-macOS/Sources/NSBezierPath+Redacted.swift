import AppKit

extension NSBezierPath {
	var cgPath: CGPath? {
		let path = CGMutablePath()
		let points = NSPointArray.allocate(capacity: 3)
		var closed = true

		for index in 0..<elementCount {
			let pathType = element(at: index, associatedPoints: points)
			switch pathType {
			case .moveTo:
				path.move(to: points[0])
				closed = false
			case .lineTo:
				path.addLine(to: points[0])
				closed = false
			case .curveTo:
				path.addCurve(to: points[2], control1: points[0], control2: points[1])
				closed = false
			case .closePath:
				path.closeSubpath()
				closed = true
			@unknown default:
				assertionFailure("Unknown NSBezierCurve path type")
				continue
            }
		}

		points.deallocate()

		if !closed {
			path.closeSubpath()
		}

		return path
	}
}
