import Foundation
import X

func bundle() -> Bundle? {
	let path = Bundle.main.path(forResource: "RedactedKitResources", ofType: "bundle")
	return path.flatMap { Bundle(path: $0) }
}

public func string(_ key: String) -> String {
	if let bundle = bundle() {
		return bundle.localizedString(forKey: key, value: nil, table: nil)
	}

	return key
}
