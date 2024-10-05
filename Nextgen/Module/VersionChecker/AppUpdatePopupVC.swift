//
//  AppUpdatePopupVC.swift
//  Ashh
//
//  Created by M1 Mac mini 4 on 08/06/22.
//

import UIKit

class AppUpdatePopupVC: UIViewController {
    
    var isForceUpdate:Bool = false
    
    @IBOutlet weak var BtnCancel: UIButton!
    @IBOutlet weak var BtnUpdate: UIButton!
    @IBOutlet weak var LblMessage: UILabel!
    var ErrorMessage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.LblMessage.text = ErrorMessage
        if(self.isForceUpdate == true){
            self.BtnCancel.isHidden = true
        }
        else{
            self.BtnCancel.isHidden = false
        }
    }
    @IBAction func BtnCancelAction(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func BtnUpdateAction(_ sender:UIButton){
        let appID : String = "6443882866" //write here the app
        if let url  = URL(string: "itms-apps://itunes.apple.com/app/id\(appID)"),
           UIApplication.shared.canOpenURL(url) {
            guard let url = URL(string: "\(url)"), !url.absoluteString.isEmpty else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            if let url = URL(string: "https://apps.apple.com/us/app/social-crypto-app/id6443882866") {
                UIApplication.shared.open(url)
            }
        }
    }
}

//MARK:- functions for the viewController
func HideAppUpdatePopup(){
    let popupViewController : AppUpdatePopupVC = AppUpdatePopupVC.instantiate(appStoryboard: .main)
    popupViewController.modalPresentationStyle = .custom
    popupViewController.modalTransitionStyle = .crossDissolve
    
    if let topController = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first?.rootViewController {
        if(topController == popupViewController){
            popupViewController.dismiss(animated: true, completion: nil)
        }else {
            let presented = topController.topMostViewController()
            if presented is AppUpdatePopupVC {
                presented.dismiss(animated: true, completion: nil)
            }
        }
    }
}

func showAppUpdatePopup(isForceUpdate:Bool,Message:String){
    //creating a reference for the dialogView controller
    let popupViewController : AppUpdatePopupVC = AppUpdatePopupVC.instantiate(appStoryboard: .main)
    popupViewController.modalPresentationStyle = .custom
    popupViewController.modalTransitionStyle = .crossDissolve
    popupViewController.ErrorMessage = Message
    popupViewController.isForceUpdate = isForceUpdate
    
    if UIApplication.topViewController() is UIAlertController {
        UIApplication.topViewController()?.dismiss(animated: false, completion: {
            if let topController = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first?.rootViewController {
                topController.present(popupViewController, animated: true)
            }
        })
    } else {
        if let topController = UIApplication.shared.windows.filter ({$0.isKeyWindow}).first?.rootViewController {
            topController.present(popupViewController, animated: true)
        }
    }
}


