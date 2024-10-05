//
//  ForgotPasswordVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    // MARK: - OUTLETS
    //    @IBOutlet weak var lblsubtitle: UILabel!
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet var sendCodeButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    // MARK: - VARIABLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sendCodeButton.layer.cornerRadius = 10.0
    }
        
    // MARK: - Button Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let vc: LoginVC = LoginVC.instantiate(appStoryboard: .main)
        vc.modalTransitionStyle = .flipHorizontal
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendCodeTapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        if validateData() {
            let dict : [String : Any] = [kemail : txtEmail.text!]
            WSForgotPassword(Parameter: dict)
        }
    }
}

extension ForgotPasswordVC {
    
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
        
        return true
    }
}

//MARK: - WebService Call
extension ForgotPasswordVC {
    
    func WSForgotPassword(Parameter:[String:Any]) -> Void {
        self.startActivityIndicator()
        ServiceManager.shared.postRequest(ApiURL: .forgotPassword, parameters: Parameter) { (response, Success, message, statusCode) in
            
            CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: message, buttons: ["Okay".localized]) { index in
                let vc: VerificationViewController = VerificationViewController.instantiate(appStoryboard: .main)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            self.stopActivityIndicator()
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.stopActivityIndicator()
        }
    }
    
}
