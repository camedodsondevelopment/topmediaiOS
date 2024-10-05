//
//  CustomTabBarController.swift
//  CurvedTabbar
//
//  Created by Gagan  Vishal on 3/25/21.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()
        createTabBarItems()
    }
    
    //MARK:- Create View Controllerss and apply to tabbar
    fileprivate func createTabBarItems(){
        
        delegate = self

        let homeVC = UINavigationController(rootViewController: HomeVC.instantiate(appStoryboard: .Home))
        let chatvc = UINavigationController(rootViewController: ChatVC.instantiate(appStoryboard: .Chat))
        let creatPost = UINavigationController(rootViewController: CreatePostVC.instantiate(appStoryboard: .CreatePost))
        let reelvc = UINavigationController(rootViewController: VideoDetailsVC.instantiate(appStoryboard: .Home))
        let profileVC = UINavigationController(rootViewController: NewDProfileViewController.instantiate(appStoryboard: .Profile))
        
        let homeTab = UITabBarItem(title: "Home", image: UIImage(named: "ic_home"), selectedImage: UIImage(named: "ic_home"))
        let chatTab = UITabBarItem(title: "Chat", image: UIImage(named: "ic_chat"), selectedImage: UIImage(named: "ic_chat"))
        let createTab = UITabBarItem(title: "", image: UIImage(named: "createP"), selectedImage: UIImage(named: "createP"))
        let reelTab = UITabBarItem(title: "Videos", image: UIImage(named: "navVideo"), selectedImage: UIImage(named: "navVideo"))
        let profileTab = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile"))

        homeVC.tabBarItem = homeTab
        chatvc.tabBarItem = chatTab
        creatPost.tabBarItem = createTab
        reelvc.tabBarItem = reelTab
        profileVC.tabBarItem = profileTab
        

        //4.
        tabBar.tintColor = UIColor(named: "AppWhiteFontColor")
        tabBar.unselectedItemTintColor =  UIColor.lightGray
        viewControllers = [homeVC, chatvc, creatPost  ,reelvc, profileVC]
        //5. Set default index to 0
        
        //6. Set middle icon
        for tabBarItem in tabBar.items! where tabBarItem == creatPost.tabBarItem {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: -50, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(viewController)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == viewControllers?[4] {
            if let nav = viewController as? UINavigationController {
                if let profileVC = nav.viewControllers.last, let vc = profileVC as? NewDProfileViewController {
                    vc.userID = ""
                }
                return true
            }
        }
        return true
    }
    
}


