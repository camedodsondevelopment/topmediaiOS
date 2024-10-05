//
//  Video.swift
//  TikTokCloneUIKit
//
//  Created by Carlo Luis Martinez Bation on 16/4/21.
//
import AVFoundation

class VideoDataSource {
    static let sharedInstance = VideoDataSource()

    var videos : [ModelVideoListMain] = []
}

class SingleVideoDataSource {
    static let sharedInstance = SingleVideoDataSource()
    
    var videos : [ModelVideoListMain] = []
}

class AppShare {
    static let shared = AppShare()
    
    var singlePost:ModelPostsMain?
    var isRefreshPosts = true
    var isRefreshProfile = true
}
