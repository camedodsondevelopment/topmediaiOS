//
//	ModelVideoListMain.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ModelVideoListMain{

	var commentsListCount : Int!
	var createdAt : String!
	var descriptionField : String!
	var file : String!
	var id : Int!
	var isVideo : String!
	var like : Int!
	var liked : Int!
	var thumbImage : String!
	var user : ModelVideoListUser!
	var userId : Int!
    var isLiked : Bool!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		commentsListCount = json["comments_list_count"].intValue
		createdAt = json["created_at"].stringValue
		descriptionField = json["description"].stringValue
		file = json["file"].stringValue
		id = json["id"].intValue
		isVideo = json["is_video"].stringValue
		like = json["like"].intValue
		liked = json["liked"].intValue
		thumbImage = json["thumb_image"].stringValue
		let userJson = json["user"]
		if !userJson.isEmpty{
			user = ModelVideoListUser(fromJson: userJson)
		}
		userId = json["user_id"].intValue
        isLiked = json["liked"].boolValue

	}

}
