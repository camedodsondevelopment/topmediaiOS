//
//  FollowingFollowerTVC.swift
//  Nextgen
//
//  Created by jacky on 08/09/22.
//

import UIKit

class FollowingFollowerTVC: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var viewMainBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var btnRemoveUnfollow: UIButton!
    
    var btnRemoveUnfollowCloser : voidCloser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - btn action
    @IBAction func btnRemoveClicks(_ sender: Any) {
        btnRemoveUnfollowCloser?()
    }
}

//MARK: - GENERAL METHOD
extension FollowingFollowerTVC {
    
    func bindData(obj : ModelPostsUser) {
        lblUserName.text = obj.name 
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: obj.profileImage)
    }
    
}
