//
//  ChatViewModel.swift
//  Nextgen
//
//  Created by Jacky Patel on 20/10/22.
//

import Foundation
import UIKit
import FirebaseFirestore
import SwiftyJSON

struct MessagesViewModelData {
    
    var date = ""
    var allTheMessages = [MessagesViewModel]()
}

struct MessagesViewModel {
    
    var value = ""
    var created: Timestamp?
    var id = ""
    var senderName = ""
    var senderID = ""
    var push_token = ""
    var fcm_token = ""
    var is_read = ""
    var users = [String]()
}

extension MessagesViewModel {
    init?(dictionary: [String: Any]) {
        guard let chatUsers = dictionary["users"] as? [String],
              let value = dictionary["value"] as? String,
              let created = dictionary["created"] as? Timestamp,
              let id = dictionary["id"] as? String,
              let senderName = dictionary["senderName"] as? String,
              let senderID = dictionary["senderID"] as? String,
              let push_token = dictionary["push_token"] as? String,
              let is_read = dictionary["is_read"] as? String,
              let fcm_token = dictionary["fcm_token"] as? String
                
        else {return nil}
        self.init(value: value, created: created, id: id, senderName: senderName, senderID: senderID, push_token: push_token, fcm_token: fcm_token, is_read: is_read, users: chatUsers)
    }
}

class ChatViewModel {
    
    var currentChat: Chat?
    var vc: ChatDetailsVC?
    var myChatList: ChatVC?
    var otherUserID = ""
    var msgTyped = ""
    var arrOfMessages = [MessagesViewModelData]()
    var arrOfConversions = [Chat]()
    private var docReference: DocumentReference?
    let fullName = NextgenUser.shared.name.removeWhiteSpace()
    let profileImage = NextgenUser.shared.profileImage

