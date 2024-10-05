//
//  AddCryptoWalletVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit

class AddCryptoWalletVC: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var lblsubtitle: UILabel!
    
    @IBOutlet weak var txtCryptoAddress: UITextField!
    @IBOutlet weak var btnTermsConditions: UIButton!{
        didSet {
            btnTermsConditions.setImage(UIImage(named: "ic_checkbox_unselected"), for: .normal)
            btnTermsConditions.setImage(UIImage(named: "ic_checkbox"), for: .selected)
        }
    }
    // MARK: - VARIABLES
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblsubtitle.setLineHeight(lineHeight: 1.2)
    }
    
    // MARK: - Other Functions
    
    // MARK: - Button Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()

        if txtCryptoAddress.text!.isEmpty {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: "Please entere crypto address".localized)
            return
        }

        wsUpdateCrypto()
    }
    
    @IBAction func btnTermsConditionsClicks(_ sender: Any) {
        
        let vc = CommonWebViewVC.instantiate(appStoryboard: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnTermsClicks(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
    }
    
}

//MARK: - GENERAL METHOD
extension AddCryptoWalletVC {
    
    func wsUpdateCrypto()  {

        ServiceManager.shared.postRequest(ApiURL: .upadteCryptoAddress, parameters: ["crypto_address" : txtCryptoAddress.text!]) { response, isSuccess, error, statusCode in
            
            if isSuccess == true{
                
                NextgenUser.shared.setData(dict: response["data"])
                appDelegate.setHomeRoot()
            }

        } Failure: { response, isSuccess, error, statusCode in
            //response
        }
    }
    
}
