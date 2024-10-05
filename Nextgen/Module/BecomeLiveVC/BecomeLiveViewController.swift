//
//  BecomeLiveViewController.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 05/09/2024.
//

import UIKit
import AgoraRtcKit
import FirebaseDatabase

let agoraSDKID = "b673ebc7bd554a90a3ab2ce75c611ab8"
var channelName = ""
var broadcasterName = ""
var bcasterProfileImage = ""
var isABroadcaster: Bool = false
var broadcasters:[UInt] = [UInt(NextgenUser.shared.id) ?? 0]

class BecomeLiveViewController: UIViewController {
    
    var agoraKit: AgoraRtcEngineKit!
    
    @IBOutlet weak var goLiveButton: UIButton!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var lblLikesCount: UILabel!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userSubTitle:UILabel!
    @IBOutlet weak var clickActionsView:UIStackView!
    @IBOutlet weak var userView: UIStackView!
    @IBOutlet weak var audienceCountLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var invteBtn:UIButton!
    
    @IBOutlet weak var videoViewForB1:UIView!
    @IBOutlet weak var videoViewForB2:UIView!
    @IBOutlet weak var videoViewForB3:UIView!
    @IBOutlet weak var videoViewForB4:UIView!
    @IBOutlet weak var stackView2:UIStackView!
    
    
    var isLiked : Bool = false {
        didSet {
            if isLiked {
                imgLike.image = UIImage(named: "big_heart_filled")
            } else {
                imgLike.image = UIImage(named: "big_heart_empty")
            }
        }
    }
    
    var agoraSDKToken = ""
    var postObj:ModelVideoListMain?
    var joinerType:String = ""
    var audienceCount: Int = 0
    var dbRef:DatabaseReference!
    var comments: [Comment] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if joinerType == "audience" {
            setupAudience()
        }else{
            startPreview()
            if isABroadcaster {
                isABroadcaster = false
                autoLiveFromInvite()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if joinerType == "audience" {
            updateAudienceCount(by: -1)
        }else{
            deleteAudeienceCountNode()
        }
        deleteComment(commentId: "\(channelName)/\(NextgenUser.shared.id)-\(Int(Date().timeIntervalSince1970))")
    }
    
    func initView() {
        
        UIApplication.shared.isIdleTimerDisabled = true
        dbRef = Database.database().reference()
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: agoraSDKID, delegate: self)
        
        agoraKit.enableVideo()
        
        let videoConfiguration = AgoraVideoEncoderConfiguration(
            size: AgoraVideoDimension640x360,
            frameRate: .fps15,
            bitrate: 1000,
            orientationMode: .adaptative,
            mirrorMode: .auto
        )
        agoraKit.setVideoEncoderConfiguration(videoConfiguration)
        invteBtn.isHidden = true

        if joinerType == "audience" {
            goLiveButton.isHidden = true
        }else{
            goLiveButton.isHidden = false
            clickActionsView.isHidden = true
            userView.isHidden = true
        }
        
        fetchAudienceCount()
        listenForComments()
        
        goLiveButton.addTarget(self, action: #selector(goLiveButtonPressed(_:)), for: .touchUpInside)
        userName.text = broadcasterName
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: AvatarImage, imgPath: bcasterProfileImage)
        
        
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
    
    @IBAction func backBtnClicked(_ sender:UIButton){
        if joinerType == "audience" {
            closeAndDismiss()
        }else{
            offLiveAndBack {
                self.closeAndDismiss()
            }
        }
    }
    
    func closeAndDismiss(){
        channelName = ""
        agoraKit.muteLocalAudioStream(true)
        agoraKit.muteLocalVideoStream(true)
        agoraKit.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
        
        dismissVC()
    }
    
    
    @IBAction func btnLikeClicks(_ sender: UIButton) {
        WSLike()
    }
    
    @IBAction func inviteBtnClicked(_ sender: UIButton) {
        let vc : InviteStreamingUserViewController = InviteStreamingUserViewController.instantiate(appStoryboard: .Home)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: false)
    }
    
