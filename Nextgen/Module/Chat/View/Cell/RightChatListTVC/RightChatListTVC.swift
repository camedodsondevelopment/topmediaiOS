//
//  RightChatListTVC.swift

import UIKit

class RightChatListTVC: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgTick: UIImageView!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var vwRight: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DispatchQueue.main.async {
            self.vwRight.layer.cornerRadius = 16.0
            self.vwRight.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
