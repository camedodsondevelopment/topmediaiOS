//
//  VerificationViewController.swift
//  Nextgen
//
//  Created by Zain Anjum on 17/07/2023.
//

import UIKit
import AEOTPTextField
class VerificationViewController: UIViewController {
    @IBOutlet var otpTextField: AEOTPTextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var verifyButton: UIButton!
    @IBOutlet var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otpTextField.otpDelegate = self
        otpTextField.configure(with: 6)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        verifyButton.layer.cornerRadius = 10.0
    }
    @IBAction func loginButtonTapped(_ sender: UIButton) {
            let vc: LoginVC = LoginVC.instantiate(appStoryboard: .main)
            self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
extension VerificationViewController: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        print(code)
    }
}
