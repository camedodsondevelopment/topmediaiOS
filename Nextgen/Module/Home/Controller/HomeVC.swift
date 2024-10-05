//
//  HomeVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import Firebase
import FirebaseDynamicLinks
import SwiftyJSON
import SDWebImage

class SearchCell: UITableViewCell{
    @IBOutlet weak var personImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var selectedImg:UIImageView!

}

class HomeVC: UIViewController,UITextFieldDelegate {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tblHome: UITableView!
    
    @IBOutlet weak var searchTblView: UITableView!
    @IBOutlet weak var modeSwitchBtn:UIButton!
    
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var searchTblHeight_constraint:NSLayoutConstraint!
    @IBOutlet weak var closeSearchTFB:UIButton!
    
    
    //MARK: - VARIABLES
    var isDataLoading:Bool=false
    var limit : Int = 30
    var userID: Int = 0
    var indexP:IndexPath?
    var oneTimeRun = true
    
    var offset : Int {
        return arrPosts.count
    }
    var hasMoreData : Bool = false
    
    var arrPosts : [ModelPostsMain] = [] {
        didSet {
            self.tblHome.reloadData()
        }
    }
    
    var arrUsers : [ModelPostsUser] = []
    let refreshControl = UIRefreshControl()
    
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTblView.isHidden = true
        
        searchTf.delegate = self
        searchTblView.delegate = self
        searchTblView.dataSource = self
        
        tblHome.registerCell(type: HomeMediaTVC.self)
        tblHome.registerCell(type: LoadingTVC.self)
        
        tblHome.setDefaultProperties(self)
        tblHome.separatorColor  = .none
        refreshControl.tintColor = #colorLiteral(red: 0.9333333333, green: 0.737254902, blue: 0.2862745098, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...".localized)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tblHome.addSubview(refreshControl) // not required when using UITableViewController
        navigationController?.navigationBar.isHidden = true
        
        modeSwitchBtn.isSelected = UserDefaults.standard.string(forKey: "MODE_KEY") == "DARK" ? true : false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchView.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        searchTblView.isHidden = true
        searchTf.text = ""
        if AppShare.shared.isRefreshPosts {
            arrPosts.removeAll()
            WSPostsList()
        }else{
            AppShare.shared.isRefreshPosts = true
        }
        
        if channelName.count > 1 && oneTimeRun{
            
            oneTimeRun = false
            
            let joinerType = isABroadcaster == true ? "broadcaster" : "audience"
            let parameter : [String : Any] =
            [
                "channel_name" : channelName,
                "uid" : NextgenUser.shared.id,
                "type" : joinerType
            ]
            
            ServiceManager.shared.postRequest(ApiURL: .getAgoraToken, parameters: parameter, Success: { (response, Success, message, statusCode) in
                
                let responseDcit = response.dictionaryValue
                if let token = responseDcit["data"]?.stringValue, token.count > 0 {
                    let vc = BecomeLiveViewController.instantiate(appStoryboard: .Home) as! BecomeLiveViewController
                    vc.modalPresentationStyle = .fullScreen
                    vc.agoraSDKToken = token
                    vc.joinerType = joinerType
                    self.present(vc, animated: true)
                }else{
                    CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: responseDcit["message"]?.stringValue ?? "")
                }
               
                
            }, Failure: { (response, Success, message, statusCode) in
                print("Failure Response:",response)
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count ?? 0 > 0 {
            searchUser(searchText: textField.text!)
        }else{
            searchTblView.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText != "" {
                closeSearchTFB.isHidden = false
                searchUser(searchText: updatedText)
            }else{
                closeSearchTFB.isHidden = true
                searchTblView.isHidden = true
            }
        }else{
            closeSearchTFB.isHidden = true
            searchTblView.isHidden = true
        }
        
        return true
    }
    
    @IBAction func closeSearchTFBtn(_ sender:UIButton){
        searchTf.text = ""
        searchTblView.isHidden = true
        arrUsers.removeAll()
        closeSearchTFB.isHidden = true
    }
    
    @IBAction func modeSwitchChangedBtn(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            
            if btn.isSelected {
                appDelegate?.overrideUserInterfaceStyle = .dark
                UserDefaults.standard.set("DARK", forKey: "MODE_KEY")
            }else {
                appDelegate?.overrideUserInterfaceStyle = .light
                UserDefaults.standard.set("LIGHT", forKey: "MODE_KEY")
            }
            UserDefaults.standard.set(btn.isSelected, forKey: "Mode")
            NotificationCenter.default.post(name: Notification.Name("HandleDarkMode"), object: nil)
        }
    }
    
    
    
