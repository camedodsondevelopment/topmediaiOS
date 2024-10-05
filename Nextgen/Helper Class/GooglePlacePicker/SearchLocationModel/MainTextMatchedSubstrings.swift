//
//  MainTextMatchedSubstrings.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on December 20, 2021
//
import Foundation
import SwiftyJSON

struct MainTextMatchedSubstrings {

	var length: Int?
	var offset: Int?

	init(_ json: JSON) {
		length = json["length"].intValue
		offset = json["offset"].intValue
	}

}