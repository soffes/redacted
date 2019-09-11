import QuartzCore

final class BoundingBoxLayer: CALayer {

	// MARK: - Properties

	let border = CALayer()
//	let topLeft = HandleLayer()
//	let topCenter = HandleLayer()
//	let topRight = HandleLayer()
//	let middleLeft = HandleLayer()
//	let middleRight = HandleLayer()
//	let bottomLeft = HandleLayer()
//	let bottomCenter = HandleLayer()
//	let bottomRight = HandleLayer()

	// MARK: - Initializers

	override init() {
		super.init()
		initialize()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	override init(layer: Any) {
		super.init(layer: layer)
		initialize()
	}

	// MARK: - CALayer

	override func layoutSublayers() {
		super.layoutSublayers()

		CATransaction.begin()
		CATransaction.setDisableActions(true)

		border.frame = bounds

//		let size = 6.0
//		let half = size / 2.0
//
//		topLeft.frame = CGRect(x: bounds.minX - half, y: bounds.maxY - half, width: size, height: size)
//		topCenter.frame = CGRect(x: bounds.midX - half, y: bounds.maxY - half, width: size, height: size)
//		topRight.frame = CGRect(x: bounds.maxX - half, y: bounds.maxY - half, width: size, height: size)
//
//		middleLeft.frame = CGRect(x: bounds.minX - half, y: bounds.midY - half, width: size, height: size)
//		middleRight.frame = CGRect(x: bounds.maxX - half, y: bounds.midY - half, width: size, height: size)
//
//		bottomLeft.frame = CGRect(x: bounds.minX - half, y: bounds.minY - half, width: size, height: size)
//		bottomCenter.frame = CGRect(x: bounds.midX - half, y: bounds.minY - half, width: size, height: size)
//		bottomRight.frame = CGRect(x: bounds.maxX - half, y: bounds.minY - half, width: size, height: size)

		CATransaction.commit()
	}

	// MARK: - Private

	private func initialize() {
		border.borderWidth = 2
		border.borderColor = selectionColor.cgColor
		addSublayer(border)

//		addSublayer(topLeft)
//		addSublayer(topCenter)
//		addSublayer(topRight)
//
//		addSublayer(middleLeft)
//		addSublayer(middleRight)
//
//		addSublayer(bottomLeft)
//		addSublayer(bottomCenter)
//		addSublayer(bottomRight)
	}
}
