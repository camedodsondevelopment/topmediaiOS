//
//  AddToChatViewController.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 26/12/2023.
//

import UIKit

class AddToChatViewController: UIViewController {

    @IBOutlet weak var searchTX:UITextField!
    @IBOutlet weak var searchTB:UITableView!
    
    var arrUsers : [ModelPostsUser] = []
    var selectedUserCloser:((ModelPostsUser)->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTX.delegate = self
        searchTB.delegate = self
        searchTB.dataSource = self

    }
    
    @IBAction func closeBtnPressed(_ sender:UIButton){
        dismissVC()
    }
    
    func searchUser(searchText: String)  {
        let Parameter:[String:Any] = ["limit" : "100" , "offser" : "0" , "search" : searchText]
        
        ServiceManager.shared.postRequest(ApiURL: .searchUser, parameters: Parameter) { response, isSuccess, error, statusCode in
            
            print(response, isSuccess, error, statusCode ?? "")
            if isSuccess == true{
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                self.arrUsers.removeAll()
                
                arr.forEach { (obj) in
                    self.arrUsers.append(ModelPostsUser(fromJson: obj))
                }
                // self.offset = self.arrUsers.count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.searchTB.reloadData()
                }
            }else{
                self.arrUsers.removeAll()
            }
            
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension AddToChatViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrUsers.count > 0 {
            searchTB.restore()
        }else{
            searchTB.setEmptyMessage("No Users found. \n\nSearch user by entring text in the search field.".localized)
        }
        return arrUsers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = arrUsers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        cell.personImg.sd_setImage(with: URL(string: data.profileImage))
        cell.titleLbl.text = "\(data.name) \(data.username ?? "")"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = arrUsers[indexPath.row]
        selectedUserCloser?(object)
        dismissVC()
    }
}


extension AddToChatViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.count > 0 {
                searchUser(searchText: updatedText)
            }else{
                arrUsers.removeAll()
                searchTB.reloadData()
            }
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        arrUsers.removeAll()
        return true
    }
    
}
