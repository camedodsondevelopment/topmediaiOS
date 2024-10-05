//
//  FollowersFollowingVC.swift
//  Nextgen
//
//  Created by Zain Anjum on 22/07/2023.
//

import UIKit

class FollowersFollowingVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
   
    let viewModel = FollowersFollowingViewModel()
    @IBOutlet var personDetail: UILabel!
    @IBOutlet var personName: UILabel!
    @IBOutlet var profileImg: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var FollowersFollowingSegmentControl: UISegmentedControl!
  
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func btnBackClicks(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func segmentTap(_ sender: Any) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch FollowersFollowingSegmentControl.selectedSegmentIndex{
        case 0:
            return viewModel.FollowersDetails.count
        case 1:
            return viewModel.FollowingDetail.count
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! FollowersFollowingTableViewCell
        let detailedData = viewModel
        switch FollowersFollowingSegmentControl.selectedSegmentIndex{
        case 0:
            cell.personUsername.text = detailedData.FollowersDetails[indexPath.row].usename
            cell.personRemove.text = detailedData.FollowersDetails[indexPath.row].removeperson
        case 1:
            let data = detailedData.FollowingDetail[indexPath.row]
            print(data.usename, data.unfollowperson, data.personImg)
            
            cell.personUsername.text = detailedData.FollowingDetail[indexPath.row].usename
            cell.personRemove.text = detailedData.FollowingDetail[indexPath.row].unfollowperson
            cell.personImg.image = UIImage(named: detailedData.FollowingDetail[indexPath.row].personImg)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

