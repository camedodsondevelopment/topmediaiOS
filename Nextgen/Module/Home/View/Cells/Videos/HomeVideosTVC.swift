//
//  HomeVideosTVC.swift
//  Ashh
//
//  Created by M1 Mac mini 4 on 09/06/22.
//

import UIKit
import AVKit
import Firebase
import FirebaseDynamicLinks
import GSPlayer

class HomeVideosTVC: UITableViewCell {

    //MARK: - IBOutlet
    @IBOutlet weak var playerView: VideoPlayerView!
    
    @IBOutlet weak var imgThumb: UIImageView!

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikesCount: UILabel!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userSubTitle:UILabel!

    @IBOutlet weak var lblCommentsCount: UILabel!
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var imgDoubleTapLike: UIImageView!
    @IBOutlet weak var btnPlayPause: UIButton!{
        didSet {
            btnPlayPause.alpha = 0.02
            btnPlayPause.setImage(UIImage(named: "ic_play_video"), for: .normal)
            btnPlayPause.setImage(UIImage(named: "ic_pause_video"), for: .selected)
        }
    }
    
    
    private var url: URL!
    
    //MARK: - VARIABLES
    var isLiked : Bool = false {
        didSet {
            if isLiked {
                imgLike.image = UIImage(named: "big_heart_filled")
            } else {
                imgLike.image = UIImage(named: "big_heart_empty")
            }
        }
    }
    var rateObserver: NSKeyValueObservation?
    var currentCellIndex : Int = 0

    var currentVideoObj : ModelVideoListMain?
    var postObj : ModelVideoListMain?
    var likedUnliked : ((Int,Bool) -> Void)?
    var hideCloser : voidCloser?
    var deleteCloser : voidCloser?
    var followCloser : boolCloser?

    //MARK: - cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGR.delegate = self
        tapGR.numberOfTapsRequired = 2
        playerView.addGestureRecognizer(tapGR)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 
    //MARK: - Button action
    func handleDoubleTap() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .allowUserInteraction, animations: {
            self.imgDoubleTapLike.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            self.imgLike.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
            self.imgDoubleTapLike.alpha = 1.0
        }) { finished in
            self.imgDoubleTapLike.alpha = 0.0
            self.imgDoubleTapLike.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.imgLike.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        print("doubletapped")
    }

    @IBAction func btnProfileClicks(_ sender: UIButton) {
        let userID = postObj?.user?.id.description ?? ""
        let topVC = UIApplication.topViewController()
        if NextgenUser.shared.id == userID {
            if topVC is ProfileVC {
                return
            }else {
                topVC?.tabBarController?.selectedIndex = 4
            }
            
        }else {
            if let topVC2 = topVC as? NewDProfileViewController , topVC2.userID == userID {
                return
            }else {
                let vc : NewDProfileViewController = NewDProfileViewController.instantiate(appStoryboard: .Profile)
                vc.userID = userID
                topVC?.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    
    
    @IBAction func btnLikeClicks(_ sender: UIButton) {
        WSLike()
    }
    
    @IBAction func btnCommentsClicks(_ sender: UIButton) {
        let vc : PostDetailsVC = PostDetailsVC.instantiate(appStoryboard: .Home)

        vc.postID = self.postObj?.id?.description ?? ""
        UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnShareClicks(_ sender: UIButton) {
        
        let vc : HomeShareVC = HomeShareVC.instantiate(appStoryboard: .Home)
        vc.postID = postObj?.id.description ?? ""
        vc.strTitle = postObj?.descriptionField ?? ""
        vc.imageURL = postObj?.thumbImage ?? ""
        vc.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()!.present(vc, animated: true)

    }
    
    @IBAction func btnPlayPauseClicks(_ sender: UIButton) {
        print("btnPlayPauseClicks")
        btnPlayPause.alpha = 1.0
        sender.isSelected = !sender.isSelected
        
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut) {
            self.btnPlayPause.alpha = 0.02
        } completion: { isCompleted in
            print("isCompleted")
        }
        
        playerView.state == .playing ? playerView.pause(reason: .userInteraction) : playerView.resume()
    }

    
    @IBAction func btnExpandCollapseClicks(_ sender: Any) {
        if lblDescription.numberOfLines == 2 {
            lblDescription.numberOfLines = 0
        }else {
            lblDescription.numberOfLines = 2
        }
        self.layoutSubviews()
    }
}

//MARK: - GENERAL FUNCTION
extension HomeVideosTVC {
    
    func bindData(obj : ModelVideoListMain) {
        postObj = obj
        
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: obj.user.profileImage)
        
        lblLikesCount.text = obj.like.description
        
        if obj.isLiked {
            imgLike.image = UIImage(named: "big_heart_filled")
        } else {
            imgLike.image = UIImage(named: "big_heart_empty")
        }
        
        userName.text = obj.user.name
        userSubTitle.text = obj.user.username
        
        lblCommentsCount.text = obj.commentsListCount.description
        lblDescription.text = obj.descriptionField

    }
   
    func setLoginScreen() {
        appDelegate.setLoginScreen()

    }
    
    func set(url: URL) {
        self.url = url
        self.playerView.contentMode = .scaleAspectFill
    }
    
    func play() {
        playerView.play(for: url)
        playerView.isHidden = false
    }
    
    func pause() {
        playerView.pause(reason: .hidden)
    }
}

//MARK: - GENERAL METHOD
extension HomeVideosTVC {
    
    func WSLike() {
        
        ServiceManager.shared.getRequest(ApiURL: .likePost, strAddInURL: postObj?.id.description ?? "", parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            let totalLikes = response["data"]["like"].intValue
            let isLiked = response["data"]["liked"].boolValue

            if isLiked {
                self.imgLike.image = UIImage(named: "big_heart_filled")
            } else {
                self.imgLike.image = UIImage(named: "big_heart_empty")
            }
            
            self.lblLikesCount.text = totalLikes.description
            self.likedUnliked?(totalLikes, isLiked)
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
}
