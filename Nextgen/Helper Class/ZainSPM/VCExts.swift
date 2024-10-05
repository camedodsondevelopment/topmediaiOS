//
//  VCExts.swift
//  ZainFramework
//
//  Created by ZainAnjum on 06/05/2019.
//

import UIKit

public extension UIViewController{
    
    static func instantiate() -> UIViewController{
        let id = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: id)
        
    }
    
    func pushVC(_ VC: UIViewController) {
        navigationController?.pushViewController(VC, animated: true)
    }
    
    func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var activityIndicatorTag: Int { return 999999 }
    
    func startActivityIndicator(
        style: UIActivityIndicatorView.Style = UIActivityIndicatorView.Style.medium,
        location: CGPoint? = nil) {
        
        let loc = location ?? self.view.center

        DispatchQueue.main.async {
            let activityIndicator = UIActivityIndicatorView(style: style)
            //Add the tag so we can find the view in order to remove it later
            activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)

            activityIndicator.tag = self.activityIndicatorTag
            
            let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
            if modeKey == "DARK"{
                activityIndicator.color = .white
            }else{
                activityIndicator.color = .black
            }
            
            activityIndicator.center = loc
            activityIndicator.hidesWhenStopped = true
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
        }
    }
    
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            if let activityIndicator = self.view.subviews.filter(
                { $0.tag == self.activityIndicatorTag}).first as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    func showAlert(text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            default:
                break
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoadingAlert(text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        if #available(iOS 13.0, *) {
            alert.view.tintColor = UIColor.label
        } else {
            alert.view.tintColor = UIColor.black
        }
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        if #available(iOS 13.0, *) {
            loadingIndicator.color = .label
        } else {
            loadingIndicator.color = .black
        }
        alert.view.addSubview(loadingIndicator)
        if let window = UIApplication.shared.windows.first{
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
