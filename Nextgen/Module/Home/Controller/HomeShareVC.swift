//
//  HomeShareVC.swift
//  Nextgen
//
//  Created by jacky on 14/09/22.
//

import UIKit

class HomeShareVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var txtShare: UITextView!
    @IBOutlet weak var btnBG: UIButton!
    
    //MARK: - VARIABLES
    var postID : String = ""
    var strTitle : String = ""
    var imageURL : String = ""
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseInOut) {
            
            self.btnBG.alpha = 1.0

        } completion: { com in
            
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.3, delay: 0) {
            self.btnBG.alpha = 0.0
        }
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnDismissClicks(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnShareClicks(_ sender: Any) {
        createDynamicLik(postID: postID, strTitle: strTitle, imageURL: imageURL, isCopy: false)
        dismiss(animated: true)
    }
    
    @IBAction func btnCopyClicks(_ sender: Any) {
        createDynamicLik(postID: postID, strTitle: strTitle, imageURL: imageURL, isCopy: true)
        dismiss(animated: true)
    }
}
