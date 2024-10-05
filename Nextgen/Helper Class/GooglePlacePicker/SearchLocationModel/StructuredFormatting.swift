//
//  StructuredFormatting.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on December 20, 2021
//
import Foundation
import SwiftyJSON

struct StructuredFormatting {

	var mainText: String?
	var mainTextMatchedSubstrings: [MainTextMatchedSubstrings]?
	var secondaryText: String?

	init(_ json: JSON) {
		mainText = json["main_text"].stringValue
		mainTextMatchedSubstrings = json["main_text_matched_substrings"].arrayValue.map { MainTextMatchedSubstrings($0) }
		secondaryText = json["secondary_text"].stringValue
	}

}