    var otherUserDetails = [String: Any]()
    var currentUserDetails = [String: Any]()
    let currentType = "user"

    
    func createNewChat() {
        
        let users = [NextgenUser.shared.id, self.otherUserID]
        
        let data: [String: Any] = [
            "users": users,
            "\(NextgenUser.shared.id)": self.currentUserDetails,
            "\(self.otherUserID)": self.otherUserDetails,
            "chat_created": Timestamp(),
            "lastmsg": "",
            "lastmsgtime": Timestamp(),
            "is_read" : "0"
         ]
                            
        let db = FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue)
        db.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChatMsgs()
            }
        }
    }
    
    func doUpdateSeen(msgID: String) {
        docReference?.collection("thread").whereField("id", isEqualTo: msgID).getDocuments { (document, error) in
            if let docs = document {
                docs.documents.first?.reference.updateData(["is_read": "1"], completion: { error in
                    
                })
            }
        }
    }
    
    func deleteChat(msgID: String, complete: @escaping () -> Void) {
        docReference?.collection("thread").whereField("id", isEqualTo: msgID).getDocuments { (document, error) in
            if let docs = document {
                docs.documents.first?.reference.delete(completion: { error in
                    if error == nil {
                        complete()
                    }
                })
            }
        }
    }
    
    func getOtherDetails(userData: @escaping ([String: Any]) -> Void) {
        let db = FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.usersdetails.rawValue).document(self.otherUserID)
        db.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                userData(dataDescription ?? [:])
            } else {
                print("Document does not exist")
                userData([:])
            }
        }
    }
        
    func save(isWithoutPush: Bool = false) {
        
        let data: [String: Any] = [
            "value": self.msgTyped,
            "created": Timestamp(),
            "id": UUID().uuidString,
            "is_read": "0",
            "push_token": appDelegate.deviceToken,
            "senderID": NextgenUser.shared.id,
            "senderName": fullName,
            "fcm_token": appDelegate.fcmRegTokenMessage,
            "users": [NextgenUser.shared.id, self.otherUserID]
        ]
                
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            
            let db = FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue)
                .whereField("users", arrayContains: NextgenUser.shared.id)

            db.getDocuments { (document, error) in
                if let docs = document {
                    
                    docs.documents.forEach { snapSht in
                        
                        if let usersArr = snapSht.data()["users"] as? [String], usersArr.containsSameElements(as: [NextgenUser.shared.id, self.otherUserID]) {
                            var data = [String: Any]()
                            data["lastmsg"] = self.msgTyped
                            data["lastmsgtime"] = Timestamp()
                            
                            snapSht.reference.updateData(data, completion: { error in
                                
                            })
                        }
                        
                    }
                }
            }
            
            if !isWithoutPush {
                self.getOtherDetails { user in
                    if user.count > 0 {
                        if let pushh = user["fcm_token"] as? String, pushh != "" {
                            self.sendChatPush(token: pushh, currentType: user["currentType"] as? String ?? "") { _ in
                                self.vc?.txtMessage.text = ""
                            } failure: { errorResponse in
                            }
                        }
                    } else {
                        self.vc?.txtMessage.text = ""
                    }
                }
            }
        })
    }
   
    func updateMyData(successBlock: @escaping (Bool) -> Void) {
        
        let db = FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue).whereField("users", arrayContains: NextgenUser.shared.id)
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                successBlock(false)
                
            } else {
               
                if (chatQuerySnap?.documents.count ?? 0) > 0 {
                    // Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        
                        var data: [String: Any] = [:]
                        let myProfile = ["email": NextgenUser.shared.email,
                                         "name": NextgenUser.shared.name,
                                         "id": "\(NextgenUser.shared.id)",
                                         "profile_image": NextgenUser.shared.profileImage]
                        
                        data["\(NextgenUser.shared.id)"] = myProfile
                        
                        doc.reference.updateData(data) { errr in
                            successBlock(true)
                        }
                    }
                } else {
                    print("Let's hope this error never prints!")
                    successBlock(false)
                }
            }
        }
    }
    
    func loadAllTheConversions(successBlock: @escaping (Bool, Int) -> Void) {
        let db = FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue)
            .whereField("users", arrayContains: NextgenUser.shared.id)
            .order(by: "lastmsgtime", descending: true)
        
        db.addSnapshotListener(includeMetadataChanges: true, listener: { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                successBlock(false, 0)
                return
            } else {
                // Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    successBlock(false, 0)
                    return
                }
                
                if queryCount == 0 {
                    // If documents count is zero that means there is no chat available and we need to create a new instance
                    successBlock(false, 0)
                    
                } else if queryCount >= 1 {
                    // Chat(s) found for currentUser
                    self.arrOfConversions.removeAll()

                    for doc in chatQuerySnap!.documents {
                        if let usersArr = doc.data()["users"] as? [String] {
                            
                            self.otherUserID = usersArr.filter({$0 != NextgenUser.shared.id})[0]

                            var myChat = doc.data()
                            myChat["sent_by"] = doc.data()["\(self.otherUserID)"] as? [String: Any] ?? [:]
                            myChat["lastmsg"] = doc.data()["lastmsg"] as? String ?? ""
                            myChat["lastmsgtime"] = doc.data()["lastmsgtime"] as? Timestamp ?? ""
                            myChat["chat_created"] = doc.data()["chat_created"] as? Timestamp ?? ""
                            myChat["unreadcount"] = 0
                            
                            if let chat = Chat(dictionary: myChat) {                                
                                //TODO:
                                //self.arrOfConversions.removeAll(where: {$0.post_id == chat.post_id})
                                self.arrOfConversions.append(chat)
                                self.arrOfConversions = self.arrOfConversions.sorted(by: { $0.lastmsgtime.dateValue().compare($1.lastmsgtime.dateValue()) == .orderedDescending })
                                self.myChatList?.tblChat.reloadData()
                                
                            } else {
                                print("issue with chat model")
                            }
                        }
                    }
                    successBlock(true, 1)
                } else {
                    successBlock(false, 0)
                    print("Let's hope this error never prints!")
                }
            }
        })
    }
    
    func getSingleConversion(successBlock: @escaping (Bool) -> Void) {
        FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue)
            .whereField("users", arrayContains: NextgenUser.shared.id)
            .order(by: "lastmsgtime", descending: true)
            .getDocuments { (chatQuerySnap, error) in
                if let error = error {
                    print("Error: \(error)")
                    successBlock(false)
                    return
                } else {
                    // Count the no. of documents returned
                    guard let queryCount = chatQuerySnap?.documents.count else {
                        successBlock(false)
                        return
                    }
                    
                    if queryCount == 0 {
                        // If documents count is zero that means there is no chat available and we need to create a new instance
                        successBlock(false)
                        
                    } else if queryCount >= 1 {
                        // Chat(s) found for currentUser
                        for doc in chatQuerySnap!.documents {
                            if let usersArr = doc.data()["users"] as? [String] {
                                
                                self.otherUserID = usersArr.filter({$0 != NextgenUser.shared.id})[0]
                                        
                                // Getting other user details
                                var myChat = doc.data()
                                myChat["sent_by"] = doc.data()["\(self.otherUserID)"] as? [String: Any] ?? [:]
                                myChat["lastmsg"] = doc.data()["lastmsg"] as? String ?? ""
                                myChat["lastmsgtime"] = doc.data()["lastmsgtime"] as? Timestamp ?? ""
                                myChat["chat_created"] = doc.data()["chat_created"] as? Timestamp ?? ""
                                myChat["unreadcount"] = 0
                                
                                if let chat = Chat(dictionary: myChat) {
                                    self.currentChat = chat
                                    successBlock(true)
                                    
                                } else {
                                    print("issue with chat model")
                                }
                            }
                        }
                    } else {
                        successBlock(false)
                        print("Let's hope this error never prints!")
                    }
                }
            }
    }
    
    func loadChatMsgs() {
        let db = FirestoreCommonMethod.shared.db.collection(MYFirebaseDatabaseCollection.chatmsgs.rawValue)
            .whereField("users", arrayContains: NextgenUser.shared.id)
//            .whereField("users", arrayContains: otherUserID)
            //.whereField("users", arrayContainsAny: [NextgenUser.shared.id, otherUserID].sorted(by: {$0 < $1}))
            
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                // Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                if queryCount == 0 {
                    // If documents count is zero that means there is no chat available and we need to create a new instance
                    self.createNewChat()
                    
                } else if queryCount >= 1 {
                    // Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        let chat = OLDChat(dictionary: doc.data())
                        
                        if (chat?.users.contains(self.otherUserID)) == true {
                            self.docReference = doc.reference
                            
                            doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        self.arrOfMessages.removeAll()
                                        for message in threadQuery!.documents {
                                            if let msg = MessagesViewModel(dictionary: message.data()) {
                                                
                                                let dateString = msg.created?.dateValue().formatRelativeString()
                                                let data = MessagesViewModelData.init(date: dateString ?? "", allTheMessages: [msg])
                                                let indexx = self.arrOfMessages.firstIndex(where: {($0.date == dateString)})
                                                if indexx != nil {
                                                    self.arrOfMessages[self.arrOfMessages.count - 1].allTheMessages.insert(msg, at: 0)
                                                } else {
                                                    self.arrOfMessages.append(data)
                                                }
                                            }
                                        }
                                        self.arrOfMessages = self.arrOfMessages.reversed()
                                        self.vc?.tblMessages.reloadData()
                                    }
                                })
                            return
                        }
                    }
                    self.createNewChat()
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
}

