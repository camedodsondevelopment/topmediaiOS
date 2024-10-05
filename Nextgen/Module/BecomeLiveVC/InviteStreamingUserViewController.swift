//
//  InviteStreamingUserViewController.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 28/09/2024.
//

import UIKit

class InviteStreamingUserViewController: UIViewController {

    @IBOutlet weak var searchTF:UITextField!
    @IBOutlet weak var usersTable:UITableView!
    
    var arrUsers : [ModelPostsUser] = []
    var selectedUIDs:[Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchUser(searchText: "a")
    }
    
    @IBAction func closeSearchBtn(_ sender:UIButton){
        searchTF.text = ""
        searchUser(searchText: "a")
    }
    
    @IBAction func inviteBtn(_ sender:UIButton){
        inviteUsersAPICall()
    }
    
    @IBAction func closeBtn(_ sender:UIButton) {
        dismissVC()
    }

    func inviteUsersAPICall(){
        
        let parameter : [String : Any] = ["channel_name" : channelName, "user_ids": selectedUIDs]
        
        ServiceManager.shared.postRequest(ApiURL: .inviteUsersForStreaming, parameters: parameter, Success: { (response, Success, message, statusCode) in
            
            let responseDcit = response.dictionaryValue
            
            CommonClass().showAlertWithTitleFromVC(vc: self, title: "Success", andMessage: responseDcit["message"]?.stringValue ?? "", buttons: ["OK"], completion: { yes in
                self.dismiss(animated: false)
            })
           
        }, Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        })
    }
}

extension InviteStreamingUserViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText != "" {
                searchUser(searchText: updatedText)
            }else{
                searchUser(searchText: "a")
            }
        }
        
        return true
    }
    
    func searchUser(searchText: String)  {
        let Parameter:[String:Any] = ["limit" : "100" , "offser" : "0" , "search" : searchText]
        
        ServiceManager.shared.postRequest(ApiURL: .searchUser, parameters: Parameter) { response, isSuccess, error, statusCode in
            
            if isSuccess == true{
                self.arrUsers.removeAll()
                
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    self.arrUsers.append(ModelPostsUser(fromJson: obj))
                }
                // self.offset = self.arrUsers.count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                    self.usersTable.reloadData()
                }
            }
            
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
        
    }
}


extension InviteStreamingUserViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrUsers.count > 0 {
            usersTable.restore()
        }else{
            usersTable.setEmptyMessage("No Users found!".localized)
        }
        return arrUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == usersTable{
            let data = arrUsers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
            GeneralUtility().setImageWithSDWEBImage(imgView: cell.personImg, placeHolderImage: AvatarImage, imgPath: data.profileImage)
            cell.titleLbl.text = "\(data.name) \(data.username ?? "")"
            
            if selectedUIDs.contains(arrUsers[indexPath.row].id) {
                cell.selectedImg.isHidden = false
            }else{
                cell.selectedImg.isHidden = true
            }
            
            
            cell.selectionStyle = .none
            return cell
        }else {
            
            if let cell  = tableView.dequeueReusableCell(withIdentifier: "LoadingTVC", for: indexPath) as? LoadingTVC {
                cell.startLoading()
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = arrUsers[indexPath.row]
        if selectedUIDs.contains(object.id) {
            selectedUIDs.removeAll(where: {$0 == object.id})
        }else{
            selectedUIDs.append(object.id)
        }
        
        usersTable.reloadData()
    }
}

