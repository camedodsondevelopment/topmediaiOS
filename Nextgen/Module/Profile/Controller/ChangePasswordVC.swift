//
//  ChangePasswordVC.swift
//  Nextgen
//
//  Created by jacky on 14/09/22.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmNewPassword: UITextField!
    
    @IBOutlet var textFields: [UITextField]!
    //MARK: - VARIABLES
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismissVC()
    }
    @IBAction func btnCancelClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismissVC()
       
    }
    
    @IBAction func btnChangePasswordClicks(_ sender: Any) {
        
        self.view.endEditing(true)
        GeneralUtility().addButtonTapHaptic()
        
        if validateData() {
            self.WSChangePassword()
        }
    }
    
    @IBAction func btnEyeClicks(_ sender: UIButton) {
        textFields[sender.tag].isSecureTextEntry = !textFields[sender.tag].isSecureTextEntry
    }
    
}

extension ChangePasswordVC {
    
    func validateData() -> Bool {
        guard (txtCurrentPassword.text?.removeWhiteSpace().count)! > 0 else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.currentPasswordMissing)
            return false
        }

        
        guard (txtNewPassword.text?.removeWhiteSpace().count)! > 0 else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.NewpasswordMissing)
            return false
        }

        guard (txtNewPassword.text?.removeWhiteSpace().count)! >= 6 else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.NewPasswordMinMissing)
            return false
        }

        guard (txtConfirmNewPassword.text?.removeWhiteSpace().count)! > 0 else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.ConfirmPasswordMissing)
            return false
        }

        if txtNewPassword.text != txtConfirmNewPassword.text {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.PasswordNotMatch)
            return false
        }
        
        if  validatePassword(password:txtNewPassword.text ?? "" ) == false{
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: ("Password must have at least one uppercase letter, one lowercase letter, one digit, and one special character"))
            return false
        }
        

        return true

    }
}
extension ChangePasswordVC {
 
    func WSChangePassword() {
        self.startActivityIndicator()
        let param : [String : Any] = ["current_password" : txtCurrentPassword.text ?? "", "new_password" : txtNewPassword.text ?? "", "confirm_password" : txtConfirmNewPassword.text ?? ""]
        
        ServiceManager.shared.postRequest(ApiURL: .changePassword, parameters: param) { (response, Success, message, statusCode) in
            
            if Success == true{
                
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: message, buttons: ["Okay".localized]) { index in
                    
                    self.navigationController?.popViewController(animated: true)
                    self.stopActivityIndicator()
                    self.dismiss(animated: true)
                }
                
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.stopActivityIndicator()
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
        
print(password)
        print(uppercaseLetterPredicate.evaluate(with: password))
        print( lowercaseLetterPredicate.evaluate(with: password))
        print(digitPredicate.evaluate(with: password))
        print(specialCharacterPredicate.evaluate(with: password))

        return password.count >= 6 &&
        uppercaseLetterPredicate.evaluate(with: password) &&
        lowercaseLetterPredicate.evaluate(with: password) &&
        digitPredicate.evaluate(with: password) &&
        specialCharacterPredicate.evaluate(with: password)

    }
}
