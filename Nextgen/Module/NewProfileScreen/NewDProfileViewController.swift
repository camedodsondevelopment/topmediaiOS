//
//  NewDProfileViewController.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 29/01/2024.
//

import UIKit
import AVFoundation
import PopMenu
import SwiftyJSON

class NewDProfileViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var btnFollow:UIButton!
    @IBOutlet weak var sendMsgBtn:UIButton!
    @IBOutlet weak var editBtn:UIButton!
    @IBOutlet weak var profileImg:UIImageView!
    @IBOutlet weak var profileBGImg:UIImageView!
    @IBOutlet weak var titleName:UILabel!
    @IBOutlet weak var detailLbl:UILabel!
    @IBOutlet weak var noDataFound:UILabel!
    @IBOutlet weak var liveBtn:UIButton!

    
    var arrOptions : [String] = ["Report User".localized]
    var currentUserProfile : ModelOtherUserProfile?
    var audioPlayer: AVAudioPlayer?

    var arrPosts : [ModelPostsMain] = [] {
        didSet {
            if arrPosts.count == 1 {
                noDataFound.isHidden = false
            }else {
                noDataFound.isHidden = true
            }
            
            self.offset = 0
            self.tableview.reloadData()
        }
    }
    var isDataLoading:Bool=false
    var limit : Int = 100
    var offset : Int = 0
    var hasMoreData : Bool = false
    
    var userID : String = ""
    var isBlocked : Bool = false
    var selectedSegmentIndex:Int = 0
    var destinationUrl:URL? = nil
    var isFromChat = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        liveBtn.isHidden = true
        
        if userID == "" {
            editBtn.isHidden = false
            btnFollow.isHidden = true
            sendMsgBtn.isHidden = true
        }else{
            editBtn.isHidden = true
            btnFollow.isHidden = false
            sendMsgBtn.isHidden = false
        }
        
        if AppShare.shared.isRefreshProfile {
            getProfile()
        }
        
        getUserLiveStatus()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        audioPlayer?.stop()
    }

    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        if isFromChat {
            navigationController?.popViewController(animated: true)
        }else{
            tabBarController?.selectedIndex = 0
            dismissVC()
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnSettingClicks(_ sender: Any) {
        let vc = SettingVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    @IBAction func btnFollowClicks(_ sender: Any) {
        self.WSFollowUser()
    }
    
    
    @IBAction func btneditClicks(_ sender: Any) {
        let vc = EditProfileVC.instantiate(appStoryboard: .Profile)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func btnSendMessageClicks(_ sender: Any) {
        let vc : ChatDetailsVC = ChatDetailsVC.instantiate(appStoryboard: .Chat)
        vc.chatVM.otherUserID = self.currentUserProfile?.id.description ?? ""
        vc.otherUserObj = self.currentUserProfile
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true )
    }
    
    @IBAction func joinAsAudience(_ sender: UIButton){
        
        let parameter : [String : Any] =
        [
            "channel_name" : channelName,
            "uid" : NextgenUser.shared.id,
            "type" : "audience"
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .getAgoraToken, parameters: parameter, Success: { (response, Success, message, statusCode) in
            
            let responseDcit = response.dictionaryValue
            if let token = responseDcit["data"]?.stringValue, token.count > 0 {
                let vc = BecomeLiveViewController.instantiate(appStoryboard: .Home) as! BecomeLiveViewController
                vc.modalPresentationStyle = .fullScreen
                vc.agoraSDKToken = token
                vc.joinerType = "audience"
                self.present(vc, animated: true)
            }else{
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: responseDcit["message"]?.stringValue ?? "")
            }
            
        }, Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        })
    }
    
    @IBAction func playAndPauseBtn(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            audioPlayer?.pause()
        }else{
            audioPlayer?.play()
        }
    }
    
    func setUI() {
        navigationController?.navigationBar.isHidden = true
        tableview.registerCell(type: HomeMediaTVC.self)
        tableview.registerCell(type: NPTableViewCell.self)
        tableview.setDefaultProperties(self)
    }
    
    func segmentTypeChanged(indexAt:Int) {
        selectedSegmentIndex = indexAt
        WSPostsList()
    }
    
    func clickActions(actionType:String){
        
        switch actionType {
            
        case "Followers":
            let vc: FollowingFollowerListVC = FollowingFollowerListVC.instantiate(appStoryboard: .Profile)
            vc.currentUserProfile = currentUserProfile
            vc.userID = userID
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case "Followings":
            let vc: FollowingFollowerListVC = FollowingFollowerListVC.instantiate(appStoryboard: .Profile)
            vc.isShowFollowingFirst = true
            vc.currentUserProfile = currentUserProfile
            vc.userID = userID
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case "Pause Music":
            GlobalService.instance.isPausedMusic = false
            audioPlayer?.play()
            break
        case "Posts":
            changeSegmentAt(index: 0)
            break
        case "Likes":
            changeSegmentAt(index: 1)
            break
        case "Media":
            changeSegmentAt(index: 2)
            break
        case "Play Music":
            GlobalService.instance.isPausedMusic = true
            audioPlayer?.pause()
            break
        default:
            print("Nothing")
        }
    }
    
    func changeSegmentAt(index:Int){
        selectedSegmentIndex = index
        WSPostsList()
    }
    
    func getUserLiveStatus(){
        
        let parameter : [String : Any] =
        [
            "user_id" : userID,
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .getUserLiveStatus, parameters: parameter, Success: { (response, Success, message, statusCode) in
            
            let responseDcit = response.dictionaryValue
            if let dict = responseDcit["data"]?.dictionaryValue {
                channelName = dict["channel_name"]?.stringValue ?? ""

                if let isLive = dict["live_status"]?.boolValue, isLive {
                    self.liveBtn.isHidden = false
                }else{
                    self.liveBtn.isHidden = true
                }
            }else{
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: responseDcit["message"]?.stringValue ?? "")
            }
           
            
        }, Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        })
    }
}


