//
//	ModelPostsUser.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ModelPostsUser{

	var id : Int!
	var name : String = ""
	var profileImage : String!
	var username : String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		id = json["id"].intValue
		name = json["name"].stringValue
        profileImage = json["profileImage"].stringValue == "" ? json["profile_image"].stringValue : json["profileImage"].stringValue
		username = json["username"].stringValue
	}
    
    func toDictonary() -> [String : Any] {
        var dict : [String : Any] = [:]
        
        dict["name"] = self.name
        dict["profile_image"] = self.profileImage ?? ""
        dict["email"] = self.username ?? ""
        dict["id"] = self.id
        return dict
    }
}
