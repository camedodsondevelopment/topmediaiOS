//
//  NotificationViewerTVC.swift
//  Nextgen
//
//  Created by jacky on 06/09/22.
//

import UIKit

class NotificationViewerTVC: UITableViewCell {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var viewMainBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnSeeAll: UIButton!
    
    //MARK: - variables
    var seeAllCloser : (() -> Void)?
    var otherUserID : String = ""
    
    //MARK: - cell method
    override func awakeFromNib() {
        super.awakeFromNib()
     
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnSeeAllClicks(_ sender: Any) {
        seeAllCloser?()
    }
    
    @IBAction func btnOtherUserClicks(_ sender: Any) {
        let vc : NewDProfileViewController = NewDProfileViewController.instantiate(appStoryboard: .Profile)
        vc.userID = otherUserID
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - GENERAL METHOD
extension NotificationViewerTVC {
    
    func bindData(obj : ModelNotificationList) {
        otherUserID = obj.fromUserId.description
        lblTime.text = timeAgoSinceDate(getDateFromString(date: obj.createdAt), numericDates: true)
        if obj.fromUser != nil {
            GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: obj.fromUser.profileImage)
        }
        lblNotification.text = obj.pushMessage
        
        btnSeeAll.isHidden = (obj.pushType != 7)
        
        if (obj.pushType == 7) {
            
//            lblNotification.attributedText = setColorForText("Person A, and 8 other people viewed your profile.", "Person A", attributes: [.font : TitilliumSemiBoldS16])
            btnSeeAll.isHidden = false
//            viewMainBG.backgroundColor = .white
//            viewMainBG.clipsToBounds = false
            
        }else {
            
//            lblNotification.attributedText = setColorForText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus risus leo, consectetur adipiscing elit.", "Lorem ipsum", attributes: [.font : TitilliumSemiBoldS16])
            btnSeeAll.isHidden = true
//            viewMainBG.backgroundColor = hexStringToUIColor(hex: "#FAFAFA")
//            viewMainBG.clipsToBounds = true
        }
//        viewMainBG.backgroundColor = .clear
    }
    
}
