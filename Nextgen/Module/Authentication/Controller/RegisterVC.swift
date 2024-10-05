//
//  RegisterVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import SwiftyJSON
import SKCountryPicker
import GoogleSignIn
import FirebaseAuth

class RegisterVC: UIViewController {
    
    @IBOutlet weak var registerBtn: UIButton!
    // MARK: - OUTLETS
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var confirmTxtPassword:UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var lastName:UITextField!
    @IBOutlet weak var dob:UITextField!

    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    
    
    // MARK: - VARIABLES
    var isFromSocialRegister : Bool = false
    var countryShortCode : String = "US"
    let appleSignIn = HSAppleSignIn()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromSocialRegister {
            txtEmail.isUserInteractionEnabled = false
        }else {
            txtEmail.isUserInteractionEnabled = true
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerBtn.layer.cornerRadius = 10.0
        btnLayer(btn: fbBtn)
        btnLayer(btn: googleBtn)
        btnLayer(btn: appleBtn)
    }
    
    func btnLayer(btn: UIButton){
        btn.layer.cornerRadius = 10.0
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 0.6
    }
    
    // MARK: - Button Actions
    @IBAction func loginNowButtonTapped(_ sender: UIButton) {
        let vc: LoginVC = LoginVC.instantiate(appStoryboard: .main)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        dismissVC()
    }
    
    @IBAction func btnCountryPickerClicks(_ sender: Any) {
        CountryPickerWithSectionViewController.presentController(on: self, configuration: { countryController in
            countryController.configuration.flagStyle = .circular
            
        }) { [weak self] country in
            
            guard let self = self else { return }
            self.lblCountryCode.text = country.dialingCode ?? ""
            self.countryShortCode = country.countryCode
        }
    }
    
    @IBAction func btnTermsConditionsClicks(_ sender: Any) {
        let vc = CommonWebViewVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func btnSocialsignup(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        
        switch sender.tag {
        case 0 :
            self.FaceBookLogin()
        case 1 :
            googlesign()
        case 2 :
            AppleSign()
        default:
            print(sender.tag)
        }
        
    }
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        if validateData() {
            let param : [String : Any] =
            [
                kPushToken : appDelegate.fcmRegTokenMessage,
                kDeviceType : kiOS,
                kDeviceID : UIDevice.current.identifierForVendor?.uuidString ?? "",
                kPassword : txtPassword.text!,
                "username" : lastName.text ?? "",
                kemail : txtEmail.text!,
                "name" : txtName.text ?? "",
                "firebase_uid" : "TEMPRORY_UID",
                "dob" : dob.text ?? "",
                "country_iso_code" : countryShortCode,
                "mobile" : txtMobile.text ?? "",
                "country_code" : lblCountryCode.text ?? "",
            ]
            
            if isFromSocialRegister {
                self.WSSocialRegister(Parameter: param)
                return
            }
            
            WSRegister(Parameter: param)
        }
    }
    
    @IBAction func btnPasswordtapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        self.txtPassword.isSecureTextEntry = !self.txtPassword.isSecureTextEntry
    }
}

extension RegisterVC {
    
    // TODO: Validation
    func validateData() -> Bool {
        
        guard (txtEmail.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.EmailNameMissing)
            return false
        }
        
        guard (txtEmail.text)!.removeWhiteSpace().isEmail() else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.ValidEmail)
            return false
        }
        
        if !isFromSocialRegister {
            
            guard (txtPassword.text?.removeWhiteSpace().count)! > 0 else
            {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.PasswordMissing)
                return false
            }
            
            guard (txtPassword.text?.removeWhiteSpace().count)! >= 6 else
            {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.PasswordMinMissing)
                return false
            }
            
            guard (txtPassword.text?.removeWhiteSpace().count)! == (confirmTxtPassword.text?.removeWhiteSpace().count)! else
            {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.PasswordNotMatch)
                return false
            }
            
            if txtPassword.text != confirmTxtPassword.text {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.PasswordNotMatch)
                return false
            }
            
        }
        if  validatePassword(password:txtPassword.text ?? "" ) == false{
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: ("Password must have at least one uppercase letter, one lowercase letter, one digit, and one special character"))
            return false
        }
        return true
    }
}

