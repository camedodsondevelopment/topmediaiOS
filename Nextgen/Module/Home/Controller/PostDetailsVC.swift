//
//  PostDetailsVC.swift
//  Nextgen
//
//  Created by Jacky Patel on 15/10/22.
//

import UIKit

class PostDetailsVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblDetails: UITableView!
    @IBOutlet weak var btnCancelReplay: UIButton!
    @IBOutlet weak var txtComment: AutoExpandingTextView!
    
    @IBOutlet weak var viewReplay: UIView!
    @IBOutlet weak var lblReplayingTo: UILabel!
    //MARK: - VARIABLES
    var postObj : ModelPostsMain?
    
    var isDataLoading:Bool=false
    var limit : Int = 10
    var offset : Int = 0
    var hasMoreData : Bool = false
    var didCommentHandler: (()->Void)?
    var shouldSendMsg:Bool = true
    
    var arrComments : [ModelCommentsMain] = [] {
        didSet {
            self.offset = arrComments.count
            self.tblDetails.reloadData()
        }
    }
    
    var postID : String = ""
    var commentInId : String = ""

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        tblDetails.registerCell(type: HomeMediaTVC.self)
        tblDetails.registerCell(type: HomeCommentsMainTVC.self)
        tblDetails.registerCell(type: LoadingTVC.self)
        tblDetails.setDefaultProperties(self)
        
        commentInId = postID
        viewReplay.isHidden = true
        if self.postObj == nil {
            self.WSGetPostDetails()
        }
        WSGetCommentList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClicks(_ sender: Any) {
        
        if txtComment.text.removeWhiteSpace().isEmpty {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: "Please enter comment".localized)
            return
        }
        
        if shouldSendMsg {
            shouldSendMsg = false
            WSPostComment()
        }
    }

    @IBAction func btnCancelReplayClicks(_ sender: Any) {
        self.viewReplay.isHidden = true
        self.commentInId = postID
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension PostDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hasMoreData {
            return 3
        }else {
            return 2
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            return arrComments.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMediaTVC") as? HomeMediaTVC {
                
                if let obj = self.postObj {
                    
                    cell.bindData(obj: obj)
                    cell.btnMore.isHidden = true
                    
                    cell.likedUnliked = { total , isliked in
                        self.postObj?.like = total
                        self.postObj?.isLiked = isliked

                        tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .none)
                        tableView.endUpdates()
                    }
                    cell.followCloser = { isFollow in
                        self.postObj?.isFollowing = isFollow ? 1 : 0
                    }
                }
                
                    return cell
                }
                
            }else  if indexPath.section == 1 {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCommentsMainTVC") as? HomeCommentsMainTVC {
                    cell.cellContentView.layer.cornerRadius = 10.0
                    cell.cellContentView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.cellContentView.layer.borderWidth = 0.02
                if arrComments.count > indexPath.row {
                    
                    let obj = arrComments[indexPath.row]
                    cell.bindData(obj: obj)
                    cell.layoutIfNeeded()

                    cell.btnCommentCloser = {
                        self.commentInId = obj.id.description
                        self.viewReplay.isHidden = false
                        self.lblReplayingTo.text = "Replying to ".localized + (obj.user?.name ?? "")
                    }
                    
                    cell.likedUnliked = { total in
                        self.arrComments[indexPath.row].likes = total
                        self.arrComments[indexPath.row].liked = !self.arrComments[indexPath.row].liked
                        
                        tableView.beginUpdates()
                        tableView.reloadRows(at: [indexPath], with: .none)
                        tableView.endUpdates()
                    }
                    
                    cell.hideShowCloser = {
                        self.hideShowComment(indexPath: indexPath)
                    }
                    
                    cell.layoutIfNeeded()
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
        if indexPath.section == 1 {
            hideShowComment(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("display value")
    }

    
    func hideShowComment(indexPath : IndexPath) {
        let objects = arrComments[indexPath.row]
        objects.isShowSubComments = !objects.isShowSubComments
        arrComments[indexPath.row] = objects
        
        tblDetails.beginUpdates()
        tblDetails.reloadRows(at: [indexPath], with: .none)
        tblDetails.endUpdates()
    }
}


//MARK: - Pagination
extension PostDetailsVC {
    //Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tblDetails {
            if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height - 350 {
                
                if !isDataLoading {
                    isDataLoading = true
                    
                    if self.hasMoreData {
                        self.WSGetCommentList(isShowLoader: false)
                    }
                }
            }
        }
    }
    
}

//MARK: - WEBService CAll
extension PostDetailsVC {
    
    func WSGetPostDetails(isShowLoader : Bool = true) {
        ServiceManager.shared.getRequest(ApiURL: .postDetails, strAddInURL: self.postID, parameters: [:], isShowLoader: true) { response, isSuccess, error, statusCode in
            
            self.postObj = ModelPostsMain(fromJson: response["data"])
            self.tblDetails.reloadSections(IndexSet(integer: 0), with: .fade)
            self.didCommentHandler?()
            
        } Failure: { response, isSuccess, error, statusCode in
            //fail
        }
    }
    
    
    //to get search results
    func WSGetCommentList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "limit" : self.limit,
            "offset" : self.offset,
            "post_id" : postID
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .commentList, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            if self.offset == 0 {
                self.arrComments.removeAll()
            }
            
            if Success == true{
                
                let dataObj = response["data"]
                
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    self.arrComments.append(ModelCommentsMain(fromJson: obj))
                }
                
                self.offset = self.arrComments.count
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                
                self.tblDetails.reloadData()
                if self.arrComments.count > 4 {
                    self.tblDetails.scrollToBottom()
                }
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.isDataLoading = false
            self.hasMoreData = false
            self.tblDetails.reloadData()
        }
    }
    
    
    //to get search results
    func WSPostComment(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "id" : commentInId,
            "comment" : txtComment.text!
        ]
        
        var url : ApiURL = .commentCreate
        if !self.viewReplay.isHidden {
            url = .subCommentCreate
        }
        
        ServiceManager.shared.postRequest(ApiURL: url, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
                        
            if Success == true{
                self.WSGetPostDetails()
                self.arrComments = response["data"]["comments_list"].arrayValue.map({ModelCommentsMain(fromJson: $0)})
                self.tblDetails.reloadData()
                self.txtComment.text = ""
                self.viewReplay.isHidden = true
                self.commentInId = self.postID
                self.tblDetails.scrollToBottom()
            }
            self.shouldSendMsg = true
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.tblDetails.reloadData()
            self.shouldSendMsg = true
        }
    }

}


extension UITableView {

    func scrollToBottom(isAnimated:Bool = true){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }

    func scrollToTop(isAnimated:Bool = true) {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