    @IBAction func notificationBtnTapped(_ sender: Any) {
        let vc = NotificationsVC.instantiate(appStoryboard: .Notifications)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func refresh(_ sender: AnyObject) {
        arrPosts.removeAll()
        WSPostsList(isShowLoader: false)
    }
    
    //MARK: - BUTTON ACTION
    @IBAction func btnSwitchVideoClicks(_ sender: Any) {
        GeneralUtility().addButtonTapHaptic()
        
        let vc : VideoDetailsVC = VideoDetailsVC.instantiate(appStoryboard: .Home)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnHandlerChangeLanguage(_ sender: Any) {
        let values = [
            "English",
            "Spanish",
            "French",
            "Chinese",
            "Hindi",
            "German",
        ]
        let selectedValue = UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "English"
        DPPickerManager.shared.showPicker(title: "Select language".localized, selected: selectedValue, strings: values.map({$0.localized})) { (selectedValue, index, cancel) in
            if !cancel {
                UserDefaults.standard.set(values[index], forKey: "SelectedLanguage")
                switch values[index] {
                case "English":
                    appDelegate.Applanguage = "en"
                case "Spanish":
                    appDelegate.Applanguage = "es"
                case "French":
                    appDelegate.Applanguage = "fr"
                case "Chinese":
                    appDelegate.Applanguage = "zh-Hans"
                case "Hindi":
                    appDelegate.Applanguage = "hi"
                case "German":
                    appDelegate.Applanguage = "de"
                default :
                    break
                }
                appDelegate.setHomeRoot()
            }
        }
    }
    
    @objc func setIndexPath(indexPath:IndexPath){
        indexP = indexPath
    }
    
    func followUnfollowSet(uid:Int, isFollow:Bool){
        var posts = arrPosts
        for index in 0..<posts.count {
            let post = posts[index]
            if post.userId == uid {
                post.isFollowing = isFollow ? 1 : 0
                posts[index] = post
            }
        }
        arrPosts = posts
        tblHome.reloadData()
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hasMoreData {
            return 2
        }else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tblHome{
            if section == 0 {
                return arrPosts.count
            }else {
                return 1
            }
        }else if tableView == searchTblView{
            if arrUsers.count > 0 {
                searchTblView.restore()
            }else{
                searchTblView.setEmptyMessage("No Users found!".localized)
            }
            return arrUsers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == searchTblView{
            let data = arrUsers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
            GeneralUtility().setImageWithSDWEBImage(imgView: cell.personImg, placeHolderImage: AvatarImage, imgPath: data.profileImage)
            cell.titleLbl.text = "\(data.name) \(data.username ?? "")"
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.section == 0 {
            
            if arrPosts.count > indexPath.row {
                
                let obj = arrPosts[indexPath.row]
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMediaTVC") as? HomeMediaTVC {
                    cell.bindData(obj: obj)
                    
                    cell.commitBtnCloser = {
                        self.setIndexPath(indexPath: indexPath)
                    }
                    
                    cell.likedUnliked = { total , isliked in
                        self.arrPosts[indexPath.row].like = total
                        self.arrPosts[indexPath.row].isLiked = isliked
                        
                        tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .none)
                        tableView.endUpdates()
                    }
                    cell.hideCloser = {
                        self.arrPosts.remove(at: indexPath.row)
                        
                        tableView.beginUpdates()
                        tableView.reloadSections(IndexSet(integer: 0), with: .none)
                        tableView.endUpdates()
                    }
                    
                    cell.followCloser = { isFollow in
                        self.followUnfollowSet(uid: self.arrPosts[indexPath.row].userId, isFollow: isFollow)
                    }
                    
                    cell.deleteCloser = {
                        self.arrPosts.remove(at: indexPath.row)
                        
                        tableView.beginUpdates()
                        tableView.reloadSections(IndexSet(integer: 0), with: .none)
                        tableView.endUpdates()
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
        if tableView == tblHome {
            let object = arrPosts[indexPath.row]
            let vc : PostDetailsVC = PostDetailsVC.instantiate(appStoryboard: .Home)
            vc.postObj = object
            vc.postID = object.id.description
            indexP = indexPath
            navigationController?.pushViewController(vc, animated: true)
        }else{
            if indexPath.section == 0 {
                if let _ = tableView.cellForRow(at: indexPath) as? SearchCell {
                    let vc : NewDProfileViewController = NewDProfileViewController.instantiate(appStoryboard: .Profile)
                    vc.userID =  "\(arrUsers[indexPath.row].id ?? 0)"
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}


//MARK: - Pagination
extension HomeVC {
    //Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tblHome {
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
    
}

//MARK: - WEBService CAll
extension HomeVC {
    
    //to get search results
    func WSPostsList(isShowLoader : Bool = true) {
        
        if isShowLoader {
            startActivityIndicator()
        }
        
        let parameter : [String : Any] =
        [
            "limit" : self.limit,
            "offset" : self.offset,
        ]
        
        isDataLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
            self.isDataLoading = false
            self.stopActivityIndicator()
        })
        ServiceManager.shared.postRequest(ApiURL: .getHomeList, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            self.refreshControl.endRefreshing()
            self.isDataLoading = false
            self.stopActivityIndicator()
            
            if self.offset == 0 {
                self.arrPosts.removeAll()
            }
            
            if Success == true{
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                arr.forEach { (obj) in
                    self.arrPosts.append(ModelPostsMain(fromJson: obj))
                }
                self.hasMoreData = !(arr.count < self.limit)
                self.tblHome.reloadData()
                if let indexPath = self.indexP {
                    self.tblHome.scrollToRow(at: indexPath, at: .top, animated: false)
                    self.indexP = nil
                }
                
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.refreshControl.endRefreshing()
            self.isDataLoading = false
            self.hasMoreData = false
            self.tblHome.reloadData()
            self.stopActivityIndicator()
        }
    }
    
    func searchUser(searchText: String)  {
        let Parameter:[String:Any] = ["limit" : "100" , "offser" : "0" , "search" : searchText]
        
        ServiceManager.shared.postRequest(ApiURL: .searchUser, parameters: Parameter) { response, isSuccess, error, statusCode in
            
            if isSuccess == true{
                self.arrUsers.removeAll()
                if self.searchTf.text!.isEmpty {
                    self.searchTblView.isHidden = true
                    return
                }
                
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    self.arrUsers.append(ModelPostsUser(fromJson: obj))
                }
                // self.offset = self.arrUsers.count
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if self.arrUsers.count == 1 {
                        self.searchTblHeight_constraint.constant = 80
                    }else if self.arrUsers.count == 2 {
                        self.searchTblHeight_constraint.constant = 160
                    }else if self.arrUsers.count == 3 {
                        self.searchTblHeight_constraint.constant = 320
                    }else{
                        self.searchTblHeight_constraint.constant = 400
                    }
                    
                    self.searchTblView.isHidden = false
                    self.searchTblView.reloadData()
                }
            }else{
                self.arrUsers.removeAll()
                self.searchTblView.isHidden = true
            }
            
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
        
    }
    
}

//MARK: - GENERAL METHOD

func editPostClicked(model:ModelPostsMain?) {
    //Edit Post Clicked
    AppShare.shared.singlePost = model
    let fvc = UIApplication.topViewController()
    fvc?.tabBarController?.selectedIndex = 2
}

func createDynamicLik(postID : String, strTitle : String = "" , imageURL : String = "", isCopy : Bool = true)  {
    
    guard let link = URL(string: "https://dodson-development.com?post_id=\(postID)") else { return }
    
    SHOW_CUSTOM_LOADER()
    let dynamicLinksDomainURIPrefix = "https://nextgen.page.link"
    if let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix) {
        
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.Project.NextgenApp")
        linkBuilder.iOSParameters?.fallbackURL = URL(string: "www.google.com")
        linkBuilder.iOSParameters?.appStoreID = "6443882866"
        
        linkBuilder.androidParameters = DynamicLinkAndroidParameters(packageName: "com.NextgenApp")
        linkBuilder.androidParameters?.fallbackURL = URL(string: "com.Project.NextgenApp")
        
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        
        linkBuilder.socialMetaTagParameters!.title = strTitle
        linkBuilder.socialMetaTagParameters!.imageURL = URL(string: imageURL)
        
        linkBuilder.navigationInfoParameters?.isForcedRedirectEnabled = true
        linkBuilder.shorten() { url, warnings, error in
            guard let url = url, error == nil else {
                HIDE_CUSTOM_LOADER()
                return
            }
            print("The short URL is: \(url)")
            
            if isCopy {
                UIPasteboard.general.url = url
                HIDE_CUSTOM_LOADER()
                
            }else {
                let activityViewController = UIActivityViewController(activityItems: [url as Any] as [Any], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = UIApplication.topViewController()!.view
                
                UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true) {
                    HIDE_CUSTOM_LOADER()
                }
            }
        }
    }else {
        HIDE_CUSTOM_LOADER()
    }
}
