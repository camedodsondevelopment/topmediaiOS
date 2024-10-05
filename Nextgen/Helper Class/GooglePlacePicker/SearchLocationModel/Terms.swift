//
//  Terms.swift
//
//  Generated using https://jsonmaster.github.io
//  Created on December 20, 2021
//
import Foundation
import SwiftyJSON

struct Terms {

	var offset: Int?
	var value: String?

	init(_ json: JSON) {
		offset = json["offset"].intValue
		value = json["value"].stringValue
	}

}