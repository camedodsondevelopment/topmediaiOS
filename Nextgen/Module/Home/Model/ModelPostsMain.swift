//
//	ModelPostsMain.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ModelPostsMain{

	var comments : Int = 0
	var createdAt : String = ""
	var descriptionField : String = ""
	var file : [String] = []
    var thumbImages : [String] = []
	var id : Int = 0
	var isFollowing : Int = 0
	var like : Int = 0
	var user : ModelPostsUser?
	var userId : Int = 0
    var isLiked : Bool = false


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		comments = json["comments_list_count"].intValue
		createdAt = json["created_at"].stringValue
		descriptionField = json["description"].stringValue
        file = json["file"].arrayValue.map({$0.stringValue})
        thumbImages = json["thumb_image"].arrayValue.map({$0.stringValue})
		id = json["id"].intValue
		isFollowing = json["is_following"].intValue
		like = json["like"].intValue
		let userJson = json["user"]
		if !userJson.isEmpty{
			user = ModelPostsUser(fromJson: userJson)
		}
		userId = json["user_id"].intValue
        isLiked = json["liked"].boolValue
	}
}
