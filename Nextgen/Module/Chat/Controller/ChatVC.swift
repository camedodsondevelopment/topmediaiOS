//
//  ChatVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import SwiftyJSON

class ChatVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var searchNames: UITextField!

    //MARK: - VARIABLES
    var chatVM = ChatViewModel()
    
    var arrFilteredChat : [Chat] = []
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tblChat.registerCell(type: ChatTVC.self)
        tblChat.setDefaultProperties(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        chatVM.myChatList = self
        getConversionList()
        searchNames.text = ""
    }

    //MARK: - BUTTON ACTIONS
    
    
    @IBAction func btnAddChatClicks(_ sender: UIButton) {
        let vc: AddToChatViewController = AddToChatViewController.instantiate(appStoryboard: .Chat)
        vc.modalPresentationStyle = .fullScreen
        vc.selectedUserCloser = { user in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                let vc : ChatDetailsVC = ChatDetailsVC.instantiate(appStoryboard: .Chat)
                vc.chatVM.otherUserID = user.id.description
                vc.otherUserObj = ModelOtherUserProfile(fromJson: JSON(user.toDictonary()))
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
        present(vc, animated: true)
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arrFilteredChat.count == 0 {
            self.tblChat.setEmptyMessage("No chat found!".localized)
        } else {
            self.tblChat.restore()
        }
        
        return  arrFilteredChat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTVC") as? ChatTVC {
            
            if arrFilteredChat.count > 0 {
                
                let current = arrFilteredChat[indexPath.row]
                
                let fullName = (current.sentbyDetails?.name ?? "")
                cell.lblUserName.text = fullName
                
                var components = fullName.components(separatedBy: " ")
                if components.count > 0 {
                    let firstName = components.removeFirst()
                    let lastName = components.joined(separator: " ")
                    let text = (firstName.first?.description ?? "") + (lastName.first?.description ?? "")
                    UIGraphicsEndImageContext()
                    
                    if current.sentbyDetails?.profileImage == "" {
                        cell.imgProfile.image = GeneralUtility().createImageFromString(text: text, size: 12)
                        cell.imgProfile.backgroundColor = UIColor(named: "CommonBG")
                    } else {
                        cell.imgProfile.backgroundColor = .clear
                        GeneralUtility().setImageWithSDWEBImage(imgView: cell.imgProfile, placeHolderImage: GeneralUtility().createImageFromString(text: text, size: 12), imgPath: current.sentbyDetails?.profileImage ?? "", isWithoutFade: true)
                    }
                }                
                cell.lblLastMsg.text = current.lastmsg
                
                
                let currentDate = current.lastmsgtime.dateValue()
                cell.lblTime.text = timeAgoSinceDate(currentDate)
                
                cell.layoutIfNeeded()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GeneralUtility().addButtonTapHaptic()
        
        let vc : ChatDetailsVC = ChatDetailsVC.instantiate(appStoryboard: .Chat)
        self.chatVM.currentChat = arrFilteredChat[indexPath.row]
        vc.chatVM = self.chatVM
        vc.chatVM.otherUserID = arrFilteredChat[indexPath.row].sentbyDetails?.internalIdentifier ?? ""
        vc.otherUserObj = ModelOtherUserProfile(fromJson: JSON(arrFilteredChat[indexPath.row].sentbyDetails?.toDictonary() ?? [:]))
        vc.callback = { _ in
            tableView.reloadData()
        }
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let object = arrFilteredChat[indexPath.row]
        let filterAction = UIContextualAction(style: .normal, title: "Block User") { (action, view, bool) in
            
            let alert = UIAlertController(title: "Block User".localized, message: nil, preferredStyle: .actionSheet)

            let yes = UIAlertAction(title: "Yes".localized, style: .default){
                UIAlertAction in
                self.WSBlockUser(userID: object.sentbyDetails?.internalIdentifier ?? "", index: indexPath.row)
            }
            let no = UIAlertAction(title: "No".localized, style: .default){UIAlertAction in}
            
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true)
        }
        filterAction.backgroundColor = UIColor.red

        return UISwipeActionsConfiguration(actions: [filterAction])
    }
    
    func WSBlockUser(userID:String, index:Int) {
        CommonClass().showAlertWithTitleFromVC(vc: self, title: "Block User", andMessage: "Are you sure you want to block this user?", buttons: ["Yes".localized, "No".localized]) { index in
            if index == 0 {
                let Parameter:[String:Any] = ["id" : userID]
                ServiceManager.shared.postRequest(ApiURL: .reportUser, parameters: Parameter) { (response, Success, message, statusCode) in
                    
                    if Success == true{
                        self.arrFilteredChat.remove(at: index)
                        self.tblChat.reloadData()
                        self.chatVM.deleteChat(msgID: userID, complete: {})
                    }
                    
                } Failure: { (response, Success, message, statusCode) in
                    print("Failure Response:",response)
                }
            }
        }
    }
}

//MARK: - GET MESSAGEs
extension ChatVC {

    func getConversionList() {
        if chatVM.arrOfConversions.count == 0 {
            SHOW_CUSTOM_LOADER()
        }
        chatVM.loadAllTheConversions { bool, count in
            self.HIDE_CUSTOM_LOADER()
            if bool {
                self.tblChat.restore()
                self.tblChat.reloadData()
            } else {
                if self.chatVM.arrOfMessages.count == 0 {
                    self.tblChat.setEmptyMessage("No chat found!".localized)
                } else {
                    self.tblChat.restore()
                }
                self.tblChat.reloadData()
            }
            self.arrFilteredChat = self.chatVM.arrOfConversions.filter({!$0.lastmsg.removeWhiteSpace().isEmpty})
        }
    }
}

extension ChatVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.count > 0 {
                arrFilteredChat = arrFilteredChat.filter({($0.sentbyDetails?.name ?? "").localizedCaseInsensitiveContains(updatedText)})
            }else{
                arrFilteredChat = chatVM.arrOfConversions.filter({!$0.lastmsg.removeWhiteSpace().isEmpty})
            }
            tblChat.reloadData()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    
    
}
