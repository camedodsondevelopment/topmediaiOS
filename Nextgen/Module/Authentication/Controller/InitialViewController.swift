//
//  InitialViewController.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 07/08/2024.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON


class InitialViewController: AppleLoginVC {

    @IBOutlet weak var logoImage:UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        logoImage.image = UIImage(named: "Logo-Black")
        if modeKey == "DARK"{
            logoImage.image = UIImage(named: "Logo-white")
        }
        
    }
    
    
    @IBAction func loginWithGoogle(_ sender: UIButton) {
        GoogleLogin()
    }
    
    @IBAction func loginWithFacebook(_ sender: UIButton) {
        FaceBookLogin()
    }
    
    @IBAction func loginWithApple(_ sender: UIButton) {
        AppleSignINBlock()
    }
    
    @IBAction func loginWithPassword(_ sender: UIButton) {
        let sb = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        sb.modalPresentationStyle = .fullScreen
        present(sb, animated: false)
    }
    
    @IBAction func singUpBtn(_ sender: UIButton) {
        let vc: RegisterVC = RegisterVC.instantiate(appStoryboard: .main)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
