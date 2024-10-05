//
//  LoginVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyJSON

class LoginVC: AppleLoginVC {
    
    // MARK: - OUTLETS
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var invalidEmailPasswordLabel: UILabel!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    // MARK: - VARIABLES
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppShare.shared.isRefreshProfile = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginButton.layer.cornerRadius = 10.0
        btnLayer(btn: fbButton)
        btnLayer(btn: googleButton)
        btnLayer(btn: appleButton)
    }
    
    func btnLayer(btn: UIButton){
        btn.layer.cornerRadius = 10.0
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.6
    }
    
    // MARK: - Button Actions
    @IBAction func btnRegistertap(_ sender: UIButton) {
        let vc: RegisterVC = RegisterVC.instantiate(appStoryboard: .main)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismissVC()
    }
    
    
    @IBAction func btnDoSocialLogin(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        
        switch sender.tag {
        case 0 :
            self.FaceBookLogin()
        case 1 :
            //TODO: GOOGLE LOGIN CLIENT KEY
            print("GOOGLE LOGIN")
            self.GoogleLogin()
            
        case 2 :
            //TODO: FaceBook LOGIN CLIENT KEY
            print("FaceBook LOGIN")
            
            
            self.AppleSignINBlock()
            
        default:
            print(sender.tag)
        }
        
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        if validateData() {
            DispatchQueue.main.async {
                self.startActivityIndicator()
            }
            let dict : [String : Any] =
            [
                kPushToken : appDelegate.fcmRegTokenMessage,
                kDeviceType : kiOS,
                kDeviceID : UIDevice.current.identifierForVendor?.uuidString ?? "",
                kPassword : txtPassword.text!,
                kemail : txtEmail.text!
            ]
            
            WSLogin(Parameter: dict)
        }
    }
    
    @IBAction func btnforgotPaswordtapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        let vc: ForgotPasswordVC = ForgotPasswordVC.instantiate(appStoryboard: .main)
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func btnPasswordtapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        GeneralUtility().addButtonTapHaptic()
        txtPassword.isSecureTextEntry = !sender.isSelected
    }
}


extension LoginVC {
    
    // TODO: Validation
    func validateData() -> Bool {
        
        guard (txtEmail.text!.removeWhiteSpace().count) > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.EmailNameMissing)
            return false
        }
        
        guard (txtEmail.text)!.isEmail() else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.ValidEmail)
            return false
        }
        
        guard (txtPassword.text?.removeWhiteSpace().count)! > 0 else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.PasswordMissing)
            return false
        }
        
        return true
    }
}

//MARK: - WebService Call
extension LoginVC {
    
    //TODO: Login API Call
    func WSLogin(Parameter:[String:Any]) -> Void {
        print("API Data:", Parameter)
        ServiceManager.shared.postRequest(ApiURL: .login, parameters: Parameter) { (response, Success, message, statusCode) in
            
            if Success == true{
                NextgenUser.shared.setData(dict: response["data"])
                appDelegate.setHomeRoot()
            }
            self.stopActivityIndicator()
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            
            self.stopActivityIndicator()
        }
    }
    
}

//MARK: - FACEBOOOK Login
extension UIViewController {
    
    func FaceBookLogin()
    {
        
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(permissions:   ["public_profile", "email"], from: self) { (fbloginresult, error) -> Void in
            
            if (error == nil) {
                
                guard fbloginresult != nil else {
                    return
                }
                
                let permissionDictionary = [
                    "fields" : "id,name,first_name,last_name,gender,email,birthday,picture.type(large)"]
                let pictureRequest = GraphRequest(graphPath: "me", parameters: permissionDictionary)
                
                pictureRequest.start { connection, result, error in
                    
                    if error == nil {
                        guard let result = result else { return }
                        
                        let results = JSON(result)
                        print("Logged in : \(String(describing: results))")
                        var parameters = [String:Any]()
                        parameters[kName] = results["name"].stringValue
                        parameters[kemail] = results["email"].stringValue
                        parameters[kUsername] = results["last_name"].stringValue
                        parameters[kSocialID] = results["id"].stringValue
                        parameters[kType] = "facebook"
                        parameters["is_exist"] = 0
                        
                        parameters[kDeviceID] = UIDevice.current.identifierForVendor?.uuidString ?? ""
                        parameters[kDeviceType] = kiOS
                        parameters[kPushToken] = appDelegate.fcmRegTokenMessage
                        
                        self.WSCheckSocialRegister(Parameter: parameters)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            fbLoginManager.logOut()
                        }
                        
                    } else {
                        
                        print("error \(String(describing: error.debugDescription))")
                    }
                }
                
                let manager = LoginManager()
                manager.logOut()
            }
        }
    }
}

