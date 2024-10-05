//
//  NotificationsVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
//CustomizedTableView
class NotificationsVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblNotifiations: UITableView!
    @IBOutlet weak var btnClearAll: UIButton!
    
    //MARK: - VARIABLES
    var isDataLoading:Bool=false
    var limit : Int = 10
    var offset : Int = 0
    var hasMoreData : Bool = false
    
    var arrNotifications : [ModelNotificationList] = [] {
        didSet {
            if arrNotifications.count == 0 {
                tblNotifiations.setEmptyMessage("No data found!".localized)
                btnClearAll.isHidden = true
            }else {
                tblNotifiations.restore()
                btnClearAll.isHidden = false
            }
            
            self.offset = arrNotifications.count
            self.tblNotifiations.reloadData()
        }
    }
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblNotifiations.registerCell(type: NotificationViewerTVC.self)
        tblNotifiations.registerCell(type: LoadingTVC.self)
        tblNotifiations.setDefaultProperties(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        arrNotifications.removeAll()
        WSNotificationList()
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnClearClicks(_ sender: Any) {
        CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: "Are you sure want to remove all notifications?", buttons: ["Yes".localized , "No".localized]) { index in
            if index == 0 {
                self.WSClearNotifications()
            }
        }
    }
    
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension NotificationsVC : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if hasMoreData {
            return 2
        }else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return arrNotifications.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationViewerTVC") as? NotificationViewerTVC {

            if arrNotifications.count > indexPath.row {
                cell.bindData(obj: arrNotifications[indexPath.row])
            }
                        
            cell.seeAllCloser = {
                let vc : ProfileViewerVC = ProfileViewerVC.instantiate(appStoryboard: .Notifications)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrNotifications[indexPath.row].notification_type ?? 0 == 1 {
            let vc : NewDProfileViewController = NewDProfileViewController.instantiate(appStoryboard: .Profile)
            vc.userID = arrNotifications[indexPath.row].userId.description
            UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            let vc : PostDetailsVC = PostDetailsVC.instantiate(appStoryboard: .Home)

            vc.postID = arrNotifications[indexPath.row].objectId?.description ?? ""
            UIApplication.topViewController()!.navigationController?.pushViewController(vc, animated: true)
        }
        

        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cellAnimation(cell: cell, indexPath: indexPath)
    }

}


//MARK: - Pagination
extension NotificationsVC {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tblNotifiations {
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 350 {
                
                if !isDataLoading {
                    isDataLoading = true
                    
                    if self.hasMoreData {
                        self.WSNotificationList(isShowLoader: false)
                    }
                }
            }
        }
    }
    
}

//MARK: - WEBService CAll
extension NotificationsVC {
    
    //to get search results
    func WSNotificationList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "limit" : self.limit,
            "offset" : self.offset,
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .getNotificationList, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            if self.offset == 0 {
                self.arrNotifications.removeAll()
            }
            
            if Success == true{
                
                let dataObj = response["data"]
                
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    self.arrNotifications.append(ModelNotificationList(fromJson: obj))
                }
                
                self.offset = self.arrNotifications.count
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                
                self.tblNotifiations.reloadData()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.isDataLoading = false
            self.hasMoreData = false
            self.tblNotifiations.reloadData()
        }
    }
    
    func WSClearNotifications() {
        
        ServiceManager.shared.getRequest(ApiURL: .RemoveAllNotifications, parameters: [:] , isShowLoader : true) { (response, Success, message, statusCode) in
            
            if self.offset == 0 {
                self.arrNotifications.removeAll()
            }
            
            if Success == true{
                
                self.arrNotifications.removeAll()

                self.tblNotifiations.reloadData()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        }
    }
}

