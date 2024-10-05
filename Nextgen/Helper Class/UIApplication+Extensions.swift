//
//  UIApplication+Extensions.swift
//  PM-TRAC
//
//  Created by muhammad on 17/06/2020.
//  Copyright © 2020 muhammad. All rights reserved.
//

import UIKit

extension UIApplication {
    
    func setCustomStatusBarColor(color:UIColor){
        if #available(iOS 13.0, *) {
            let statusBar1 =  UIView()
            if let frame = UIApplication.shared.windows[0].windowScene?.statusBarManager!.statusBarFrame {
                statusBar1.frame = frame
            }
            statusBar1.backgroundColor = color
            UIApplication.shared.windows[0].addSubview(statusBar1)
            
        } else {
            
            let statusBar1: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            statusBar1.backgroundColor = color
        }
    }
    
    func topViewController(base: UIViewController? = UIApplication.shared.windows[0].rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    func topNavigationController(_ viewController: UIViewController? = UIApplication.shared.windows[0].rootViewController) -> UINavigationController? {
        
        if let nav = viewController as? UINavigationController {
            return nav
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.navigationController
            }
        }
        return viewController?.navigationController
    }
}

extension UIApplication {
    func topMostViewController(controller: UIViewController? = UIApplication.shared.windows[0].rootViewController) -> UIViewController? {
        
        if let navigationController = controller as? UINavigationController {
            return topMostViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController,
           let selectedViewController = tabController.selectedViewController {
            return topMostViewController(controller: selectedViewController)
        }
        
        if let presentedViewController = controller?.presentedViewController {
            return topMostViewController(controller: presentedViewController)
        }
        
        return controller
    }
    
}
