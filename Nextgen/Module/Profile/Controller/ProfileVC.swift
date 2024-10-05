//
//  ProfileVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import BetterSegmentedControl
import PopMenu
import SwiftyJSON

class ProfileVC: UIViewController {
    
    //MARK: - IBOUTLETS
    
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    
    @IBOutlet weak var lblRewardPoints: UILabel!
    
    @IBOutlet weak var viewFollowerDetails: UIView!
    @IBOutlet weak var progressFollowers: UIProgressView!
    @IBOutlet weak var progressLikes: UIProgressView!
    @IBOutlet weak var progressComments: UIProgressView!
    
    
    @IBOutlet weak var lblWalletInfo: UILabel!
    @IBOutlet weak var segmentProfile: BetterSegmentedControl!
    
    @IBOutlet weak var btnShowRewardPoint: UIButton!
    @IBOutlet weak var tblPost: UITableView!
    @IBOutlet weak var constraintTblHeight: NSLayoutConstraint!
    
    @IBOutlet var lblGamificationTitle: [UILabel]!
    @IBOutlet var progressGamifiaction: [UIProgressView]!
    @IBOutlet var lblGamificationValues: [UILabel]!
    
    
    //MARK: - VARIABLES
    let arrOptions : [String] = ["Change Mode".localized,"Help".localized, "Log out".localized]
    
    var arrPosts : [ModelPostsMain] = [] {
        didSet {
            if arrPosts.count == 0 {
                tblPost.setEmptyMessage("No data found!".localized)
            }else {
                tblPost.restore()
            }
            
            self.offset = arrPosts.count
            self.tblPost.reloadData()
        }
    }
    var isDataLoading:Bool=false
    var limit : Int = 10
    var offset : Int = 0
    var hasMoreData : Bool = false
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tblPost.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        bindData()
        
        self.getProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tblPost.removeObserver(self, forKeyPath: "contentSize")
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
    @IBAction func btnMoreClicks(_ sender: UIButton) {
        self.showOptionsOf(sender: sender)
    }
    
    @IBAction func btnFollowersClicks(_ sender: Any) {
        let vc : FollowingFollowerListVC = FollowingFollowerListVC.instantiate(appStoryboard: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFollowingClicks(_ sender: Any) {
        let vc : FollowingFollowerListVC = FollowingFollowerListVC.instantiate(appStoryboard: .Profile)
        vc.isShowFollowingFirst = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnEditProfileClicks(_ sender: Any) {
        let vc : EditProfileVC = EditProfileVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func segmentTypeChanged(_ sender: Any) {
        self.arrPosts.removeAll()
        
        self.WSPostsList()
    }
}

//MARK: - GENERAL FUNCTIONS
extension  ProfileVC {
    
    func setSegment() {
        
        let fontSelected = TitilliumRegularS16
        let fontUnSelected = TitilliumRegularS16
        
        let defaultColor = UIColor.clear
        let selectedBGColor = #colorLiteral(red: 0.9333333333, green: 0.737254902, blue: 0.2862745098, alpha: 1)
        
        segmentProfile.segments = LabelSegment.segments(withTitles: ["My Posts".localized , "Likes & Replies".localized , "Media".localized], numberOfLines: 1, normalBackgroundColor: defaultColor, normalFont: fontUnSelected, normalTextColor: selectedBGColor, selectedBackgroundColor: selectedBGColor, selectedFont: fontSelected, selectedTextColor: .white)
    }
    
    private func setUI() {
        tblPost.registerCell(type: HomeMediaTVC.self)
        tblPost.registerCell(type: LoadingTVC.self)
        tblPost.setDefaultProperties(self)
        setSegment()
    }
}

//MARK: - popmenu
extension  ProfileVC : PopMenuViewControllerDelegate {
    
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
                
            case "Help" :
                let vc : HelpVC = HelpVC.instantiate(appStoryboard: .Profile)
                self.navigationController?.pushViewController(vc, animated: true)
                
            case "Log out" :
                
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: "Are you sure want to logout?".localized, buttons: ["Yes".localized, "No".localized]) { index in
                    if index == 0 {
                        
                        ServiceManager.shared.getRequest(ApiURL: .logout, parameters: [:]) { response, isSuccess, error, statusCode in
                            appDelegate.setLoginScreen()
                        } Failure: { response, isSuccess, error, statusCode in
                            //failure
                        }
                    }
                }
                
            case "Change Mode":
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                   let window = appDelegate.window {
                    let currentMode = window.overrideUserInterfaceStyle
                    if currentMode == .light {
                        window.overrideUserInterfaceStyle = .dark
                        UserDefaults.standard.set("dark", forKey: "mode")
                        GeneralUtility.sharedInstance.setStatusBar(view: self.view, mode: "light")
                        //                            UIApplication.shared.statusBarStyle = .lightContent
                        
                    } else if currentMode == .dark {
                        window.overrideUserInterfaceStyle = .light
                        UserDefaults.standard.set("light", forKey: "mode")
                        GeneralUtility.sharedInstance.setStatusBar(view: self.view, mode: "default")
                        //                            UIApplication.shared.statusBarStyle = .default
                        
                        print("Current mode is dark.")
                    } else if #available(iOS 13.0, *), currentMode == .unspecified {
                        if window.traitCollection.userInterfaceStyle == .light {
                            window.overrideUserInterfaceStyle = .dark
                            UserDefaults.standard.set("dark", forKey: "mode")
                            GeneralUtility.sharedInstance.setStatusBar(view: self.view, mode: "default")
                            //                                UIApplication.shared.statusBarStyle = .default
                            
                        } else if window.traitCollection.userInterfaceStyle == .dark {
                            GeneralUtility.sharedInstance.setStatusBar(view: self.view, mode: "light")
                            window.overrideUserInterfaceStyle = .light
                            UserDefaults.standard.set("light", forKey: "mode")
                            
                        } else {
                            print("Unknown or unspecified mode.")
                        }
                    } else {
                        print("Unknown or unspecified mode.")
                    }
                }
            default :
                break
            }
            
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    
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
                        cell.arrOptions = ["Copy Link"]
                    }else {
                        cell.arrOptions = ["Report"]
                    }
                    
