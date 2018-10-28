import Foundation
import Photos

extension RedactionSerialization {
	public static func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
		do {
			_ = try RedactionSerialization.redactions(from: adjustmentData)
			return true
		} catch {
			print("Failed to check adjustment data: \(error)")
			return false
		}
	}

	public static func adjustmentData(for redactions: [Redaction]) throws -> PHAdjustmentData {
		let data = try self.data(for: redactions)
		return PHAdjustmentData(formatIdentifier: formatIdentifier, formatVersion: formatVersion, data: data)
	}

	public static func redactions(from adjustmentData: PHAdjustmentData) throws -> [Redaction] {
		if adjustmentData.formatIdentifier != formatIdentifier {
			throw DeserializationError.unsupportedType
		}

		if adjustmentData.formatVersion != formatVersion {
			throw DeserializationError.unsupportedVersion
		}

		return try redactions(for: adjustmentData.data)
	}
}
