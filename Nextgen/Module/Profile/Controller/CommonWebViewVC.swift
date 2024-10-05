//
//  CommonWebViewVC.swift
//  TheOry
//
//  Created by M1 Mac Mini 2 on 21/12/22.
//

import UIKit
import WebKit

enum WebviewFor {
    case termsConditions
    case privacyPolicy
}

class CommonWebViewVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var vwProgress: UIProgressView!
    @IBOutlet weak var lblTitle: UILabel!
    
    // MARK: - VARIABLES
    
    var mytitle = ""
    var isFor : WebviewFor = .termsConditions
    var strPDFURL : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView.isOpaque = false
            self.webView.uiDelegate = self
            self.webView.navigationDelegate = self

            var strURL : String = ""
            switch self.isFor {
            case .termsConditions :
                strURL = ApiURL.termsConditions.strURL()
            case .privacyPolicy :
                strURL = ApiURL.privacyPolicy.strURL()
            }
            
            self.webView.load(NSURLRequest(url: URL(string: strURL)!) as URLRequest)
            self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
    }
    
    // MARK: - Other Functions
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(self.webView.estimatedProgress)
            
            if Float(self.webView.estimatedProgress) > 0.5 {
                self.vwProgress.setProgress(Float(self.webView.estimatedProgress), animated: true)
            }
            
            if self.webView.estimatedProgress == 1.0 {
                self.vwProgress.isHidden = true
            } else {
                self.vwProgress.isHidden = false
            }
        }
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        dismissVC()
    }
    
}

// MARK: - Webview Methods

extension CommonWebViewVC: WKNavigationDelegate, WKUIDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish loading")
        let textSize = 250
        let javascript = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '\(textSize)%'"
        
        webView.evaluateJavaScript(javascript) { (response, error) in
            
        }
    }
}
