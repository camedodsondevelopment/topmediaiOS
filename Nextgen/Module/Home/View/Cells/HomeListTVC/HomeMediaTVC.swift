//
//  HomeMediaTVC.swift
//  Nextgen
//
//  Created by jacky on 14/09/22.
//

import UIKit
import PopMenu
import AVKit
import Lightbox


class HomeMediaTVC: UITableViewCell {

    //MARK: - IBOutlet
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var tblComments: UITableView!
    
    @IBOutlet weak var constraintTblHeights: NSLayoutConstraint!
    
    @IBOutlet weak var likeCounter: UILabel!
    @IBOutlet weak var commentCounter: UILabel!
    @IBOutlet weak var btnComment:UIButton!
    @IBOutlet weak var likeImg:UIImageView!
    
    @IBOutlet weak var collectionMedia: UICollectionView!
    @IBOutlet weak var viewMedia: UIView!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - VARIABLE
    var arrOptions : [String] = ["Hide this post".localized , "Copy Link".localized, "Report".localized]
    var arrOptions2 : [String] = [ "Copy Link".localized, "Edit Post".localized, "Delete".localized]
    var arrURLS : [String] = []
    var postObj : ModelPostsMain?
    var likedUnliked : ((Int,Bool) -> Void)?
    var hideCloser : voidCloser?
    var deleteCloser : voidCloser?
    var followCloser : boolCloser?
    var commitBtnCloser:voidCloser?
    var id = 0
    var arrays:[PopMenuAction]=[]
    let imageViewss = UIImageView()
    
    var arraySelected = 1
    //MARK: - cell methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tblComments.registerCell(type: HomeCommentsMainTVC.self)
        tblComments.setDefaultProperties(self)
        tblComments.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        tblComments.separatorColor = .clear
        collectionMedia.registerCell(type: PostMediaCVC.self)
        collectionMedia.setDefaultProperties(vc: self)
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //height observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let obj = object as? UITableView {
            if obj == tblComments && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    //do stuff here
                    constraintTblHeights.constant = newSize.height
                    layoutIfNeeded()
                }
            }
        }
    }

    
    //MARK: - button action
    @IBAction func btnFollowClicks(_ sender: Any) {
        WSFollowUser()
    }
    
    @IBAction func btnMoreClicks(_ sender: UIButton) {
        showOptionsOf(sender: sender)
    }
    
    @IBAction func btnLikeClicks(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            likeImg.image = UIImage(named: "heart_filled")
        }else{
            likeImg.image = UIImage(named: "likeImg")
            if let likeCount = postObj?.like, likeCount > 0 {
                likeCounter.text = "\((postObj?.like ?? 0)-1)"
            }
        }
        WSLike()
    }
    
    @IBAction func btnCommentClicks(_ sender: UIButton) {
        if !(UIApplication.topViewController() is PostDetailsVC) {
            commitBtnCloser?()
            let vc : PostDetailsVC = PostDetailsVC.instantiate(appStoryboard: .Home)
            vc.postObj = self.postObj
            vc.postID = self.postObj?.id.description ?? ""
            UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnShareClicks(_ sender: Any) {
        let vc : HomeShareVC = HomeShareVC.instantiate(appStoryboard: .Home)
        vc.postID = postObj?.id.description ?? ""
        vc.strTitle = postObj?.descriptionField ?? ""
        vc.imageURL = postObj?.file.first ?? ""
        vc.modalPresentationStyle = .overFullScreen
        UIApplication.topViewController()!.present(vc, animated: true)
    }
    
    @IBAction func btnProfileClicks(_ sender: Any) {
        
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
                vc.modalPresentationStyle = .fullScreen
                topVC?.present(vc, animated: true )
            }
        }
    }
}

//MARK: - popmenu
extension  HomeMediaTVC : PopMenuViewControllerDelegate {
    
    func showOptionsOf(sender : UIView) {
        print("\(id)")
        print(NextgenUser.shared.id)
        
        if "\(id)" == NextgenUser.shared.id {
            arraySelected=2
            arrays = arrOptions2.map({PopMenuDefaultAction(title: $0.localized)})
        }else{
            arraySelected=1
            arrays = arrOptions.map({PopMenuDefaultAction(title: $0.localized)})
        }
        
        let controller = PopMenuViewController(sourceView: sender, actions: arrays)
        
        // Customize appearance
        controller.contentView.backgroundColor = .AppColor
        controller.appearance.popMenuFont = TitilliumRegularS16
        
        controller.appearance.popMenuColor.actionColor = .tint(.white)
        controller.appearance.popMenuBackgroundStyle = .dimmed(color: .white, opacity: 0.5)
        controller.appearance.popMenuColor.backgroundColor = PopMenuActionBackgroundColor.solid(fill: .AppColor)
        controller.appearance.popMenuCornerRadius = 14
        // Configure options
        controller.shouldDismissOnSelection = false
        controller.delegate = self
        
        controller.didDismiss = { selected in
            print("Menu dismissed: \(selected ? "selected item" : "no selection")")
        }
        
        // Present menu controller
        
        UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
        
    }
    
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        print("index tapped", index)
        popMenuViewController.dismiss(animated: true) {
            //options
            if self.arraySelected == 1{
                switch self.arrOptions[index]  {
                    
                case "Hide this post" :
                    self.WSHidePost()
                    break
                case "Copy Link" :
                    createDynamicLik(postID: self.postObj?.id.description ?? "", strTitle: (self.postObj?.descriptionField ?? "") , imageURL: (self.postObj?.file.first ?? ""))
                    break
                case "Report" :
                    let vc : ReportPostVC = ReportPostVC.instantiate(appStoryboard: .Profile)
                    vc.postID = self.postObj?.id.description ?? ""
                    vc.modalPresentationStyle = .fullScreen
                    UIApplication.topViewController()!.present(vc, animated: true)
                    break
                default :
                    break
                }
            }else{
                switch self.arrOptions2[index]  {
                    
                case "Copy Link" :
                    createDynamicLik(postID: self.postObj?.id.description ?? "", strTitle: (self.postObj?.descriptionField ?? "") , imageURL: (self.postObj?.file.first ?? ""))
                    break
                case "Edit Post" :
                    //Rizwan needs to open the edit post screen here.
                    editPostClicked(model: self.postObj)
                    break
                case "Delete" :
                    CommonClass().showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, title: Constant.APP_NAME, andMessage: "Are you sure want to delete this post?".localized, buttons: ["Yes".localized , "No".localized]) { index in
                        
                        if index == 0 {
                            self.WSDeletePost()
                        }
                    }
                default :
                    break
                }
            }
        }
    }
}