extension ChatViewModel {
    
    func createPushDict(token: String) -> [String: Any] {
        var mainDict = [String: Any]()
        
        mainDict["to"] = token
        mainDict["push_type"] = 1
        mainDict["user_type"] = self.currentType
        mainDict["aps"] = self.createAPSDict(currentType: currentType)
        mainDict["notification"] = self.createNotificationDict(currentType: currentType)
        mainDict["data"] = self.createDataDict(currentType: currentType)
        
        return mainDict
    }
    
    private func createAPSDict(currentType: String) -> [String: Any] {
        var mainDict = [String: Any]()
        
        mainDict["alert"] = "\(self.fullName) sent you a message"
        mainDict["badge"] = 1
        mainDict["mutable-content"] = 1
        mainDict["push_type"] = 1
        mainDict["sound"] = "default"
        mainDict["user_type"] = currentType
        
        return mainDict
    }
    
    private func createDataDict(currentType: String) -> [String: Any] {
        var mainDict = [String: Any]()
        
        mainDict["badge"] = 1
        mainDict["from_user_id"] = NextgenUser.shared.id
        mainDict["push_message"] = self.msgTyped
        mainDict["push_title"] = "\(self.fullName) sent you a message"
        mainDict["push_type"] = 1
        mainDict["user_type"] = currentType
        mainDict["sound"] = "default"
        mainDict["user_id"] = self.otherUserID
        mainDict["sender_name"] = self.fullName
        mainDict["sender_profile"] = self.profileImage
        
        return mainDict
    }
    
    private func createNotificationDict(currentType: String) -> [String: Any] {
        var mainDict = [String: Any]()
        
        mainDict["body"] = self.msgTyped
        mainDict["title"] = "\(self.fullName) sent you a message"
        mainDict["badge"] = 1
        mainDict["sound"] = "default"
        mainDict["user_type"] = currentType
        
        return mainDict
    }
    
    func sendChatPush(token: String, currentType: String, isShowLoader: Bool = false, success: @escaping (JSON) -> Void, failure: @escaping (_ errorResponse: JSON) -> Void) {
        GeneralUtility().addButtonTapHaptic()
        ServiceManager.shared.postRequestForSendFCM(ApiURL: "https://fcm.googleapis.com/v1/projects/nextgen-1665319772916/messages", parameters: self.createPushDict(token: token), isShowLoader: isShowLoader) { (response, Success, message, statusCode) in
            if Success == true {
                success(response)
            } else {
                failure(response)
            }
            
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:", response)
            failure(response)
        }
    }
}

extension Date {

    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true

        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            return "Today"
            
        } else if calendar.isDateInYesterday(self) {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
            return "Yesterday"
            
        } else {
            dateFormatter.dateFormat = "EEE, MMM d, yyyy"
            
            return dateFormatter.string(from: self)
        }
    }
}

extension Dictionary {

    static func += (left: inout [Key: Value], right: [Key: Value]) {
        for (key, value) in right {
            left[key] = value
        }
    }
}
// MARK: - Array Extenstion
extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var uniqueValues = [Element]()
        forEach {
            if !uniqueValues.contains($0) {
                uniqueValues.append($0)
            }
        }
        return uniqueValues
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
