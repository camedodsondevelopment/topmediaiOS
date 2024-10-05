//
//  CommentsTableViewCell.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 27/09/2024.
//

import UIKit
import SDWebImage

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var comment:UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(object:Comment){
        userName.text = "\(object.userName): "
        comment.text = object.commentText
        GeneralUtility().setImageWithSDWEBImage(imgView: img, placeHolderImage: AvatarImage, imgPath: object.userImg)
    }
}
