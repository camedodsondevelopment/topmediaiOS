//
//  followersFollowingViewModel.swift
//  Nextgen
//
//  Created by Zain Anjum on 22/07/2023.
//

import Foundation
let FollowersData = FollowersModel(personImg: "Vector", usename: "User Name", removeperson: "Remove")
let FollowingData = FollowingModel(personImg: "Vector", usename: "User Name", unfollowperson: "Unfollow")

class FollowersFollowingViewModel {
    let FollowersDetails = [FollowersData, FollowersData, FollowersData, FollowersData, FollowersData, FollowersData ]
    let FollowingDetail = [FollowingData, FollowingData, FollowingData, FollowingData, FollowingData, FollowingData]
}
