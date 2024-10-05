//
//  StroryboardExtension.swift
//  Persell
//
//  Created by Himanshu Visroliya on 11/06/22.
//

import Foundation
import UIKit

enum AppStoryboard: String {
    
    case main = "Main"
    case Home = "Home"
    case Tabbar = "Tabbar"
    case Chat = "Chat"
    case Notifications = "Notifications"
    case Profile = "Profile"
    case CreatePost = "CreatePost"
}

extension UIViewController {
    
    class func instantiate<T: UIViewController>(appStoryboard: AppStoryboard) -> T {
        
        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T ?? T()
    }
}
