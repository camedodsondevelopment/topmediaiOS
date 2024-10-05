//
//  LaunchVc.swift
//  Nextgen
//
//  Created by apple on 02/08/2023.
//

import UIKit

class LaunchDashboardVC: UIViewController {

    @IBOutlet weak var logoImage:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImage.isHidden = true
        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        var revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Logo-white")!, iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: .white)
        if modeKey == "DARK"{
            revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "Logo-Black")!, iconInitialSize: CGSize(width: 200, height: 200), backgroundColor: .black)
        }
        revealingSplashView.duration = 2
        view.addSubview(revealingSplashView)
        revealingSplashView.startAnimation(){
            print("Completed")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            let vc = TabHome()
            let win = UIApplication.shared.windows.first
            let nav: UINavigationController = UINavigationController(rootViewController: vc)

            if(win != nil){
                UIView.transition(with: win!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    nav.isNavigationBarHidden = true
                    win!.rootViewController = nav
                    win!.makeKeyAndVisible()
                    
                }, completion: { completed in
                    
                })
            }
        })
    }
}
