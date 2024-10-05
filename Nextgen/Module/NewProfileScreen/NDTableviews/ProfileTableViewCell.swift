//
//  ProfileTableViewCell.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 24/08/2024.
//

import UIKit


protocol ProfileButtonsDelegate {
    func followBtnClicked()
    func sendMsgBtnClicked()
}

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage:UIImageView!
    @IBOutlet weak var profilePic:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var descriptionLbl:UILabel!
    @IBOutlet weak var followBtn:UIButton!
    @IBOutlet weak var sendMsgBtn:UIButton!

    var delegate:ProfileButtonsDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func followBtnTabbed(_ sender: UIButton){
        delegate?.followBtnClicked()
    }
    
    @IBAction func sendMsgBtnTabbed(_ sender: UIButton){
        delegate?.sendMsgBtnClicked()
    }
    
}
