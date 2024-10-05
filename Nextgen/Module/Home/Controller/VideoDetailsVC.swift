//
//  VideoDetailsVC.swift
//  Nextgen
//
//  Created by Jacky Patel on 22/12/22.
//

import UIKit
import Foundation
import AVKit
import GSPlayer

enum videoDetailType {
    case profileVideos
    case likedVideos
    case search
    case searchResult
    case videoDetails
    case otherUserVideos
}

class VideoDetailsVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var tblVideos: UITableView!
    
    //MARK: - VARIABLES
    var arrCategoryVideos : [ModelVideoListMain] = []
    let refreshControl = UIRefreshControl()
    var selectedVideoID : Int?
    
    var isDataLoading : Bool = true
    var limit : Int = 10
    var offset : Int = 0
    var hasMoreData : Bool = false

    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblVideos.registerCell(type: HomeVideosTVC.self)
        tblVideos.registerCell(type: LoadingTVC.self)
        tblVideos.setDefaultProperties(self)
        
        tblVideos.sectionHeaderHeight = 0
        tblVideos.sectionFooterHeight = 0
        tblVideos.remembersLastFocusedIndexPath = true

        if #available(iOS 15.0, *) {
            tblVideos.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }

        setInitialData()
        navigationController?.navigationBar.isHidden = true
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...", attributes: [.foregroundColor : UIColor.white])
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .white
        tblVideos.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        check()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        checkPause()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        setInitialData(isShowLoader: false)
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnBackClicks(_ sender: Any) {
        channelName = ""
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func becomeLiveBtn(_ sender:UIButton){
        
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        channelName = "TopMedia-\(currentTimestamp)"
        
        let parameter : [String : Any] =
        [
            "channel_name" : channelName,
            "uid" : NextgenUser.shared.id,
            "type" : "broadcaster"
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .getAgoraToken, parameters: parameter, Success: { (response, Success, message, statusCode) in
            
            let responseDcit = response.dictionaryValue
            if let token = responseDcit["data"]?.stringValue, token.count > 0 {
                print("Agora Token: ====", token)
                let vc = BecomeLiveViewController.instantiate(appStoryboard: .Home) as! BecomeLiveViewController
                vc.modalPresentationStyle = .fullScreen
                vc.agoraSDKToken = token
                vc.joinerType = "broadcaster"
                self.present(vc, animated: true)
            }else{
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: responseDcit["message"]?.stringValue ?? "")
            }
           
            
        }, Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
        })
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension VideoDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if hasMoreData {
            return 2
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return VideoDataSource.sharedInstance.videos.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if VideoDataSource.sharedInstance.videos.count > indexPath.row {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeVideosTVC") as? HomeVideosTVC {
                    
                    let video = VideoDataSource.sharedInstance.videos[indexPath.row]
    
                    if let url = URL(string: video.file) {
                        cell.set(url: url)
                    }
                    
                    cell.currentCellIndex = indexPath.row
                    cell.bindData(obj: video)
                    return cell
                }
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTVC") as? LoadingTVC{
                cell.startLoading()
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblVideos.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblVideos.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
        }
    }
}

extension VideoDetailsVC {

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? HomeVideosTVC {
            cell.pause()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { check() }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        check()
    }
    
    func check() {
        checkPreload()
        checkPlay()
    }
    
    func checkPreload() {
        guard let lastRow = tblVideos.indexPathsForVisibleRows?.last?.row else { return }
        
        let urls = VideoDataSource.sharedInstance.videos
            .suffix(from: min(lastRow + 1, VideoDataSource.sharedInstance.videos.count))
            .prefix(3)
        
        var finalURLs: [URL] = []
        for video in urls {
            finalURLs.append(URL(string: video.file)!)
        }
        
        VideoPreloadManager.shared.set(waiting: Array(finalURLs))
    }
    
    func checkPlay() {
        let visibleCells = tblVideos.visibleCells.compactMap { $0 as? HomeVideosTVC }
        
        guard visibleCells.count > 0 else { return }
        let visibleFrame = CGRect(x: 0, y: tblVideos.contentOffset.y, width: tblVideos.bounds.width, height: tblVideos.bounds.height)
        let visibleCell = visibleCells
            .filter { visibleFrame.intersection($0.frame).height >= $0.frame.height / 2 }
            .first
        
        visibleCell?.play()
    }
    
    func checkPause() {
        let visibleCells = tblVideos.visibleCells.compactMap { $0 as? HomeVideosTVC }
        
        guard visibleCells.count > 0 else { return }
        
        let visibleFrame = CGRect(x: 0, y: tblVideos.contentOffset.y, width: tblVideos.bounds.width, height: tblVideos.bounds.height)

        let visibleCell = visibleCells
            .filter { visibleFrame.intersection($0.frame).height >= $0.frame.height / 2 }
            .first
        
        visibleCell?.pause()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tblVideos {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if scrollView.contentOffset.y >= scrollView.contentSize.height - (scrollView.frame.size.height * 4) {
                    if !self.isDataLoading {
                        self.isDataLoading = true
                        
                        if self.hasMoreData {
                            self.getVideoList(isShowLoader: false)
                        }
                    }
                }
            }
        }
    }
}

//MARK: - APIs call
extension VideoDetailsVC {
    
    private func getVideoList(isShowLoader : Bool = true) {
        
        let parameter : [String : Any] =
        [
            "limit" : self.limit,
            "offset" : self.offset,
        ]
        
        ServiceManager.shared.postRequest(ApiURL: .getVideoList, parameters: parameter , isShowLoader : isShowLoader) { (response, Success, message, statusCode) in
            
            self.refreshControl.endRefreshing()
            if self.offset == 0 {
                VideoDataSource.sharedInstance.videos.removeAll()
            }
            
            if Success == true{
                
                let dataObj = response["data"]
                
                let arr = dataObj.arrayValue
                
                arr.forEach { (obj) in
                    VideoDataSource.sharedInstance.videos.append(ModelVideoListMain(fromJson: obj))
                }
                
                self.offset = VideoDataSource.sharedInstance.videos.count
                self.hasMoreData = !(arr.count < self.limit)
                self.isDataLoading = false
                
                self.bindData()
            }
            
            print("Success Response:",response)
        } Failure: { (response, Success, message, statusCode) in
            print("Failure Response:",response)
            self.bindData()
        }
    }
    
}

//MARK: - GENERAL FUNCTION
extension VideoDetailsVC {
    
    func setInitialData(isShowLoader : Bool = true) {
        VideoDataSource.sharedInstance.videos.removeAll()
        self.getVideoList()
    }
    
    private func bindData() {
        self.isDataLoading = false
        self.refreshControl.endRefreshing()
        DispatchQueue.main.async {
            self.tblVideos.reloadData()
            if let indx = VideoDataSource.sharedInstance.videos.firstIndex(where: {$0.id == self.selectedVideoID}) {
                print("SCROLLING AT", indx)
                self.tblVideos.beginUpdates()
                self.tblVideos.scrollToRow(at: IndexPath(row: indx, section: 0), at: .middle, animated: false)
                self.tblVideos.endUpdates()
            }
            self.check()
        }
        self.tblVideos.isScrollEnabled = true
    }
}
