//
//  UsersTVC.swift
//  Nextgen
//
//  Created by jacky on 06/09/22.
//

import UIKit

class UsersTVC: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var viewMainBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - GENERAL METHOD
extension UsersTVC {
    
    func bindData(obj : ModelPostsUser) {
        lblUserName.text = obj.name ?? ""
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: obj.profileImage)
    }
    
}
