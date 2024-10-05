//
//  SettingVC.swift
//  Nextgen
//
//  Created by Zain Anjum on 20/07/2023.
//

import UIKit

class SettingVC: UIViewController {
    @IBOutlet weak var helpOrReport: UIButton!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var logout : UIButton!
    @IBOutlet weak var backbutton: UIButton!

    //arrow-left 1
    override func viewDidLoad() {
        super.viewDidLoad()
        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        if modeKey == "DARK"{
            backbutton.setImage(UIImage(named: "arrow-left 1"), for: .normal)
        }
    }
    @IBAction func helpBtnTap(_ sender: UIButton) {
        let vc = HelpVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    @IBAction func changePasswordBtnTap(_ sender: UIButton) {
        let vc: ChangePasswordVC = ChangePasswordVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    @IBAction func logoutBtnTap(_ sender: UIButton) {
        CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: "Are you sure want to logout?".localized, buttons: ["Yes".localized, "No".localized]) { index in
            if index == 0 {
                
                ServiceManager.shared.getRequest(ApiURL: .logout, parameters: [:]) { response, isSuccess, error, statusCode in
                    AppShare.shared.isRefreshProfile = false
                    appDelegate.setLoginScreen()
                } Failure: { response, isSuccess, error, statusCode in
                    //failure
                }
            }
        }
    }
    @IBAction func backBtnTap(_ sender: UIButton) {
        self.dismissVC()
    }
    
    @IBAction func deleteAccountBtnTap(_ sender: UIButton) {
        CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: "Are you sure want to delete your whole account? It will remove all the data related to this account.".localized, buttons: ["Yes".localized, "No".localized]) { index in
            if index == 0 {
                ServiceManager.shared.getRequest(ApiURL: .deleteAccount, parameters: [:]) { response, isSuccess, error, statusCode in
                    appDelegate.setLoginScreen()
                } Failure: { response, isSuccess, error, statusCode in
                    //failure
                }
            }
        }
    }
    
    @IBAction func editProfileClicked(_ sender:UIButton){
        let vc : EditProfileVC = EditProfileVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
