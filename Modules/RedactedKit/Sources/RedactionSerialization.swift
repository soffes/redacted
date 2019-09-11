import Foundation

public struct RedactionSerialization {

	public enum DeserializationError: Error {
		case invalidContainer
		case unsupportedType
		case unsupportedVersion
	}

	public static let formatIdentifier = "com.nothingmagical.redacted.redaction"
	public static let formatVersion = "1"

	public static func data(for redactions: [Redaction]) throws -> Data {
		let json: [String: Any] = [
			"Type": formatIdentifier,
			"Version": formatVersion,
			"Redactions": redactions.map { $0.dictionaryRepresentation }
		]
		return try JSONSerialization.data(withJSONObject: json, options: [])
	}

	public static func redactions(for data: Data) throws -> [Redaction] {
		let raw = try JSONSerialization.jsonObject(with: data, options: [])

		guard let json = raw as? [String: Any] else {
			throw DeserializationError.invalidContainer
		}

		guard let type = json["Type"] as? String, type == formatIdentifier else {
			throw DeserializationError.unsupportedVersion
		}

		guard let version = json["Version"] as? String, version == formatVersion else {
			throw DeserializationError.unsupportedVersion
		}

		guard let dictionaries = json["Redactions"] as? [[String: Any]] else {
			throw DeserializationError.invalidContainer
		}

        return dictionaries.compactMap(Redaction.init)
	}

	private init() {}
}
