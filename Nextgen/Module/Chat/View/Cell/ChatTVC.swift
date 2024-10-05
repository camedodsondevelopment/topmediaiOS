//
//  ChatTVC.swift
//  Nextgen
//
//  Created by jacky on 06/09/22.
//

import UIKit

class ChatTVC: UITableViewCell {

    //MARK: -
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    //MARK: - cell method
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
