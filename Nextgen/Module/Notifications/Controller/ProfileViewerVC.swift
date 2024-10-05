//
//  ProfileViewerVC.swift
//  Nextgen
//
//  Created by jacky on 06/09/22.
//

import UIKit

class ProfileViewerVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblUsers: UITableView!

    //MARK: - VARIABLES
    var isDataLoading:Bool=false
    var limit : Int = 10
    var offset : Int = 0
    var hasMoreData : Bool = false
    
    var arrUsers : [ModelPostsUser] = [] {
        didSet {
            if arrUsers.count == 0 {
                tblUsers.setEmptyMessage("No data found!".localized)
            }else {
                tblUsers.restore()
            }
            
            self.offset = arrUsers.count
            self.tblUsers.reloadData()
        }
    }

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblUsers.registerCell(type: UsersTVC.self)
        tblUsers.setDefaultProperties(self)
        
        self.arrUsers.removeAll()
        WSUsersList()
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ProfileViewerVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hasMoreData {
            return 2
        }else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return arrUsers.count
        }else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UsersTVC") as? UsersTVC {
                if arrUsers.count > indexPath.row {
                    cell.bindData(obj: arrUsers[indexPath.row])
                }
                return cell
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
        
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellAnimation(cell: cell, indexPath: indexPath)
//    }

}


//MARK: - Pagination
extension ProfileViewerVC {
    //Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tblUsers {
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 350 {
                
                if !isDataLoading {
                    isDataLoading = true
                    
                    if self.hasMoreData {
                        self.WSUsersList(isShowLoader: false)
                    }
                }
            }
        }
    }
    
}

//MARK: - WEBService CAll
extension ProfileViewerVC {
    
    //to get search results
    func WSUsersList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "limit" : self.limit,
            "offset" : self.offset,
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .getProfileViewer, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            if self.offset == 0 {
                self.arrUsers.removeAll()
            }
            
            if Success == true{
                
                let dataObj = response["data"]
                
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    self.arrUsers.append(ModelPostsUser(fromJson: obj))
                }
                
                self.offset = self.arrUsers.count
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                
                self.tblUsers.reloadData()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.isDataLoading = false
            self.hasMoreData = false
            self.tblUsers.reloadData()
        }
    }
}

