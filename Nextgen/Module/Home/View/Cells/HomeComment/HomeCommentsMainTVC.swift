//
//  HomeCommentsMainTVC.swift
//  Nextgen
//
//  Created by jacky on 03/09/22.
//

import UIKit

class HomeCommentsMainTVC: UITableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    //MARK: - IBOutlet
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    @IBOutlet weak var viewSubcomments: UIView!
    @IBOutlet weak var tblSubComments: UITableView!
    @IBOutlet weak var constaintTblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblLikesCount: UILabel!
//    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var btnHide: UIButton!
    @IBOutlet weak var likeImg: UIImageView!
    
    @IBOutlet weak var viewButtons: UIView!
    
    //MARK: - VARIABLEs
    var isShowSubComment : Bool = true{
        didSet {
            print("Comment Status:-", isShowSubComment)
            viewSubcomments.isHidden = isShowSubComment
        }
    }

    var likedUnliked : intCloser?
    var arrSubComments : [ModelCommentsMain] = []
    var btnCommentCloser : voidCloser?
    var hideShowCloser : voidCloser?
    var commentID : String = ""
    var totalLikes : Int = 0
    var currentObj : ModelCommentsMain?

    //MARK: - cell methods
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        if modeKey == "DARK"{
            
            mainView.backgroundColor = UIColor.black
        }
        
        tblSubComments.registerCell(type: HomeCommentsMainTVC.self)
        tblSubComments.setDefaultProperties(self)
        
        tblSubComments.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let obj = object as? UITableView {
            if obj == tblSubComments && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    //do stuff here
                    constaintTblHeight.constant = newSize.height
                }
            }
            
        }
    }
    
    //MARK: - button action
    @IBAction func btnHideClicks(_ sender: Any) {
        hideShowCloser?()
    }
    
    @IBAction func btnLikeClicks(_ sender: Any) {
        WSLike()
    }
    
    @IBAction func btnCommentClicks(_ sender: Any) {
        btnCommentCloser?()
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeCommentsMainTVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return true ? arrSubComments.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCommentsMainTVC") as? HomeCommentsMainTVC {
            
            if arrSubComments.count > indexPath.row {
                let obj = arrSubComments[indexPath.row]
                cell.bindData(obj: obj)
                cell.btnHide.isHidden = true
                cell.viewButtons.isHidden = true
            }
                
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}

//MARK: - GENERAL METHOD
extension HomeCommentsMainTVC {
    
    func bindData(obj : ModelCommentsMain) {
        self.currentObj = obj
        
        lblUserName.text = obj.user.name
        GeneralUtility().setImageWithSDWEBImage(imgView: imgUserProfile, placeHolderImage: nil, imgPath: obj.user.profileImage)
        
        lblTime.text = timeAgoSinceDate(getDateFromString(date: obj.createdAt))
        
        lblLikesCount.text = obj.likes.description
//        lblCommentsCount.text = obj.replyCount.description
        
        lblComment.text = obj.comment ?? ""

        arrSubComments = obj.commentsReply
        isShowSubComment = obj.isShowSubComments
        btnHide.isSelected = isShowSubComment
        
        tblSubComments.reloadData()
        layoutIfNeeded()
        
        btnHide.setTitle("Hide".localized, for: .normal)
        btnHide.setTitle("Show more replies".localized, for: .selected)
        
        btnHide.isHidden = (arrSubComments.count == 0)
        self.commentID = obj.id.description
        self.totalLikes = obj.likes ?? 0
        
        
        if obj.liked {
            likeImg.image = UIImage(named: "heart_filled")
        }else {
            likeImg.image = UIImage(named: "likeImg")
        }
    }
    
}

//MARK: - GENERAL METHOD
extension HomeCommentsMainTVC {
    
    func WSLike() {
        
        ServiceManager.shared.getRequest(ApiURL: .commentLike, strAddInURL: self.commentID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            if (self.currentObj?.liked ?? false) {
                self.totalLikes -= 1
                self.likeImg.image = UIImage(named: "ic_like")
            }else {
                self.totalLikes += 1
                self.likeImg.image = UIImage(named: "ic_unliked")
            }
            self.lblLikesCount.text = self.totalLikes.description
            self.likedUnliked?(self.totalLikes)
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }

}
