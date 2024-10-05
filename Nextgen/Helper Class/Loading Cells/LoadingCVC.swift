//
//  LoadingCVC.swift
//  Broker's Adda
//
//  Created by Zestbrains on 22/07/21.
//

import UIKit

class LoadingCVC: UICollectionViewCell {

    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loader.startAnimating()
    }

    func startLoading() {
        loader.startAnimating()
    }
    
    func stopLoading() {
        loader.stopAnimating()
    }
}
