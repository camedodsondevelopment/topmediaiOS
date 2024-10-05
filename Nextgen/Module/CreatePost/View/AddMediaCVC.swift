//
//  AddMediaCVC.swift
//  Nextgen
//
//  Created by Jacky Patel on 11/10/22.
//

import UIKit

class AddMediaCVC: UICollectionViewCell {

    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!    
    
    @IBOutlet weak var viewAddMedia: UIView!
    
    var deleteCloser : voidCloser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btnDeleteClicks(_ sender: Any) {
        deleteCloser?()
    }
}
