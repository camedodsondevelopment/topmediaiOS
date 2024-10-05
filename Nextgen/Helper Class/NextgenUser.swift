//
//  NextgenUser.swift
//  Youunite
//
//  Created by Mac on 21/12/20.
//  Copyright © 2020 ZestBrains PVT LTD. All rights reserved.
//

import UIKit
import SwiftyJSON

class NextgenUser: NSObject, NSCoding {
    
    var about : String = ""
    var countryShortCode : String = ""
    var cryptoAddress : String = ""
    var dateOfBirth : String = ""
    var email : String = ""
    var firebaseUid : String = ""
    var followersCount : String = ""
    var followingCount : String = ""
    var id : String = ""
    var latitude : String = ""
    var longitude : String = ""
    var name : String = ""
    var profileImage : String = ""
    var profileViewing : String = ""
    var token : String = ""
    var username : String = ""
    var isSocialLogin : String = ""
    var backgroundImage : String = ""
    
    var countryCode : String = ""
    var countryIsoCode : String = ""
    var gamification : [Gamification] = []
    var mobile : String = ""
    
    var preference = [NSDictionary]()
    static var shared: NextgenUser = NextgenUser()
    override init() {
        super.init()
        let encodedObject: NSData? = UserDefaults.standard.object(forKey: "NextgenUser") as? NSData
        if encodedObject != nil {
            let userDefaultsReference = UserDefaults.standard
            let encodedeObject: NSData = userDefaultsReference.object(forKey: "NextgenUser") as? NSData ?? NSData()
            let kUSerObject: NextgenUser = NSKeyedUnarchiver.unarchiveObject(with: encodedeObject as Data) as? NextgenUser ?? NextgenUser()
            self.loadContent(fromUser: kUSerObject)
        }
    }
    
    func saveArchievedData(data:Any, key:String){
        let data = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        about = aDecoder.decodeObject(forKey: "about") as? String ?? ""
        countryShortCode = aDecoder.decodeObject(forKey: "country_short_code") as? String ?? ""
        cryptoAddress = aDecoder.decodeObject(forKey: "crypto_address") as? String ?? ""
        dateOfBirth = aDecoder.decodeObject(forKey: "date_of_birth") as? String ?? ""
        email = aDecoder.decodeObject(forKey: "email") as? String ?? ""
        firebaseUid = aDecoder.decodeObject(forKey: "firebase_uid") as? String ?? ""
        followersCount = aDecoder.decodeObject(forKey: "followers_count") as? String ?? ""
        followingCount = aDecoder.decodeObject(forKey: "following_count") as? String ?? ""
        id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        latitude = aDecoder.decodeObject(forKey: "latitude") as? String ?? ""
        longitude = aDecoder.decodeObject(forKey: "longitude") as? String ?? ""
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        profileImage = aDecoder.decodeObject(forKey: "profile_image")  as? String ?? ""
        profileViewing = aDecoder.decodeObject(forKey: "profile_viewing")  as? String ?? ""
        token = aDecoder.decodeObject(forKey: "token")  as? String ?? ""
        username = aDecoder.decodeObject(forKey: "username") as? String ?? ""
        isSocialLogin = aDecoder.decodeObject(forKey: "is_social_login") as? String ?? ""
        backgroundImage = aDecoder.decodeObject(forKey: "background_image") as? String ?? ""
        
        countryCode = aDecoder.decodeObject(forKey: "country_code") as? String ?? ""
        countryIsoCode = aDecoder.decodeObject(forKey: "country_iso_code") as? String ?? ""
        gamification = aDecoder.decodeObject(forKey: "gamification") as? [Gamification] ?? []
        mobile = aDecoder.decodeObject(forKey: "mobile") as? String ?? ""
    }
    
    func loadUser() -> NextgenUser {
        let userDefaultsReference = UserDefaults.standard
        let encodedeObject: NSData = userDefaultsReference.object(forKey: "NextgenUser") as? NSData ?? NSData()
        let kUSerObject: NextgenUser = NSKeyedUnarchiver.unarchiveObject(with: encodedeObject as Data) as? NextgenUser ?? NextgenUser()
        return kUSerObject
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(about, forKey: "about")
        aCoder.encode(countryShortCode, forKey: "country_short_code")
        aCoder.encode(cryptoAddress, forKey: "crypto_address")
        aCoder.encode(dateOfBirth, forKey: "date_of_birth")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(firebaseUid, forKey: "firebase_uid")
        aCoder.encode(followersCount, forKey: "followers_count")
        aCoder.encode(followingCount, forKey: "following_count")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(profileImage, forKey: "profile_image")
        aCoder.encode(profileViewing, forKey: "profile_viewing")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(username, forKey: "username")
        aCoder.encode(isSocialLogin, forKey: "is_social_login")
        aCoder.encode(backgroundImage, forKey: "background_image")
        
        aCoder.encode(countryCode, forKey: "country_code")
        aCoder.encode(countryIsoCode, forKey: "country_iso_code")
        aCoder.encode(gamification, forKey: "gamification")
        aCoder.encode(mobile, forKey: "mobile")
    }
    
