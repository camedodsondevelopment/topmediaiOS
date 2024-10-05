//
//  FollowersFollowingTableViewCell.swift
//  Nextgen
//
//  Created by Zain Anjum on 22/07/2023.
//

import UIKit

class FollowersFollowingTableViewCell: UITableViewCell {
    @IBOutlet var personUsername: UILabel!
    @IBOutlet var personRemove: UILabel!
    @IBOutlet var personImg: UIImageView!
//    @IBOutlet var personUnfollow: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
