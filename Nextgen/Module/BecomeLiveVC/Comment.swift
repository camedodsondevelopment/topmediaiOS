//
//  Comment.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 27/09/2024.
//

import UIKit

struct Comment {
    let id: String
    let userId: String
    let userName: String
    let userImg:String
    let commentText: String
    let timestamp: TimeInterval
    
    init(id: String, userId: String, userName: String, userImg: String, commentText: String, timestamp: TimeInterval) {
        self.id = id
        self.userId = userId
        self.commentText = commentText
        self.timestamp = timestamp
        self.userName = userName
        self.userImg = userImg
    }
}
