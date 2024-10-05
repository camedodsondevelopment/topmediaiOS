//
//  OtherUserProfileVC.swift
//  Nextgen
//
//  Created by jacky on 14/09/22.
//

import UIKit
import BetterSegmentedControl
import PopMenu
import SwiftyJSON
import AVFoundation


class OtherUserProfileVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var scrollMain: UIScrollView!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    
    @IBOutlet weak var msgAndFollowView: UIStackView!
    
    @IBOutlet weak var heightAnchor: NSLayoutConstraint!
    @IBOutlet weak var segmentProfile: BetterSegmentedControl!
    
    @IBOutlet weak var tblPost: UITableView!
    @IBOutlet weak var constraintTblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnFollow: UIButton!
    
    //MARK: - VARIABLES
    var arrOptions : [String] = ["Report User".localized]
    var currentUserProfile : ModelOtherUserProfile?
    var audioPlayer: AVAudioPlayer?

    var arrPosts : [ModelPostsMain] = [] {
        didSet {
            if arrPosts.count == 0 {
                tblPost.setEmptyMessage("No data found!".localized)
            }else {
                tblPost.restore()
            }
            
            self.offset = 0
            self.tblPost.reloadData()
        }
    }
    var isDataLoading:Bool=false
    var limit : Int = 100
    var offset : Int = 0
    var hasMoreData : Bool = false
    
    var userID : String = ""
    var isBlocked : Bool = false
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        if userID == "" {
            self.userID = NextgenUser.shared.id
        }
        
        getProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        followersBtn.setTitle("Followers".localized, for: .normal)
        followingBtn.setTitle("Following".localized, for: .normal)
        
        tblPost.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        getProfile()
        
        if GlobalService.instance.hideMsgView {
            msgAndFollowView.isHidden = true
            heightAnchor.constant = 0
        }else {
            msgAndFollowView.isHidden = false
            heightAnchor.constant = 40
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tblPost.removeObserver(self, forKeyPath: "contentSize")
        stopPlaying()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let obj = object as? UITableView {
            if obj == tblPost && keyPath == "contentSize" {
                if let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize {
                    //do stuff here
                    constraintTblHeight.constant = newSize.height
                }
            }
            
        }
    }
    
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        self.dismissVC()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnSettingClicks(_ sender: Any) {
        let vc = SettingVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
        
    }
    
    @IBAction func btnFollowClicks(_ sender: Any) {
        self.WSFollowUser()
    }
    
    
    @IBAction func btneditClicks(_ sender: Any) {
        if self.userID == NextgenUser.shared.id {
            let vc = EditProfileVC.instantiate(appStoryboard: .Profile)
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
    }
    
   
    
    @IBAction func btnFollowersClicks(_ sender: Any) {
        let vc: FollowingFollowerListVC = FollowingFollowerListVC.instantiate(appStoryboard: .Profile)
        vc.currentUserProfile = self.currentUserProfile
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFollowingClicks(_ sender: Any) {
        let vc: FollowingFollowerListVC = FollowingFollowerListVC.instantiate(appStoryboard: .Profile)
        vc.currentUserProfile = self.currentUserProfile
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnSendMessageClicks(_ sender: Any) {
        
        let vc : ChatDetailsVC = ChatDetailsVC.instantiate(appStoryboard: .Chat)
        vc.chatVM.otherUserID = self.currentUserProfile?.id.description ?? ""
        vc.otherUserObj = self.currentUserProfile
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true )
    }
    
    @IBAction func segmentTypeChanged(_ sender: Any) {
        self.arrPosts.removeAll()
        self.WSPostsList()
    }
    
    @IBAction func playAndPauseBtn(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            audioPlayer?.pause()
        }else{
            audioPlayer?.play()
        }
    }
    
    func stopPlaying(){
        audioPlayer?.stop()
    }
}

//MARK: - GENERAL FUNCTIONS
extension  OtherUserProfileVC {
    
