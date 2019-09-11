import Foundation
import X

func bundle() -> Bundle? {
	return Bundle(for: RedactedView.self)
}

public func string(_ key: String) -> String {
	if let bundle = bundle() {
		return bundle.localizedString(forKey: key, value: nil, table: nil)
	}
	return key
}
