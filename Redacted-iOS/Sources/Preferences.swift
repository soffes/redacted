import Foundation

final class Preferences {

	// MARK: - Types

	private enum Key: String {
		case completedTutorial
	}


	// MARK: - Properties

	static let shared: Preferences = {
		let defaults = UserDefaults(suiteName: "group.com.nothingmagical.redacted-ios")!
		let preferences = Preferences(userDefaults: defaults)

		if UserDefaults.standard.bool(forKey: "CreatedRedaction") {
			preferences.completedTutorial = true
		}

		return preferences
	}()

	private let userDefaults: UserDefaults

	var completedTutorial: Bool {
		get {
			return userDefaults.bool(forKey: Key.completedTutorial.rawValue)
		}

		set {
			userDefaults.set(newValue, forKey: Key.completedTutorial.rawValue)
		}
	}


	// MARK: - Initializers

	init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}
}