    @IBAction func sendCommentClicked(_ sender: UIButton) {
        guard let commentText = commentTextField.text, !commentText.isEmpty else { return }
                
        // Create a new comment
        let comment = Comment(id: channelName, userId: NextgenUser.shared.id, userName: NextgenUser.shared.name, userImg: NextgenUser.shared.profileImage, commentText: commentText, timestamp: Date().timeIntervalSince1970)
        
        let ref = "Comments/\(channelName)/\(NextgenUser.shared.id)-\(Int(Date().timeIntervalSince1970))"
        
        // Save the comment
        dbRef.child(ref).setValue([
            "userId": comment.userId,
            "commentText": comment.commentText,
            "timestamp": comment.timestamp,
            "userName": comment.userName,
            "userImg" : comment.userImg
        ]) { error, _ in
            if let error = error {
                print("Error adding comment: \(error.localizedDescription)")
            } else {
                self.commentTextField.text = ""
                print("Comment successfully added!")
            }
        }
        
    }
    
    @objc func goLiveButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            startPreview()
            startLiveStreaming()
            notficyAPICallBeforeLive()
            sender.setTitle("Live", for: .selected)
        }else{
            stopLiveStreaming()
            sender.setTitle("Go Live", for: .normal)
        }
    }
    
    func autoLiveFromInvite() {
        startLiveStreaming()
        goLiveButton.setTitle("Live", for: .selected)
    }
    
    func setupRemoteVideoStream(uid: UInt) {
        guard let agoraKit = agoraKit else { return }
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        
        if broadcasters.count == 1 {
            videoCanvas.view = videoViewForB1
            videoViewForB1.tag = Int(uid)
            videoViewForB2.isHidden = true
            stackView2.isHidden = true
        }else if broadcasters.count == 2 {
            videoCanvas.view = videoViewForB3
            videoViewForB3.tag = Int(uid)

            videoViewForB3.isHidden = false
            videoViewForB2.isHidden = true
            videoViewForB4.isHidden = true
            stackView2.isHidden = false
        }else if broadcasters.count == 3 {
            videoCanvas.view = videoViewForB2
            videoViewForB2.tag = Int(uid)

            videoViewForB2.isHidden = false
            videoViewForB4.isHidden = true
        }else {
            videoCanvas.view = videoViewForB4
            videoViewForB4.tag = Int(uid)

            videoViewForB4.isHidden = false
        }
        
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    func startPreview() {
        let videoCanvas = AgoraRtcVideoCanvas()
        
        if broadcasters.count == 1 {
            videoCanvas.view = videoViewForB1
            videoViewForB2.isHidden = true
            stackView2.isHidden = true
        }else if broadcasters.count == 2 {
            videoCanvas.view = videoViewForB3
            videoViewForB3.isHidden = false
            videoViewForB2.isHidden = true
            videoViewForB4.isHidden = true
            stackView2.isHidden = false
        }else if broadcasters.count == 3 {
            videoCanvas.view = videoViewForB2
            videoViewForB2.isHidden = false
            videoViewForB4.isHidden = true
        }else {
            videoCanvas.view = videoViewForB4
            videoViewForB4.isHidden = false
        }
        
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        agoraKit.startPreview()
    }
    
    func stopLiveStreaming(){
        agoraKit.muteLocalAudioStream(true)
        agoraKit.muteLocalVideoStream(true)
        agoraKit.leaveChannel(nil)
    }
    
    func startLiveStreaming() {
        agoraKit.muteLocalAudioStream(false)
        agoraKit.muteLocalVideoStream(false)
        
        let options = AgoraRtcChannelMediaOptions()
        options.channelProfile = .liveBroadcasting
        options.clientRoleType = .broadcaster
        options.audienceLatencyLevel = .ultraLowLatency
        options.publishMicrophoneTrack = true
        options.publishCameraTrack = true
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true
        
        let joinResult = agoraKit.joinChannel(byToken: agoraSDKToken, channelId: channelName, uid: UInt(NextgenUser.shared.id) ?? 0, mediaOptions: options)
        
        if joinResult != 0 {
            print("Failed to join channel with error code: \(joinResult)")
        } else {
            print("Live streaming started successfully")
            invteBtn.isHidden = false
        }
    }
    
    func setupAudience() {
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.audience)
        let token = agoraSDKToken
        let channelName = channelName
        let uid: UInt = UInt(NextgenUser.shared.id) ?? 0
        
        // Join the channel
        agoraKit.joinChannel(byToken: token, channelId: channelName, info: nil, uid: uid) { (channel, uid, elapsed) in
            print("Joined channel: \(channel) with UID: \(uid)")
            self.updateAudienceCount(by: 1)
        }
    }

    
    func notficyAPICallBeforeLive(){
        
        let parameter : [String : Any] =
        [
            "channel_name" : channelName
            
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .notifyToAllFollowers, parameters: parameter, Success: { (response, Success, message, statusCode) in
            
            let responseDcit = response.dictionaryValue
            
            if let token = responseDcit["data"]?.stringValue, token.count > 0 {
                
            }else{
//                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: responseDcit["message"]?.stringValue ?? "")
            }
           
            
        }, Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        })
    }
    
    func offLiveAndBack(complete: @escaping ()->Void){
        ServiceManager.shared.getRequest(ApiURL: .liveOffStatus, parameters: [:], Success: { (response, Success, message, statusCode) in
            
            let responseDict = response.dictionaryValue
            print(responseDict)
            complete()
            
        }, Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        })
    }
    
}

