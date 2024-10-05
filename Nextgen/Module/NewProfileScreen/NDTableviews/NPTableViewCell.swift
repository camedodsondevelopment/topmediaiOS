//
//  NPTableViewCell.swift
//  Nextgen
//
//  Created by Muhammad Rizwan on 29/01/2024.
//

import UIKit

class NPTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomView:UIView!
    @IBOutlet weak var followersCount:UILabel!
    @IBOutlet weak var followingCount:UILabel!
    @IBOutlet weak var followersLbl:UILabel!
    @IBOutlet weak var followingLbl:UILabel!
    @IBOutlet weak var musicBtn:UIButton!
    @IBOutlet weak var postsBtn:UIButton!
    @IBOutlet weak var likesBtn:UIButton!
    @IBOutlet weak var mediaBtn:UIButton!


    var closur:((String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUI()
    }
    
    func setUI(){
    
    }
    
    func bindValues(followers:String, following:String, selectedSegment:Int, isMusicPlaying:Bool){
        followersCount.text = followers
        followingCount.text = following
        followersLbl.text = "Followers".localized
        followingLbl.text = "Following".localized
        postsBtn.borderColor = UIColor(named: "DarkestYellow") ?? .white
        likesBtn.borderColor = UIColor(named: "DarkestYellow") ?? .white
        mediaBtn.borderColor = UIColor(named: "DarkestYellow") ?? .white
        

        
        if isMusicPlaying {
            musicBtn.setTitle("Pause Music", for: .normal)
        }else{
            musicBtn.setTitle("Play Music", for: .normal)
        }
        
        
        if selectedSegment == 1 {
            likesBtn.backgroundColor = UIColor(named: "DarkestYellow")

            postsBtn.backgroundColor = .clear
            mediaBtn.backgroundColor = .clear
            
            postsBtn.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
            mediaBtn.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
            likesBtn.setTitleColor(UIColor(named: "tabbarSelected") ?? .black, for: .normal)

        }else if selectedSegment == 2 {
            postsBtn.backgroundColor = .clear
            likesBtn.backgroundColor = .clear
            mediaBtn.backgroundColor = UIColor(named: "DarkestYellow")
            postsBtn.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
            mediaBtn.setTitleColor(UIColor(named: "tabbarSelected") ?? .black, for: .normal)
            likesBtn.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
        }else{
            postsBtn.backgroundColor = UIColor(named: "DarkestYellow")
            likesBtn.backgroundColor = .clear
            mediaBtn.backgroundColor = .clear
            postsBtn.setTitleColor(UIColor(named: "tabbarSelected") ?? .black, for: .normal)
            mediaBtn.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
            likesBtn.setTitleColor(UIColor(named: "DarkestYellow") ?? .white, for: .normal)
        }
    }
    
    @IBAction func followerBtnPressed(_ sender:UIButton){
        closur?("Followers")
    }
    
    @IBAction func followingBtnPressed(_ sender:UIButton){
        closur?("Followings")
    }
    
    @IBAction func musicBtnPressed(_ sender:UIButton){
        if sender.titleLabel?.text == "Pause Music" {
            musicBtn.setTitle("Play Music", for: .normal)
        }else{
            musicBtn.setTitle("Pause Music", for: .normal)
        }
        
        closur?(musicBtn.titleLabel?.text ?? "")
    }
    
    @IBAction func postsBtnPressed(_ sender:UIButton){
        closur?("Posts")
    }
    
    @IBAction func likesBtnPressed(_ sender:UIButton){
        closur?("Likes")
    }
    
    @IBAction func mediaBtnPressed(_ sender:UIButton){
        closur?("Media")
    }
    
}
