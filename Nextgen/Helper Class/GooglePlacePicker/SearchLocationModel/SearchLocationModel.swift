//
//  SearchLocationModel.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on December 20, 2021
//
import Foundation
import SwiftyJSON

struct SearchLocationModel {

	var description: String?
	var matchedSubstrings: [MatchedSubstrings]?
	var placeId: String?
	var reference: String?
	var structuredFormatting: StructuredFormatting?
	var terms: [Terms]?
	var types: [String]?

	init(_ json: JSON) {
		description = json["description"].stringValue
		matchedSubstrings = json["matched_substrings"].arrayValue.map { MatchedSubstrings($0) }
		placeId = json["place_id"].stringValue
		reference = json["reference"].stringValue
		structuredFormatting = StructuredFormatting(json["structured_formatting"])
		terms = json["terms"].arrayValue.map { Terms($0) }
		types = json["types"].arrayValue.map { $0.stringValue }
	}

}