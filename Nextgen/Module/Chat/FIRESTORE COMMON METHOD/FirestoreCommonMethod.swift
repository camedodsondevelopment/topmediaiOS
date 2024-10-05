//
//  FirestoreCommonMethod.swift
//  Nextgen
//
//  Created by Jacky Patel on 18/10/22.
//

import Foundation
import FirebaseFirestore
import SwiftyJSON

enum MYFirebaseDatabaseCollection: String {
    case chatmsgs = "newchatnewmsgs"
    case usersdetails = "usersdetails"
    case chatlists = "chatlists"
}

struct OLDChat {
    var users: [String]
    
    var dictionary: [String: Any] {
        return ["users": users]
    }
}

extension OLDChat {
    init?(dictionary: [String: Any]) {
        guard let chatUsers = dictionary["users"] as? [String]
        
        else {return nil}
        self.init(users: chatUsers)
    }
}

struct Chat {
   
    var users: [String]
    var lastmsg: String
    var unreadcount: Int
    var chat_created: Timestamp
    var lastmsgtime: Timestamp
    var sentbyDetails: OtherUserDetails?
}

extension Chat {
    init?(dictionary: [String: Any]) {
        guard let chatUsers = dictionary["users"] as? [String] else { return nil }
                
        guard let unreadcount = dictionary["unreadcount"] as? Int else { return nil }
        
        guard let lastmsg = dictionary["lastmsg"] as? String else { return nil }
        
        guard let lastmsgtime = dictionary["lastmsgtime"] as? Timestamp else { return nil }
        
        guard let chat_created = dictionary["chat_created"] as? Timestamp else { return nil }
        
        let sentbyDetails = OtherUserDetails(dictionary: (dictionary["sent_by"] as? [String: Any] ?? [:]))
        
        self.init(users: chatUsers, lastmsg: lastmsg, unreadcount: unreadcount, chat_created: chat_created, lastmsgtime: lastmsgtime, sentbyDetails: sentbyDetails)
    }
}

struct OtherUserDetails {
    
    public var profileImage: String?
    public var name: String?
    public var email: String?
    public var internalIdentifier: String?
}

extension OtherUserDetails {
    init?(dictionary: [String: Any]) {
        
        let jsonOBJ = JSON(dictionary)
        
        let profileImage = jsonOBJ["profile_image"].stringValue
        let email = jsonOBJ["email"].stringValue
        let internalIdentifier = jsonOBJ["id"].stringValue
        let name = jsonOBJ["name"].stringValue
        
        self.init(profileImage: profileImage, name: name, email: email, internalIdentifier: internalIdentifier)
    }
    
    func toDictonary() -> [String : Any] {
        var dict : [String : Any] = [:]
        
        dict["name"] = self.name ?? ""
        dict["profile_image"] = self.profileImage ?? ""
        dict["email"] = self.email ?? ""
        dict["id"] = self.internalIdentifier ?? ""
        return dict
    }
}

class FirestoreCommonMethod {
    
    var db: Firestore!
    
    static var shared: FirestoreCommonMethod = {
        var instance = FirestoreCommonMethod()
        // setup code
        return instance
    }()
    
    init() {
        db = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings())
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        db.settings = settings
        Firestore.firestore().settings = settings

    }
    
    func savePushTokens(token: String) {
        let data: [String: Any] = [
            "senderID" : NextgenUser.shared.id,
            "fcm_token" : token]
       
        if NextgenUser.shared.id != "" {
            self.addDataIntoCollection(collection: MYFirebaseDatabaseCollection.usersdetails.rawValue, userID: NextgenUser.shared.id, dataAdding: data) { isadd in
                
            }
        }
    }
    
    func addDataIntoCollection(collection: String, userID: String, dataAdding: [String: Any], successBlock: @escaping (Bool) -> Void) {
        let ref = db.collection(collection).document(userID)
        ref.setData(dataAdding, merge: true) { err in
            if let err = err {
                print("Error adding document: \(err)")
                
                CommonClass().showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: err.localizedDescription)
                successBlock(false)
            } else {
                print("Document added with ref: \(ref)")
                successBlock(true)
            }
        }
    }
    
    func updateDataIntoCollection(collection: String, userID: String, dataAdding: [String: Any], successBlock: @escaping (Bool) -> Void) {
        let ref = db.collection(collection).document(userID)
        ref.setData(dataAdding, merge: true) { err in
            if let err = err {
                print("Error updating document, reason: \(err)")
                CommonClass().showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: err.localizedDescription)
                successBlock(false)
            } else {
                print("Document successfully updated")
                successBlock(true)
            }
        }
    }
    
    func getConversionMessages(collection: String, userID: String, successBlock: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let collectionRef = self.db.collection(collection)
            collectionRef.addSnapshotListener { (querySnapshot, err) in
                if let _ = querySnapshot?.documents {
                    
                } else {
                    successBlock(false)
                }
            }
        }
    }
    
    func sendMessage(collectionMain: String, collectionSub: String, chatID: String, dataAdding: [String: Any], successBlock: @escaping (Bool) -> Void) {
        db.collection(collectionMain).document(chatID).collection(collectionSub).addDocument(data: dataAdding) { err in
            if let err = err {
                print("Error updating document, reason: \(err)")
                CommonClass().showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: err.localizedDescription)
                successBlock(false)
                
            } else {
                print("Document successfully updated")
                successBlock(true)
            }
        }
    }
    
    func createThreadID(successBlock: @escaping (Int) -> Void) {
        DispatchQueue.main.async {
            let collectionRef = self.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue)
            collectionRef.addSnapshotListener { (querySnapshot, err) in
                if let _ = querySnapshot?.documents {
                    successBlock((Int(querySnapshot?.documents.last?.documentID ?? "") ?? 0) + 1)
                } else {
                    successBlock(1)
                }
            }
        }
    }
}
