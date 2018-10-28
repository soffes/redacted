import UIKit

final class SegmentedControl: UIControl {

	// MARK: - Properties

	var selectedIndex = 0 {
		didSet {
			for button in buttons {
				button.isSelected = false
			}

			selectedButton = buttons[selectedIndex]
			selectedButton.isSelected = true
		}
	}

	private let stackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let buttons: [UIButton] = {
		return [
			ToolbarButton(image: #imageLiteral(resourceName: "Pixelate")),
			ToolbarButton(image: #imageLiteral(resourceName: "Blur")),
			ToolbarButton(image: #imageLiteral(resourceName: "BlackBar"))
		]
	}()

	private var selectedButton: UIButton

	override var isEnabled: Bool {
		didSet {
			buttons.forEach { $0.isEnabled = isEnabled }

			if isEnabled {
				haptics.prepare()
			}
		}
	}

	private let haptics = UISelectionFeedbackGenerator()
	

	// MARK: - Initializers

	override init(frame: CGRect) {
		selectedButton = buttons[selectedIndex]
		selectedButton.isSelected = true

		super.init(frame: frame)

		var constraints = [NSLayoutConstraint]()

		for (i, button) in buttons.enumerated() {
			button.tag = i
			button.addTarget(self, action: #selector(selectItem), for: .touchDown)

			stackView.addArrangedSubview(button)

			constraints += [
				button.widthAnchor.constraint(equalToConstant: 40),
				button.heightAnchor.constraint(equalTo: heightAnchor)
			]
		}

		addSubview(stackView)

		NSLayoutConstraint.activate(constraints + [
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
		])
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	// MARK: - UIView

	override class var layerClass: AnyClass {
		return CATransformLayer.self
	}


	// MARK: - Private

	@objc private func selectItem(_ sender: UIButton) {
		selectedIndex = sender.tag
		
		sendActions(for: .valueChanged)
		sendActions(for: .primaryActionTriggered)
		haptics.selectionChanged()
	}
}
