//
//  ReportUserVC.swift
//  Nextgen
//
//  Created by Jacky Patel on 17/10/22.
//

import UIKit

class ReportUserVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var txtIsuuseType: PaddingTextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    //MARK: - VARIABLES
    var userID : String = ""

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSelectTypeClick(_ sender: Any) {
        // Strings Picker
        let values = [
            "Harassment or bullying.".localized,
            "Sales or promotion of drugs.".localized,
            "Violence or threat of violence.".localized,
            "Nudity or pornography.".localized,
            "Hate speech or symbols.".localized,
            "Self injury.".localized,
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

extension ReportUserVC {
    
    // TODO: Validation
    func validateData() -> Bool {
        
        guard (txtIsuuseType.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.selectReportReason)
            return false
        }
        
        guard (txtDescription.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.enterReportDescription)
            return false
        }
        
        return true
    }
}

//MARK: - WebService Call
extension ReportUserVC {
    
    //TODO: Login API Call
    func WSReport() -> Void {
        
        let Parameter:[String:Any] = ["id" : userID , "reason" : txtIsuuseType.text! , "description" : txtDescription.text! ]
        ServiceManager.shared.postRequest(ApiURL: .reportUser, parameters: Parameter) { (response, Success, message, statusCode) in
            
            if Success == true{
                
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: message, buttons: ["Okay".localized]) { index in
                    if index == 0 {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
    }
    
}
