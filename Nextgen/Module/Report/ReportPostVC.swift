//
//  ReportPostVC.swift
//  Nextgen
//
//  Created by Jacky Patel on 12/10/22.
//

import UIKit

class ReportPostVC: UIViewController  {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var txtIsuuseType: PaddingTextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    //MARK: - VARIABLES
    var postID : String = ""
    var placeholder = "Start Typing ...".localized

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtviewCustomization()
    }
    
    
    func txtviewCustomization(){

        txtDescription.text = "Start Typing ...".localized
        txtDescription.textColor = UIColor.lightGray
        txtDescription.delegate=self

    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        dismissVC()
    }
    
    @IBAction func btnSelectTypeClick(_ sender: Any) {
        // Strings Picker
        let values = [
            "Spam".localized,
        "Nudity or sexual activity".localized,
        "Hate speech or symbols".localized,
        "Violence or dangerous organisations".localized,
        "Bullying or harassment".localized,
        "Selling illegal or regulated goods".localized,
        "Intellectual property violations".localized,
        "Suicide or self-injury".localized,
        "Eating disorders".localized,
        "Scams or fraud".localized,
        "False information".localized,
        ]
        
        DPPickerManager.shared.showPicker(title: "Select report reason type".localized, selected: "Spam".localized, strings: values.map({$0.localized})) { (selectedValue, index, cancel) in
            if !cancel {
                self.txtIsuuseType.text = selectedValue?.localized
            }
        }

    }
    
    @IBAction func btnSendClicks(_ sender: Any) {
        self.view.endEditing(true)
        GeneralUtility().addButtonTapHaptic()

        if validateData() {
            WSReport()
        }
    }
}

extension ReportPostVC {
    
    // TODO: Validation
    func validateData() -> Bool {
        
        guard (txtIsuuseType.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: "Please select report reason".localized)
            return false
        }
        
        guard (txtDescription.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: "Please enter report description".localized)
            return false
        }
        
        return true
    }
}


extension ReportPostVC:UITextViewDelegate{
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
//MARK: - WebService Call
extension ReportPostVC {
    
    //TODO: Login API Call
    func WSReport() -> Void {
        
        let Parameter:[String:Any] = ["id" : postID , "reason" : txtIsuuseType.text! , "description" : txtDescription.text! ]
        ServiceManager.shared.postRequest(ApiURL: .postReport, parameters: Parameter) { (response, Success, message, statusCode) in
            
            if Success == true{
                
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: message, buttons: ["Okay".localized]) { index in
                    if index == 0 {
                        self.dismissVC()
                    }
                }
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
    }
    
}
