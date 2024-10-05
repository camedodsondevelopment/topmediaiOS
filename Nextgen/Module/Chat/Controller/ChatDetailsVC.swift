//
//  ChatDetailsVC.swift
//  Nextgen
//
//  Created by jacky on 06/09/22.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift

class ChatDetailsVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblMessages: UITableView!
    @IBOutlet weak var txtMessage: AutoExpandingTextView!{
        didSet {
            txtMessage.maxHeight = 150
        }
    }
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    //MARK: - VARIABLES
    var chatVM = ChatViewModel()
    var isFromNotificaiton = false
    var callback : ((Int) -> Void)?
    var otherUserObj : ModelOtherUserProfile?

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        let modeKey = UserDefaults.standard.string(forKey: "MODE_KEY")
        if modeKey == "DARK"{
            txtMessage.textColor = UIColor.white
        }
        chatVM.vc = self
        setUI()
        
        dataDisplay()
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        GeneralUtility().addButtonTapHaptic()
        
        if self.isFromNotificaiton {
            appDelegate.setHomeRoot()
            
        } else {
            self.navigationController?.popViewController(animated: true)
            self.dismissVC()
        }
    }
    
    @IBAction func btnVoiceCallClicks(_ sender: Any) {
        
    }
    
    @IBAction func btnVideoCallClicks(_ sender: Any) {
        if let zoomURL = URL(string: "zoomus://") , UIApplication.shared.canOpenURL(zoomURL) {
            UIApplication.shared.open(zoomURL)
        }else if let zoomWebURL = URL(string: "https://zoom.us/") {
            UIApplication.shared.open(zoomWebURL)
        }
    }
    
    @IBAction func btnSendClicks(_ sender: Any) {
        if let txt = txtMessage.text, txt.count > 0 {
            chatVM.msgTyped = txtMessage.text ?? ""
            txtMessage.text = ""
            chatVM.save()
        }else{
            
        }
        
    }
    
    @IBAction func btnUserImageClicks(_ sender: Any) {
        let vc : NewDProfileViewController = NewDProfileViewController.instantiate(appStoryboard: .Profile)
        vc.userID = chatVM.otherUserID
        vc.isFromChat = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - GENERAL METHOD
extension ChatDetailsVC {
    
    func setUI()  {
        tblMessages.transform = CGAffineTransform(scaleX: 1, y: -1)
        tblMessages.reloadData()

        tblMessages.registerCell(type: ChatSenderTVC.self)
        tblMessages.registerCell(type: ChatReciverTVC.self)

        tblMessages.registerCell(type: RightChatListTVC.self)
        tblMessages.registerCell(type: LeftChatListTVC.self)
        tblMessages.setDefaultProperties(self)
        txtMessage.delegate = self
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.chatVM.arrOfMessages.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatVM.arrOfMessages[section].allTheMessages.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myrowData = self.chatVM.arrOfMessages[indexPath.section].allTheMessages[indexPath.row]
        if myrowData.senderID != NextgenUser.shared.id {
            if myrowData.is_read == "0" {
                self.chatVM.doUpdateSeen(msgID: myrowData.id)
                self.callback?(0)
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let myrowData = self.chatVM.arrOfMessages[indexPath.section].allTheMessages[indexPath.row]

        if myrowData.senderID ==  NextgenUser.shared.id {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderTVC") as? ChatSenderTVC {
                cell.lblMessage.text = myrowData.value
                
                let dayTime = DateFormatter()
                dayTime.dateFormat = "hh:mm a"
                let dateString = dayTime.string(from: myrowData.created?.dateValue() ?? Date())
                cell.lblTime.text = dateString
                
                cell.selectionStyle = .none
                cell.layoutIfNeeded()
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }
            
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReciverTVC") as? ChatReciverTVC {
                cell.lblMessage.text = myrowData.value
                
                let dayTime = DateFormatter()
                dayTime.dateFormat = "hh:mm a"
                let dateString = dayTime.string(from: myrowData.created?.dateValue() ?? Date())
                cell.lblTime.text = dateString
                
                cell.selectionStyle = .none
                cell.layoutIfNeeded()
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let headerLabelView = UILabel(frame: CGRect(x: 0, y: tableView.frame.size.height - 20, width: tableView.frame.size.width, height: 30))
        let headerLabel = UILabel(frame: CGRect(x: (tableView.frame.size.width-100)/2, y: 0, width: 100, height: 30))
        
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.font = TitilliumRegularS13
        headerLabel.backgroundColor = .clear
        headerLabel.textAlignment = .center
        headerLabel.layer.cornerRadius = 12
        headerLabel.clipsToBounds = true
        headerLabel.textColor = .gray
        headerLabelView.layer.cornerRadius = 12
        headerLabel.text = self.chatVM.arrOfMessages[section].date
        
        headerLabelView.transform = CGAffineTransform(scaleX: 1, y: -1)
        headerLabelView.addSubview(headerLabel)
        
        return headerLabelView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if(velocity.y>0) {
            //Code will work without the animation block.I am using animation block incase if you want to set any delay to it.
            UIView.animate(withDuration: 2.5, delay: 0, options: UIView.AnimationOptions(), animations: {
                print("Hide")
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 2.5, delay: 0, options: UIView.AnimationOptions(), animations: {
                
                print("Unhide")
            }, completion: nil)
        }
    }
}


//MARK:- UITextViewDelegate
extension ChatDetailsVC: UITextViewDelegate {
    

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text != "" {
            chatVM.msgTyped = textView.text ?? ""
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard range.location == 0 else {
            return true
        }
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
    
    
}

//MARK: - GENERAL METHOD
extension ChatDetailsVC {
    
    func dataDisplay() {
        
        chatVM.otherUserDetails = otherUserObj?.toDictionary() ?? [:]
        chatVM.currentUserDetails = NextgenUser.shared.toDictionary()

        lblUserName.text = otherUserObj?.name ?? ""
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: placeholderImage, imgPath: (otherUserObj?.profileImage ?? ""))
        chatVM.loadChatMsgs()
    }

}
