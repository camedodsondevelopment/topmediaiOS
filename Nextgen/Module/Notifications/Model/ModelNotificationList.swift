//
//	ModelNotificationList.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ModelNotificationList{

	var createdAt : String!
	var fromUser : FromUser!
	var fromUserId : Int!
	var id : Int!
	var objectId : Int!
	var pushMessage : String!
	var pushTitle : String!
	var pushType : Int!
	var updatedAt : String!
	var userId : Int!
    var notification_type:Int?


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		createdAt = json["created_at"].stringValue
		let fromUserJson = json["from_user"]
		if !fromUserJson.isEmpty{
			fromUser = FromUser(fromJson: fromUserJson)
		}
		fromUserId = json["from_user_id"].intValue
		id = json["id"].intValue
		objectId = json["object_id"].intValue
		pushMessage = json["push_message"].stringValue
		pushTitle = json["push_title"].stringValue
		pushType = json["push_type"].intValue
		updatedAt = json["updated_at"].stringValue
		userId = json["user_id"].intValue
        notification_type = json["notification_type"].intValue

	}

}