//MARK: - APPLE LOGIN
class AppleLoginVC : UIViewController {
    
    let appleSignIn = HSAppleSignIn()
    
    func AppleSignINBlock() {
        appleSignIn.didTapLoginWithApple()
        appleSignIn.appleSignInBlock = { (userInfo, message) in
            if let userInfo = userInfo{
                
                var registerDetail = [String:Any]()
                registerDetail[kName] = userInfo.firstName
                registerDetail[kemail] = userInfo.email
                registerDetail[kUsername] = userInfo.lastName
                registerDetail[kSocialID] = userInfo.userid
                registerDetail[kType] = kApple
                registerDetail["is_exist"] = 0
                
                registerDetail[kDeviceID] = UIDevice.current.identifierForVendor?.uuidString ?? ""
                registerDetail[kDeviceType] = kiOS
                registerDetail[kPushToken] = appDelegate.fcmRegTokenMessage
                DispatchQueue.main.async {
                    self.WSCheckSocialAvailability(Parameter: registerDetail)
                }
                
                
            }else if let message = message{
                print("Error Message: \(message)")
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME , andMessage: "\(message)", buttons: ["Dismiss".localized]) { (i) in
                }
                
                return
            }else{
                print("Unexpected error!")
            }
        }
    }
}


//MARK: - GOOGLE LOGINs
extension  UIViewController {
    
    func GoogleLogin() {
        
        let signInConfig = GIDConfiguration.init(clientID: googleClientKey)
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { user, error in
            DispatchQueue.main.async {
                self.HIDE_CUSTOM_LOADER()
            }
            guard error == nil else { return }
            
            var registerDetail = [String:Any]()
            guard let guser = user?.user.profile else {return}
            registerDetail[kName] = guser.name
            registerDetail[kemail] = guser.email
            registerDetail[kSocialID] = user?.user.userID ?? ""
            registerDetail[kUsername] = guser.givenName ?? ""
            registerDetail[kType] = "google"
            registerDetail["is_exist"] = 0
            
            registerDetail[kDeviceID] = UIDevice.current.identifierForVendor?.uuidString ?? ""
            registerDetail[kDeviceType] = kiOS
            registerDetail[kPushToken] = appDelegate.fcmRegTokenMessage
            
            DispatchQueue.main.async {
                self.WSCheckSocialAvailability(Parameter: registerDetail)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                GIDSignIn.sharedInstance.signOut()
            }
        }
    }
}

//MARK: - GENERAL METHOD
extension UIViewController {
    
    func WSCheckSocialAvailability(Parameter:[String:Any]) -> Void {
        
        ServiceManager.shared.postRequest(ApiURL: .checkSocialAvaibilty, parameters: Parameter) { (response, Success, message, statusCode) in
            
            if Success == true{
                NextgenUser.shared.setData(dict: response["data"])
                appDelegate.setHomeRoot()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: message.localized)
        }
    }
    func WSCheckSocialRegister(Parameter:[String:Any]) -> Void {
        
        ServiceManager.shared.postRequest(ApiURL: .SocialRegister, parameters: Parameter) { (response, Success, message, statusCode) in
            
            if Success == true{
                NextgenUser.shared.setData(dict: response["data"])
                appDelegate.setHomeRoot()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
    }
}
