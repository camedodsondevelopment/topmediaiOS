//
//	Gamification.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class Gamification : NSObject, NSCoding{

	var coin : String!
	var currentValue : String!
	var maxRange : Int!
	var minRange : Int!
	var name : String!
	var relationShip : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		coin = json["coin"].stringValue
		currentValue = json["current_value"].stringValue
		maxRange = json["max_range"].intValue
		minRange = json["min_range"].intValue
		name = json["name"].stringValue
		relationShip = json["relation_ship"].stringValue
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if coin != nil{
			dictionary["coin"] = coin
		}
		if currentValue != nil{
			dictionary["current_value"] = currentValue
		}
		if maxRange != nil{
			dictionary["max_range"] = maxRange
		}
		if minRange != nil{
			dictionary["min_range"] = minRange
		}
		if name != nil{
			dictionary["name"] = name
		}
		if relationShip != nil{
			dictionary["relation_ship"] = relationShip
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         coin = aDecoder.decodeObject(forKey: "coin") as? String
         currentValue = aDecoder.decodeObject(forKey: "current_value") as? String
         maxRange = aDecoder.decodeObject(forKey: "max_range") as? Int
         minRange = aDecoder.decodeObject(forKey: "min_range") as? Int
         name = aDecoder.decodeObject(forKey: "name") as? String
         relationShip = aDecoder.decodeObject(forKey: "relation_ship") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if coin != nil{
			aCoder.encode(coin, forKey: "coin")
		}
		if currentValue != nil{
			aCoder.encode(currentValue, forKey: "current_value")
		}
		if maxRange != nil{
			aCoder.encode(maxRange, forKey: "max_range")
		}
		if minRange != nil{
			aCoder.encode(minRange, forKey: "min_range")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if relationShip != nil{
			aCoder.encode(relationShip, forKey: "relation_ship")
		}

	}

}