    private func loadContent(fromUser user: NextgenUser) -> Void {
        self.about  = user.about
        self.countryShortCode   = user.countryShortCode
        self.cryptoAddress  = user.cryptoAddress
        self.dateOfBirth    = user.dateOfBirth
        self.email  = user.email
        self.firebaseUid    = user.firebaseUid
        self.followersCount = user.followersCount
        self.followingCount = user.followingCount
        self.id = user.id
        self.latitude   = user.latitude
        self.longitude  = user.longitude
        self.name   = user.name
        self.profileImage   = user.profileImage
        self.profileViewing = user.profileViewing
        self.token  = user.token
        self.username   = user.username
        self.isSocialLogin   = user.isSocialLogin
        self.backgroundImage   = user.backgroundImage
        
        self.countryCode   = user.countryCode
        self.countryIsoCode   = user.countryIsoCode
        self.gamification   = user.gamification
        self.mobile   = user.mobile
    }
    
    func save() -> Void {
        let encodedObject =  try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        UserDefaults.standard.setValue(encodedObject, forKey: "NextgenUser")
        UserDefaults.standard.synchronize()
    }
    
    func clear() -> Void {
        about = ""
        countryShortCode = ""
        cryptoAddress = ""
        dateOfBirth = ""
        email = ""
        firebaseUid = ""
        followersCount = ""
        followingCount = ""
        id = ""
        latitude = ""
        longitude = ""
        name = ""
        profileImage = ""
        profileViewing = ""
        token = ""
        username = ""
        isSocialLogin = ""
        backgroundImage = ""
        
        countryCode   = ""
        countryIsoCode   = ""
        gamification   = []
        mobile   = ""
        
        NextgenUser.shared.save()
        
        // remove all user data from app
        UserDefaults.standard.removeObject(forKey: "NextgenUser")
        UserDefaults.standard.removeObject(forKey: "CategorySelected")
        UserDefaults.standard.synchronize()
    }
    
    func setData(dict: JSON) -> Void {
        
        let json = dict
        if json.isEmpty {
            return
        }
        about = json["about"].stringValue
        countryShortCode = json["country_short_code"].stringValue
        cryptoAddress = json["crypto_address"].stringValue
        dateOfBirth = json["date_of_birth"].stringValue
        email = json["email"].stringValue
        firebaseUid = json["firebase_uid"].stringValue
        followersCount = json["followers_count"].stringValue
        followingCount = json["following_count"].stringValue
        id = json["id"].stringValue
        UserDefaults.standard.set(id, forKey: "userID")

        latitude = json["latitude"].stringValue
        longitude = json["longitude"].stringValue
        name = json["name"].stringValue
        profileImage = json["profile_image"].stringValue
        profileViewing = json["profile_viewing"].stringValue
        token = json["token"].stringValue
        username = json["username"].stringValue
        isSocialLogin = json["is_social_login"].stringValue
        backgroundImage = json["background_image"].stringValue
        
        countryCode = json["country_code"].stringValue
        countryIsoCode = json["country_iso_code"].stringValue
        gamification = [Gamification]()
        let gamificationArray = json["gamification"].arrayValue
        for gamificationJson in gamificationArray{
            let value = Gamification(fromJson: gamificationJson)
            gamification.append(value)
        }
        mobile = json["mobile"].stringValue
        
        NextgenUser.shared.save()
    }
    
    func setPrefranceData(dict:[NSDictionary]) -> Void {
        NextgenUser.shared.preference = dict
        NextgenUser.shared.save()
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        dictionary["about"] = about
        dictionary["country_short_code"] = countryShortCode
        dictionary["crypto_address"] = cryptoAddress
        dictionary["date_of_birth"] = dateOfBirth
        dictionary["email"] = email
        dictionary["firebase_uid"] = firebaseUid
        dictionary["followers_count"] = followersCount
        dictionary["following_count"] = followingCount
        dictionary["id"] = id
        dictionary["latitude"] = latitude
        dictionary["longitude"] = longitude
        dictionary["name"] = name
        dictionary["profile_image"] = profileImage
        dictionary["profile_viewing"] = profileViewing
        dictionary["token"] = token
        dictionary["username"] = username
        dictionary["is_social_login"] = isSocialLogin
        dictionary["background_image"] = backgroundImage
        
        dictionary["country_code"] = countryCode
        dictionary["country_iso_code"] = countryIsoCode
        var dictionaryElements = [[String:Any]]()
        for gamificationElement in gamification {
            dictionaryElements.append(gamificationElement.toDictionary())
        }
        dictionary["gamification"] = dictionaryElements
        dictionary["mobile"] = mobile
        
        return dictionary
    }
}
