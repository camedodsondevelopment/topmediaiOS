//
//  HelpVC.swift
//  Nextgen
//
//  Created by jacky on 08/09/22.
//

import UIKit

class HelpVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var txtIsuuseType: PaddingTextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    //MARK: - VARIABLES
    var placeholder = "Start Typing ...".localized

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        txtviewCustomization()
    }
    
    
    func txtviewCustomization(){
        txtDescription.text = "Start Typing ...".localized
        txtDescription.textColor = UIColor.lightGray
        txtDescription.delegate = self
    }
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.dismissVC()
    }
    
    @IBAction func btnSelectTypeClick(_ sender: Any) {
        // Strings Picker
        let values = [
            "Bug in the application".localized,
            "Need help in post".localized,
            "How to use post".localized,
            "How to report user ?.localized"
        ]
        DPPickerManager.shared.showPicker(title: "Select issue type".localized, selected: "Need help in post".localized, strings: values.map({$0.localized})) { (selectedValue, index, cancel) in
            if !cancel {
                self.txtIsuuseType.text = selectedValue
            }
        }

    }
    
    @IBAction func btnSendClicks(_ sender: Any) {
        self.view.endEditing(true)

        if validateData() {
            WSHelp()
        }
    }
}


extension HelpVC:UITextViewDelegate{
    //MARK:- TextView Delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = UIColor(named: "#1976D2")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Start Typing ...".localized
            textView.textColor = UIColor.lightGray
            placeholder = ""
        } else {
            placeholder = "  " + textView.text
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder =  "  " + textView.text
    }
}
extension HelpVC {
    
    // TODO: Validation
    func validateData() -> Bool {
        
        guard (txtIsuuseType.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.selectIssueReason)
            return false
        }
        
        guard (txtDescription.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.enterIssueDescription)
            return false
        }
        
        return true
    }
}

//MARK: - WebService Call
extension HelpVC {
    
    //TODO: Login API Call
    func WSHelp() -> Void {
        self.startActivityIndicator()
        let Parameter:[String:Any] = ["type_of_issue" : txtIsuuseType.text! , "description" : txtDescription.text! ]
        ServiceManager.shared.postRequest(ApiURL: .helpRequest, parameters: Parameter) { (response, Success, message, statusCode) in
            
            if Success == true{
                
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: AlertMessage.helpSentSuccess, buttons: ["Okay".localized]) { index in
                    if index == 0 {
//                        self.navigationController?.popViewController(animated: true)
                        self.dismissVC()
                    }
                }
            }
            self.stopActivityIndicator()
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.stopActivityIndicator()
        }
    }
    
}
