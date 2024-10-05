//
//  TabHome.swift
//  Nextgen
//
//  Created by iobits Technologies on 04/08/2023.
//

import UIKit

class TabHome: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MANGO")
        DispatchQueue.main.async {
            let SbData = UIStoryboard(name: "Tabbar", bundle: Bundle.main)
            let SB = SbData.instantiateViewController(withIdentifier: "CustomTabBarController") as! CustomTabBarController
            SB.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(SB, animated: true)
        }
    }
}