//MARK: - WebService Call
extension RegisterVC {
    
    func WSRegister(Parameter:[String:Any]) -> Void {
        
        ServiceManager.shared.postMultipartRequest(ApiURL: .signup, imageVideoParameters: [], parameters: Parameter) { response, isSuccess, error, statusCode in
            
            if isSuccess == true{
                NextgenUser.shared.setData(dict: response["data"])
                
                appDelegate.setHomeRoot()
            }
            
        } Failure: { response, isSuccess, error, statusCode in
            print("Failure", (response, isSuccess, error, statusCode))
        }
    }
    
    func WSSocialRegister(Parameter:[String:Any]) -> Void {
        self.startActivityIndicator()
        ServiceManager.shared.postMultipartRequest(ApiURL: .SocialRegister, imageVideoParameters: [], parameters: Parameter) { response, isSuccess, error, statusCode in
            
            if isSuccess == true{
                NextgenUser.shared.setData(dict: response["data"])
                
                appDelegate.setHomeRoot()
            }
            self.stopActivityIndicator()
            
        } Failure: { response, isSuccess, error, statusCode in
            print("Failure", (response, isSuccess, error, statusCode))
            self.stopActivityIndicator()
        }
    }
    
    
}


//MARK: - GENERAL METHOD
extension RegisterVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        if textField == txtMobile {
            textField.text = GeneralUtility.sharedInstance.format(with: "XXX-XXX-XXXX", phone: newString)
            return false
        }
        
        if textField == dob {
            textField.text = GeneralUtility.sharedInstance.format(with: "XXXX-XX-XX", phone: newString)
            return false
        }
        return true
    }
}

extension RegisterVC{
    func googlesign() {
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
            registerDetail[firebaseID] = "TEMPRORY_UID"
            registerDetail[kDeviceID] = UIDevice.current.identifierForVendor?.uuidString ?? ""
            registerDetail[kDeviceType] = kiOS
            registerDetail[kPushToken] = appDelegate.fcmRegTokenMessage
            DispatchQueue.main.async {
                self.WSCheckSocialRegister(Parameter: registerDetail)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                GIDSignIn.sharedInstance.signOut()
            }
        }
    }
    
    func AppleSign() {
        appleSignIn.didTapLoginWithApple()
        appleSignIn.appleSignInBlock = { (userInfo, message) in
            if let userInfo = userInfo{
                
                var registerDetail = [String:Any]()
                registerDetail[kName] = userInfo.firstName
                registerDetail[kemail] = userInfo.email
                registerDetail[kUsername] = userInfo.lastName
                registerDetail[kSocialID] = userInfo.userid
                registerDetail[firebaseID] = "TEMPRORY_UID"
                
                registerDetail[kType] = kApple
                registerDetail["is_exist"] = 0
                
                registerDetail[kDeviceID] = UIDevice.current.identifierForVendor?.uuidString ?? ""
                registerDetail[kDeviceType] = kiOS
                registerDetail[kPushToken] = appDelegate.fcmRegTokenMessage
                DispatchQueue.main.async {
                    self.WSCheckSocialRegister(Parameter: registerDetail)
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
    
    func validatePassword(password: String) -> Bool {
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        let lowercaseLetterRegex = ".*[a-z]+.*"
        let digitRegex = ".*\\d.*"
        let specialCharacterRegex = ".*[!\"#$%&'()*+,-./:;<=>?@\\[\\\\\\]^_`{|}~]+.*"
        
        let uppercaseLetterPredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex)
        let lowercaseLetterPredicate = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex)
        let digitPredicate = NSPredicate(format: "SELF MATCHES %@", digitRegex)
        let specialCharacterPredicate = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex)
        
        return password.count >= 6 &&
        uppercaseLetterPredicate.evaluate(with: password) &&
        lowercaseLetterPredicate.evaluate(with: password) &&
        digitPredicate.evaluate(with: password) &&
        specialCharacterPredicate.evaluate(with: password)
        
    }
    
}