extension NewDProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = arrPosts[indexPath.row]
        
        if obj.id == 0 || obj.user == nil{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "NPTableViewCell") as? NPTableViewCell, let user = currentUserProfile {
                cell.bindValues(followers: user.followersCount.description, following: user.followingCount.description, selectedSegment: selectedSegmentIndex, isMusicPlaying: audioPlayer?.isPlaying ?? true)
                cell.closur = { action in
                    self.clickActions(actionType: action)
                }
                return cell
            }
        }else{
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
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? HomeMediaTVC {
            cell.btnComment.sendActions(for: .touchUpInside)
        }
    }
    
    func reloadTable() {
        tableview.beginUpdates()
        tableview.reloadSections(IndexSet(integer: 0), with: .none)
        tableview.endUpdates()
    }
}

//MARK: - WEBService CAll
extension NewDProfileViewController {
    
    //to get search results
    func WSPostsList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "user_id" : userID == "" ? NextgenUser.shared.id : userID,
            "limit" : limit,
            "offset" : offset,
        ]
        
        var url : ApiURL = .none
        
        switch selectedSegmentIndex {
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
            
            self.arrPosts.removeAll()
            self.arrPosts.append(ModelPostsMain(fromJson: [:]))
            if Success == true{
                
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    
                    if url == .profileLiked {
                        if let post = obj["post"].dictionaryObject, post.count > 0 {
                            self.arrPosts.append(ModelPostsMain(fromJson: obj["post"]))
                        }
                    }else {
                        let singleObj = ModelPostsMain(fromJson: obj)
                        singleObj.user = ModelPostsUser(fromJson: JSON(self.currentUserProfile?.toDictionary() ?? [:]))
                        self.arrPosts.append(singleObj)
                    }
                    
                }
                
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                self.tableview.reloadData()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.isDataLoading = false
            self.hasMoreData = false
            self.tableview.reloadData()
        }
    }
    
    func getFollowersList() {
        let id = userID == "" ? NextgenUser.shared.id : userID
        ServiceManager.shared.getRequest(ApiURL: .getFollowersList, strAddInURL: id, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    
    func getProfile() {
        let id = userID == "" ? NextgenUser.shared.id : userID
        ServiceManager.shared.getRequest(ApiURL: .getOtherUserProfile, strAddInURL: id, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
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
    
    func bindData() {
        guard let user = self.currentUserProfile else { return }
        GeneralUtility().setImageWithSDWEBImage(imgView: profileImg, placeHolderImage: placeholderImage, imgPath: user.profileImage)
        GeneralUtility().setImageWithSDWEBImage(imgView: profileBGImg, placeHolderImage: UIImage(named: "edit"), imgPath: user.backgroundImage)
        titleName.text = user.name
        
        detailLbl.text = user.about
        
        btnFollow.isSelected = (user.isFollowing != 0)
        
        btnFollow.setTitle("Follow".localized, for: .normal)
        btnFollow.setTitle("Unfollow".localized, for: .selected)
        btnFollow.setTitleColor(.white, for: .selected)
        btnFollow.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
        
        if btnFollow.isSelected {
            btnFollow.layer.backgroundColor = (UIColor(named: "DarkestYellow") ?? .white).cgColor
        }else{
            btnFollow.layer.backgroundColor = UIColor.black.cgColor
        }
        
        
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
            if !GlobalService.instance.isPausedMusic {
                guard let path = Bundle.main.path(forResource: "memries", ofType:"mp3") else {
                    return }
                let url = URL(fileURLWithPath: path)
                playMusic(url: url)
            }
        }
    }
    
    
}
//MARK: - popmenu
extension  NewDProfileViewController : PopMenuViewControllerDelegate {
    
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


extension NewDProfileViewController: UIDocumentPickerDelegate {
    func openDocumentPicker() {
        var documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [UTType.audio]
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: UIDocumentPickerMode.import)
        }
        documentPicker.delegate = self
        // set popover controller for iPad
        if let popoverController = documentPicker.popoverPresentationController {
            popoverController.sourceView = self.view //set your view name here
        }
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let _ = url.startAccessingSecurityScopedResource()
        let asset = AVURLAsset(url: url)
        guard asset.isComposable else {
            print("Your music is Not Composible")
            return
        }
        addAudio(audioUrl: url)
    }

    func addAudio(audioUrl: URL) {
        // lets create your destination file url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        guard let destinationUrl = destinationUrl else { return }
        print(destinationUrl)
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            self.playMusic(url: destinationUrl)
        } else {
            // if the file doesn't exist you can use NSURLSession.sharedSession to download the data asynchronously
            print("Downloading...")
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    self.playMusic(url: destinationUrl)
                    
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                    
                }
            }).resume()
        }
    }

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
