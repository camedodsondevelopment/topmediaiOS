//
//  LoaderClass.swift
//  DemoServiceManage
//
//  Created by Zestbrains on 11/06/21.
//

import Foundation
import UIKit

class LoadingDailog: UIViewController {
    //MARK: - Shared Instance
    static let sharedInstance : LoadingDailog = {
        let instance = LoadingDailog()
        return instance
    }()
    
    func startLoader() {
        startActivityIndicator()
    }
    
    func stopLoader() {
        stopActivityIndicator()
    }
 }

//MARK: HIDE/SHOW LOADERS
public func HIDE_CUSTOM_LOADER(){
    LoadingDailog.sharedInstance.stopLoader()
}
public func SHOW_CUSTOM_LOADER(){
    LoadingDailog.sharedInstance.startLoader()
}

//MARK: Loading indicater and Alert From UIVIEWController
extension UIViewController {
    
    //MARK: - Show/Hide Loading Indicator
    func SHOW_CUSTOM_LOADER() {
        LoadingDailog.sharedInstance.startLoader()
    }
    func HIDE_CUSTOM_LOADER() {
        LoadingDailog.sharedInstance.stopLoader()
    }
    
}


