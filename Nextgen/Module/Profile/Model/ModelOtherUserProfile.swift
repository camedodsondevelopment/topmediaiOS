//
//	ModelOtherUserProfile.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON


class ModelOtherUserProfile : NSObject, NSCoding{

	var about : String!
	var backgroundImage : String!
	var countryCodeShort : String!
	var countryShortCode : String!
	var cryptoAddress : String!
	var dateOfBirth : String!
	var email : String!
	var firebaseUid : String!
	var followersCount : Int!
	var followingCount : Int!
	var id : Int!
	var isFollowing : Int!
	var isSocialLogin : Int!
	var latitude : String!
	var longitude : String!
	var name : String!
	var profileImage : String!
	var profileViewing : String!
	var token : String!
	var username : String!
    var isBlocked : Bool!
    var audio_file:String!


	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
		about = json["about"].stringValue
		backgroundImage = json["background_image"].stringValue
		countryCodeShort = json["country_code_short"].stringValue
		countryShortCode = json["country_short_code"].stringValue
		cryptoAddress = json["crypto_address"].stringValue
		dateOfBirth = json["date_of_birth"].stringValue
		email = json["email"].stringValue
		firebaseUid = json["firebase_uid"].stringValue
		followersCount = json["followers_count"].intValue
		followingCount = json["following_count"].intValue
		id = json["id"].intValue
		isFollowing = json["is_following"].intValue
		isSocialLogin = json["is_social_login"].intValue
		latitude = json["latitude"].stringValue
		longitude = json["longitude"].stringValue
		name = json["name"].stringValue
		profileImage = json["profile_image"].stringValue
		profileViewing = json["profile_viewing"].stringValue
		token = json["token"].stringValue
		username = json["username"].stringValue
        isBlocked = json["block"].boolValue
        audio_file = json["audio_file"].stringValue
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if about != nil{
			dictionary["about"] = about
		}
		if backgroundImage != nil{
			dictionary["background_image"] = backgroundImage
		}
		if countryCodeShort != nil{
			dictionary["country_code_short"] = countryCodeShort
		}
		if countryShortCode != nil{
			dictionary["country_short_code"] = countryShortCode
		}
		if cryptoAddress != nil{
			dictionary["crypto_address"] = cryptoAddress
		}
		if dateOfBirth != nil{
			dictionary["date_of_birth"] = dateOfBirth
		}
		if email != nil{
			dictionary["email"] = email
		}
		if firebaseUid != nil{
			dictionary["firebase_uid"] = firebaseUid
		}
		if followersCount != nil{
			dictionary["followers_count"] = followersCount
		}
		if followingCount != nil{
			dictionary["following_count"] = followingCount
		}
		if id != nil{
			dictionary["id"] = id
		}
		if isFollowing != nil{
			dictionary["is_following"] = isFollowing
		}
		if isSocialLogin != nil{
			dictionary["is_social_login"] = isSocialLogin
		}
		if latitude != nil{
			dictionary["latitude"] = latitude
		}
		if longitude != nil{
			dictionary["longitude"] = longitude
		}
		if name != nil{
			dictionary["name"] = name
		}
		if profileImage != nil{
			dictionary["profile_image"] = profileImage
		}
		if profileViewing != nil{
			dictionary["profile_viewing"] = profileViewing
		}
		if token != nil{
			dictionary["token"] = token
		}
		if username != nil{
			dictionary["username"] = username
		}
        if isBlocked != nil{
            dictionary["block"] = isBlocked
        }
        if audio_file != nil {
            dictionary["audio_file"] = audio_file
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         about = aDecoder.decodeObject(forKey: "about") as? String
         backgroundImage = aDecoder.decodeObject(forKey: "background_image") as? String
         countryCodeShort = aDecoder.decodeObject(forKey: "country_code_short") as? String
         countryShortCode = aDecoder.decodeObject(forKey: "country_short_code") as? String
         cryptoAddress = aDecoder.decodeObject(forKey: "crypto_address") as? String
         dateOfBirth = aDecoder.decodeObject(forKey: "date_of_birth") as? String
         email = aDecoder.decodeObject(forKey: "email") as? String
         firebaseUid = aDecoder.decodeObject(forKey: "firebase_uid") as? String
         followersCount = aDecoder.decodeObject(forKey: "followers_count") as? Int
         followingCount = aDecoder.decodeObject(forKey: "following_count") as? Int
         id = aDecoder.decodeObject(forKey: "id") as? Int
         isFollowing = aDecoder.decodeObject(forKey: "is_following") as? Int
         isSocialLogin = aDecoder.decodeObject(forKey: "is_social_login") as? Int
         latitude = aDecoder.decodeObject(forKey: "latitude") as? String
         longitude = aDecoder.decodeObject(forKey: "longitude") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         profileImage = aDecoder.decodeObject(forKey: "profile_image") as? String
         profileViewing = aDecoder.decodeObject(forKey: "profile_viewing") as? String
         token = aDecoder.decodeObject(forKey: "token") as? String
         username = aDecoder.decodeObject(forKey: "username") as? String
        isBlocked = aDecoder.decodeBool(forKey: "block") as? Bool
        audio_file = aDecoder.decodeObject(forKey: "audio_file") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if about != nil{
			aCoder.encode(about, forKey: "about")
		}
		if backgroundImage != nil{
			aCoder.encode(backgroundImage, forKey: "background_image")
		}
		if countryCodeShort != nil{
			aCoder.encode(countryCodeShort, forKey: "country_code_short")
		}
		if countryShortCode != nil{
			aCoder.encode(countryShortCode, forKey: "country_short_code")
		}
		if cryptoAddress != nil{
			aCoder.encode(cryptoAddress, forKey: "crypto_address")
		}
		if dateOfBirth != nil{
			aCoder.encode(dateOfBirth, forKey: "date_of_birth")
		}
		if email != nil{
			aCoder.encode(email, forKey: "email")
		}
		if firebaseUid != nil{
			aCoder.encode(firebaseUid, forKey: "firebase_uid")
		}
		if followersCount != nil{
			aCoder.encode(followersCount, forKey: "followers_count")
		}
		if followingCount != nil{
			aCoder.encode(followingCount, forKey: "following_count")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if isFollowing != nil{
			aCoder.encode(isFollowing, forKey: "is_following")
		}
		if isSocialLogin != nil{
			aCoder.encode(isSocialLogin, forKey: "is_social_login")
		}
		if latitude != nil{
			aCoder.encode(latitude, forKey: "latitude")
		}
		if longitude != nil{
			aCoder.encode(longitude, forKey: "longitude")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if profileImage != nil{
			aCoder.encode(profileImage, forKey: "profile_image")
		}
		if profileViewing != nil{
			aCoder.encode(profileViewing, forKey: "profile_viewing")
		}
		if audio_file != nil{
			aCoder.encode(audio_file, forKey: "audio_file")
		}
		if username != nil{
			aCoder.encode(username, forKey: "username")
		}
        if isBlocked != nil{
            aCoder.encode(isBlocked, forKey: "block")
        }
	}

}