                    cell.btnFollow.isHidden = true
                    
                    cell.likedUnliked = { total , isliked in
                        self.arrPosts[indexPath.row].like = total
                        self.arrPosts[indexPath.row].isLiked = isliked
                        
                        self.reloadTable()
                        
                        tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .fade)
                        tableView.endUpdates()
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
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellAnimation(cell: cell, indexPath: indexPath)
//    }
    
    func reloadTable() {
        tblPost.beginUpdates()
        tblPost.reloadSections(IndexSet(integer: 0), with: .fade)
        tblPost.endUpdates()
    }
}

//MARK: - GENERAL METHOD
extension ProfileVC {
    
    func bindData() {
        let user = NextgenUser.shared
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: user.profileImage)
        
        GeneralUtility().setImageWithSDWEBImage(imgView: imgPoster, placeHolderImage: nil, imgPath: user.backgroundImage)
        
        lblName.text = user.name
        lblUserName.text = "@" + user.username
        
        lblFollowersCount.text = user.followersCount
        lblFollowingCount.text = user.followingCount
        
        lblBio.text = user.about
    }
    
}

//MARK: - Pagination
extension ProfileVC {
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
extension ProfileVC {
    
    func getProfile() {
        
        //scrollMain.isHidden = true
        ServiceManager.shared.getRequest(ApiURL: .GetProfile, strAddInURL: "", parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            NextgenUser.shared.setData(dict: response["data"])
            //self.currentUserProfile = ModelOtherUserProfile(fromJson: response["data"])
            self.WSPostsList()
            self.bindData()
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    //to get search results
    func WSPostsList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "user_id" : NextgenUser.shared.id,
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
        
        ServiceManager.shared.postRequest(ApiURL: url, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            if self.offset == 0 {
                self.arrPosts.removeAll()
            }
            
            if Success == true{
                
                let dataObj = response["data"]
                
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    
                    if self.segmentProfile.index == 1 {
                        self.arrPosts.append(ModelPostsMain(fromJson: obj["post"]))
                        
                    }else {
                        let singleObj = ModelPostsMain(fromJson: obj)
                        singleObj.user = ModelPostsUser(fromJson: JSON(["id" : NextgenUser.shared.id, "name" : NextgenUser.shared.name, "profile_image" : NextgenUser.shared.profileImage]))
                        self.arrPosts.append(singleObj)
                    }
                    
                }
                
                self.offset = self.arrPosts.count
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
    
}


extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
