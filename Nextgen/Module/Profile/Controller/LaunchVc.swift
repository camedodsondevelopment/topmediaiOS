//
//  LaunchVc.swift
//  Nextgen
//
//  Created by apple on 02/08/2023.
//

import UIKit

class LaunchVc: UIViewController {
    
    @IBOutlet weak var logoImage:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage.isHidden = true
        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        var revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Logo-Black")!, iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: .white)
        if modeKey == "DARK"{
            revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Logo-white")!, iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: .black)
        }
        revealingSplashView.duration = 2
        view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation(){
            print("Completed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let sb = self.storyboard?.instantiateViewController(withIdentifier: "InitialViewController") as! InitialViewController
            sb.modalPresentationStyle = .fullScreen
            self.present(sb, animated: false)
        }
    }
}
