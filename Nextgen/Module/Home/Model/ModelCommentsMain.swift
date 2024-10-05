//
//	ModelCommentsMain.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON

class ModelCommentsMain{

	var comment : String!
	var commentsReply : [ModelCommentsMain]!
	var createdAt : String!
	var id : Int!
	var likes : Int!
	var postId : Int!
	var replyCount : Int!
	var user : ModelPostsUser!
	var userId : Int!
    var isShowSubComments : Bool = false
    var liked : Bool!

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		comment = json["comment"].stringValue
		commentsReply = [ModelCommentsMain]()
		let commentsReplyArray = json["comments_reply"].arrayValue
		for commentsReplyJson in commentsReplyArray{
			let value = ModelCommentsMain(fromJson: commentsReplyJson)
			commentsReply.append(value)
		}
		createdAt = json["created_at"].stringValue
		id = json["id"].intValue
		likes = json["likes"].intValue
		postId = json["post_id"].intValue
		replyCount = json["comments_reply_count"].intValue
		let userJson = json["user"]
		if !userJson.isEmpty{
			user = ModelPostsUser(fromJson: userJson)
		}
		userId = json["user_id"].intValue
        liked = json["liked"].boolValue
	}

}