    func setSegment() {
        
        let fontSelected = TitilliumRegularS16
        let fontUnSelected = TitilliumRegularS16
        
        let defaultColor = UIColor.clear
        let selectedBGColor = #colorLiteral(red: 0.9333333333, green: 0.737254902, blue: 0.2862745098, alpha: 1)
        
        segmentProfile.segments = LabelSegment.segments(withTitles: ["Posts".localized , "Likes & Replies".localized , "Media".localized], numberOfLines: 1, normalBackgroundColor: defaultColor, normalFont: fontUnSelected, normalTextColor: selectedBGColor, selectedBackgroundColor: selectedBGColor, selectedFont: fontSelected, selectedTextColor: .white)
    }
    
    func setUI() {
        navigationController?.navigationBar.isHidden = true
        tblPost.registerCell(type: HomeMediaTVC.self)
        tblPost.registerCell(type: LoadingTVC.self)
        tblPost.setDefaultProperties(self)
        
        setSegment()
    }
}

//MARK: - popmenu
extension  OtherUserProfileVC : PopMenuViewControllerDelegate {
    
    func showOptionsOf(sender : UIView) {
        
        let arrays : [PopMenuAction] = arrOptions.map({PopMenuDefaultAction(title: $0.localized)})
        //PopMenuDefaultAction(title: "Action Title 1")
        
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
            switch self.arrOptions[index] {
                
            case "Report User".localized :
                let vc : ReportUserVC = ReportUserVC.instantiate(appStoryboard: .Profile)
                vc.userID = self.userID
                vc.modalPresentationStyle = .overFullScreen
                UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
                
                
            case "Block User".localized  , "Unblock User".localized :
                self.WSBlockUser()
                
            case "Log out".localized :
                appDelegate.setLoginScreen()
                
            default :
                break
            }
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension OtherUserProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hasMoreData {
            return 2
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return arrPosts.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if arrPosts.count > indexPath.row {
                
                let obj = arrPosts[indexPath.row]
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMediaTVC") as? HomeMediaTVC {
                    cell.bindData(obj: obj)
                    
                    if obj.user?.id.description == NextgenUser.shared.id {
                        cell.arrOptions = ["Delete".localized]
                    }else {
                        cell.arrOptions = ["Report".localized]
                    }
                    
                    cell.btnFollow.isHidden = true
                    
                    cell.likedUnliked = { total , isliked in
                        self.arrPosts[indexPath.row].like = total
                        self.arrPosts[indexPath.row].isLiked = isliked
                        
                        self.reloadTable()
                    }
                    cell.hideCloser = {
                        self.arrPosts.remove(at: indexPath.row)
                        
                        self.reloadTable()
                    }
                    
                    cell.deleteCloser = {
                        self.arrPosts.remove(at: indexPath.row)
                        
                        self.reloadTable()
                    }
                    cell.followCloser = { isFollow in
                        self.arrPosts[indexPath.row].isFollowing = isFollow ? 1 : 0
                    }
                    
                    return cell
                }
            }
            
        }else {
            
            if let cell  = tableView.dequeueReusableCell(withIdentifier: "LoadingTVC", for: indexPath) as? LoadingTVC {
                cell.startLoading()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? HomeMediaTVC {
            cell.btnComment.sendActions(for: .touchUpInside)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        cellAnimation(cell: cell, indexPath: indexPath)
    }
    
    func reloadTable() {
        tblPost.beginUpdates()
        tblPost.reloadSections(IndexSet(integer: 0), with: .none)
        tblPost.endUpdates()
    }
}

//MARK: - GENERAL METHOD
extension OtherUserProfileVC {
    
    func bindData() {
        guard let user = self.currentUserProfile else { return }
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: user.profileImage)
        GeneralUtility().setImageWithSDWEBImage(imgView: imgPoster, placeHolderImage: UIImage(named: "edit"), imgPath: user.backgroundImage)
        lblName.text = user.name
        
        lblFollowersCount.text = user.followersCount.description
        lblFollowingCount.text = user.followingCount.description
        
        lblBio.text = user.about
        
        btnFollow.setTitle("Follow".localized, for: .normal)
        btnFollow.setTitle("Unfollow".localized, for: .selected)
        
        btnFollow.isSelected = (user.isFollowing != 0)
        scrollMain.isHidden = false
        
        isBlocked = user.isBlocked ?? false
        arrOptions = ["Report User".localized]
        
        if isBlocked {
            arrOptions.append("Block User".localized)
        }else {
            arrOptions.append("Unblock User".localized)
        }
        
        if let url = URL(string: user.audio_file){
            playMusic(url: url)
        }else{
            guard let path = Bundle.main.path(forResource: "memries", ofType:"mp3") else {
                return }
            let url = URL(fileURLWithPath: path)
            playMusic(url: url)
        }
    }
    
}

//MARK: - Pagination
extension OtherUserProfileVC {
    //Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 350 {
            if !isDataLoading {
                isDataLoading = true
                
                if self.hasMoreData {
                    self.WSPostsList(isShowLoader: false)
                }
            }
        }
    }
    
}