//MARK: - GENERAL METHOD
extension HomeMediaTVC {
    
    func bindData(obj : ModelPostsMain) {
        postObj = obj
        id = obj.userId
        lblUserName.text = obj.user?.name ?? ""
        GeneralUtility().setImageWithSDWEBImage(imgView: imgUserProfile, placeHolderImage: AvatarImage, imgPath: obj.user?.profileImage ?? "")
        lblTime.text = timeAgoSinceDate(getDateFromString(date: obj.createdAt))
        likeCounter.text = "\(obj.like.description)"
        likeCounter.textColor = .lightGray
        commentCounter.text = "\(obj.comments.description)"
        commentCounter.textColor = .lightGray
        btnFollow.isHidden = (obj.user?.id?.description == NextgenUser.shared.id)
        btnFollow.setTitle("+ FOLLOW".localized, for: .normal)
        btnFollow.setTitle("UNFOLLOW".localized, for: .selected)
        btnFollow.isSelected = obj.isFollowing == 1
        lblDescription.isHidden = true
        if obj.descriptionField == "" {
            lblDescription.isHidden = true
        }else {
            lblDescription.text = obj.descriptionField
            lblDescription.isHidden = false
        }
        
        if obj.isLiked{
            likeImg.image = UIImage(named: "heart_filled")
        }else{
            likeImg.image = UIImage(named: "likeImg")
        }
        
        viewMedia.isHidden = obj.file.isEmpty
        arrURLS = obj.file
        collectionMedia.reloadData()
        if obj.file.count > 1 {
            pageControl.isHidden = false
            pageControl.numberOfPages = obj.file.count
        }else{
            pageControl.isHidden = true
        }
    }
    
}

//MARK: - GENERAL METHOD
extension HomeMediaTVC : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrURLS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostMediaCVC", for: indexPath) as! PostMediaCVC
        
        let obj = arrURLS[indexPath.row]

        let filteredArr = arrURLS.filter({$0.localizedCaseInsensitiveContains(".mp4")})
        
        if obj.localizedCaseInsensitiveContains(".mp4") {
            cell.imgPlay.isHidden = false
            if let firstIn = filteredArr.firstIndex(of: obj), (postObj?.thumbImages.count ?? 0) > firstIn {
                GeneralUtility().setImageWithSDWEBImage(imgView: cell.imgPost, placeHolderImage: placeholderImage, imgPath: (postObj?.thumbImages[firstIn] ?? ""))
            }
        }else {
            cell.imgPlay.isHidden = true
            GeneralUtility().setImageWithSDWEBImage(imgView: cell.imgPost, placeHolderImage: placeholderImage, imgPath: arrURLS[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (ScreenSize.WIDTH - 10)
        let height = width * 9 / 16
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let obj = arrURLS[indexPath.row]
        AppShare.shared.isRefreshPosts = false
        if obj.localizedCaseInsensitiveContains(".mp4") {
            self.playVideo(strURl: obj)
        }else {
            let images = [
              LightboxImage(imageURL: URL(string: obj)!)
            ]
            let controller = LightboxController(images: images)
            controller.dynamicBackground = true
            UIApplication.shared.topViewController()?.present(controller, animated: false, completion: {})
        }
    }
}

//MARK: - GENERAL METHOD
extension HomeMediaTVC {
    
    func WSLike() {
        ServiceManager.shared.getRequest(ApiURL: .likePost, strAddInURL: postObj?.id.description ?? "", parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            let totalLikes = response["data"]["like"].intValue
            let isLiked = response["data"]["liked"].boolValue
            self.likedUnliked?(totalLikes, isLiked)
            
        } Failure: { response, isSuccess, error, statusCode in
            
        }
    }
    
    func WSFollowUser() {
        ServiceManager.shared.getRequest(ApiURL: .followUser, strAddInURL: postObj?.user?.id?.description ?? "", parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            self.btnFollow.isSelected = !self.btnFollow.isSelected
            self.followCloser?(self.btnFollow.isSelected)
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    func WSHidePost() {
        ServiceManager.shared.postRequest(ApiURL: .postHide, parameters: ["id" : (postObj?.id.description ?? "")]) { response, isSuccess, error, statusCode in
            self.hideCloser?()
        } Failure: { response, isSuccess, error, statusCode in
            
        }
    }
    
    func WSDeletePost() {
        ServiceManager.shared.getRequest(ApiURL: .postDelete, strAddInURL: postObj?.id.description ?? "", parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            self.deleteCloser?()
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
}


//MARK: - GENERAL METHOD
extension HomeMediaTVC {
    
    func playVideo(strURl : String){
        if let url = URL(string: strURl) {
            let player = AVPlayer(url: url)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            UIApplication.shared.topViewController()?.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }

}

extension HomeMediaTVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = scrollView.currentPage
    }
}



