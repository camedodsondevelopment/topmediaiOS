//
//  FollowingFollowerListVC.swift
//  Nextgen
//
//  Created by jacky on 08/09/22.
//

import UIKit
import BetterSegmentedControl

class FollowingFollowerListVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblUsers: UITableView!
    @IBOutlet weak var segmentTypes: BetterSegmentedControl!
    
    
    @IBOutlet weak var atTitleLbl: UILabel!
    @IBOutlet weak var titleOneLbl: UILabel!
    @IBOutlet weak var titleTwoLbl: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    
    //MARK: - VARIABLES
    var isShowFollowingFirst : Bool = false
    var currentUserProfile : ModelOtherUserProfile?
    
    var isDataLoading:Bool=false
    var limit : Int = 100
    var offset : Int = 0
    var hasMoreData : Bool = false
    var userID:String = ""

    
    var arrUsers : [ModelPostsUser] = [] {
        didSet {
            if arrUsers.count == 0 {
                tblUsers.setEmptyMessage(AlertMessage.noDataFound)
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
        
        tblUsers.registerCell(type: FollowingFollowerTVC.self)
        tblUsers.registerCell(type: LoadingTVC.self)
        tblUsers.setDefaultProperties(self)
        
        setSegment()
        
        if isShowFollowingFirst {
            segmentTypes.setIndex(1)
            tblUsers.reloadData()
        }
                
        WSUsersList()
        guard let user = self.currentUserProfile else { return }
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: nil, imgPath: user.profileImage)
        
        titleOneLbl.text = user.name
        titleTwoLbl.text = user.about
        atTitleLbl.text = "@\(user.name ?? "")"
        
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func segmentTypeChanged(_ sender: Any) {
        offset = 0
        arrUsers.removeAll()
        WSUsersList()
    }
}

//MARK: - GENERAL FUNCTIONS
extension  FollowingFollowerListVC {
    
    func setSegment() {
        
        let fontSelected = TitilliumRegularS16
        let fontUnSelected = TitilliumRegularS16
        
        let defaultColor = UIColor.clear
        let selectedBGColor = UIColor.AppBlueColor
        
        segmentTypes.segments = LabelSegment.segments(withTitles: ["Followers".localized , "Following".localized], numberOfLines: 1, normalBackgroundColor: defaultColor, normalFont: fontUnSelected, normalTextColor: .black, selectedBackgroundColor: selectedBGColor, selectedFont: fontSelected, selectedTextColor: .white)
    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension FollowingFollowerListVC : UITableViewDelegate, UITableViewDataSource {
    
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
            
            if arrUsers.count > indexPath.row {
                
                let obj = arrUsers[indexPath.row]
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingFollowerTVC") as? FollowingFollowerTVC {
                    cell.bindData(obj: obj)
                    
                    if segmentTypes.index == 0 {
                        cell.btnRemoveUnfollow.setTitle("Remove".localized, for: .normal)
                        cell.btnRemoveUnfollow.setTitle("Remove".localized, for: .selected)
                    }else {
                        cell.btnRemoveUnfollow.setTitle("Unfollow".localized, for: .normal)
                        cell.btnRemoveUnfollow.setTitle("Unfollow".localized, for: .selected)
                    }
                    
                    if userID == "" {
                        cell.btnRemoveUnfollow.isHidden = false
                    }else{
                        cell.btnRemoveUnfollow.isHidden = true
                    }

                    cell.btnRemoveUnfollowCloser = {
                        if self.segmentTypes.index == 0 {
                            CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: AlertMessage.removeFollowingUser, buttons: ["Yes".localized,"No".localized]) { index in
                                if index == 0{
                                    self.WSRemoveFollowingUser(userID: obj.id.description, index: indexPath.row)
                                }
                            }
                        }else {
                            CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: AlertMessage.unfollowConfirmation, buttons: ["Yes".localized,"No".localized]) { index in
                                if index == 0{
                                    self.WSUNFollowUser(userID: obj.id.description, index: indexPath.row)
                                }
                            }
                        }
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
        if indexPath.section == 0 {
            let vc : NewDProfileViewController = NewDProfileViewController.instantiate(appStoryboard: .Profile)
            vc.isFromChat = true
            vc.userID =  "\(arrUsers[indexPath.row].id ?? 0)"
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

//MARK: - Pagination
extension FollowingFollowerListVC {
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
extension FollowingFollowerListVC {
    
    //to get search results
    func WSUsersList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "limit" : limit,
            "offset" : offset,
            "user_id" : userID
        ]
        
        var url : ApiURL = .getFollowersList
        if segmentTypes.index == 0 {
            url = .getFollowersList
        }else {
            url = .getFollowingList
        }
        
        ServiceManager.shared.postRequest(ApiURL: url, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            if Success == true{
                
                let dataObj = response["data"]
                let arr = dataObj.arrayValue
                self.arrUsers.removeAll()
                
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
    
    func WSUNFollowUser(userID : String , index : Int) {
        
        ServiceManager.shared.getRequest(ApiURL: .followUser, strAddInURL: userID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            self.arrUsers.remove(at: index)
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    func WSRemoveFollowingUser(userID : String , index : Int) {
        
        ServiceManager.shared.getRequest(ApiURL: .removeFollowingUser, strAddInURL: userID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            self.arrUsers.remove(at: index)
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }

}