//MARK: - WEBService CAll
extension OtherUserProfileVC {
    
    //to get search results
    func WSPostsList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "user_id" : self.userID,
            "limit" : self.limit,
            "offset" : self.offset,
        ]
        
        var url : ApiURL = .none
        
        switch self.segmentProfile.index {
        case 0 :
            url = .postLists
        case 1 :
            url = .profileLiked
        case 2 :
            url = .profileMedia
        default :
            url = .profilePost
        }
        arrPosts.removeAll()
        ServiceManager.shared.postRequest(ApiURL: url, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            if Success == true{
                
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                self.arrPosts.removeAll()
                
                arr.forEach { (obj) in
                    
                    if self.segmentProfile.index == 1 {
                        self.arrPosts.append(ModelPostsMain(fromJson: obj["post"]))
                    }else {
                        let singleObj = ModelPostsMain(fromJson: obj)
                        singleObj.user = ModelPostsUser(fromJson: JSON(self.currentUserProfile?.toDictionary() ?? [:]))
                        self.arrPosts.append(singleObj)
                    }
                    
                }
                
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                self.tblPost.reloadData()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.isDataLoading = false
            self.hasMoreData = false
            self.tblPost.reloadData()
        }
    }
    
    func getFollowersList() {
        print("id from userID\(self.userID)")
        print("id from shared\(NextgenUser.shared.id)")
        scrollMain.isHidden = true
        ServiceManager.shared.getRequest(ApiURL: .getFollowersList, strAddInURL: self.userID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    
    func getProfile() {
        if NextgenUser.shared.id == "" {
            return
        }
        print("id from userID\(self.userID)")
        print("id from shared\(NextgenUser.shared.id)")
        scrollMain.isHidden = true
        ServiceManager.shared.getRequest(ApiURL: .getOtherUserProfile, strAddInURL: self.userID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            self.currentUserProfile = ModelOtherUserProfile(fromJson: response["data"])
            self.WSPostsList()
            self.bindData()
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    func WSFollowUser() {
        
        ServiceManager.shared.getRequest(ApiURL: .followUser, strAddInURL: userID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            print(response)
            self.btnFollow.isSelected = !self.btnFollow.isSelected
            self.getProfile()
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    func WSBlockUser() {
        
        var url : ApiURL = .blockUser
        if isBlocked {
            url = .unblockUser
        }
        
        ServiceManager.shared.getRequest(ApiURL: url, strAddInURL: userID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            self.navigationController?.popViewController(animated: true)
            
        } Failure: { response, isSuccess, error, statusCode in}
    }
}

extension OtherUserProfileVC: UIDocumentPickerDelegate {
    func playMusic(url: URL) {
        if let player = audioPlayer, player.isPlaying {
            audioPlayer?.stop()
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