extension BecomeLiveViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        if reason == .quit || reason == .dropped {
            if let index = broadcasters.firstIndex(of: uid) {
                broadcasters.remove(at: index)
                if videoViewForB1.tag == uid {
                    videoViewForB1.isHidden = true
                }else if videoViewForB2.tag == uid {
                    videoViewForB2.isHidden = true
                }else if videoViewForB3.tag == uid {
                    videoViewForB3.isHidden = true
                }else{
                    videoViewForB4.isHidden = true
                }
            }
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("Error occurred: \(errorCode.rawValue) - \(errorCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("User \(uid) joined channel \(channel) in \(elapsed)ms")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("Left channel with stats: \(stats)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didUserJoined uid: UInt, elapsed: Int) {
        print("User \(uid) joined the channel in \(elapsed)ms")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didUserOffline uid: UInt, reason: AgoraUserOfflineReason) {
        print("User \(uid) went offline for reason: \(reason.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("Broadcaster with UID \(uid) joined the channel.")
        if broadcasters.contains(uid) { return }
        broadcasters.append(uid)
        setupRemoteVideoStream(uid: uid)
    }
}

extension BecomeLiveViewController{
    
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
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
}

extension BecomeLiveViewController {
    
    func fetchAudienceCount() {
        dbRef.child("AudienceCounter/\(channelName)/audience_count").observe(.value) { snapshot in
            if let count = snapshot.value as? Int {
                self.audienceCount = count
                self.updateAudienceLabel()
            }
        }
    }
    
    func updateAudienceCount(by value: Int) {
        dbRef.child("AudienceCounter/\(channelName)/audience_count").runTransactionBlock { currentData in
            var count = currentData.value as? Int ?? 0
            count += value
            currentData.value = count
            return TransactionResult.success(withValue: currentData)
        } andCompletionBlock: { error, _, _ in
            if let error = error {
                print("Error updating data: \(error)")
            } else {
                self.fetchAudienceCount() // Refresh count after update
            }
        }
    }
    
    func deleteAudeienceCountNode(){
        dbRef.child("AudienceCounter/\(channelName)/audience_count").removeValue()
    }
    
    func updateAudienceLabel() {
        audienceCountLabel.text = "\(audienceCount)"
    }
    
    func deleteComment(commentId: String) {
        let ref = Database.database().reference().child("Comments")
        ref.child(commentId).removeValue { error,arg  in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
            } else {
                print("Comment successfully deleted!")
            }
        }
    }
    
    func listenForComments() {
        dbRef.child("Comments/\(channelName)").observe(.childAdded) { snapshot, previousChildKey in
            guard let data = snapshot.value as? [String: Any],
                  let userId = data["userId"] as? String,
                  let commentText = data["commentText"] as? String,
                  let timestamp = data["timestamp"] as? TimeInterval,
                  let userName =  data["userName"] as? String,
                  let userImg = data["userImg"] as? String else { return }
            
            let newComment = Comment(id: snapshot.key, userId: userId, userName: userName, userImg: userImg, commentText: commentText, timestamp: timestamp)
            self.comments.append(newComment)
            self.commentsTableView.reloadData()
            self.commentsTableView.scrollToBottom()
        }
    }
}

extension BecomeLiveViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentsTableViewCell
        let comment = comments[indexPath.row]
        cell.setupUI(object: comment)
        return cell
    }
}
