//
//  RedactionSerialization+Adjustments.swift
//  Redacted
//
//  Created by Sam Soffes on 7/8/17.
//  Copyright © 2017 Nothing Magical Inc. All rights reserved.
//

import Foundation
import Photos

extension RedactionSerialization {
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
