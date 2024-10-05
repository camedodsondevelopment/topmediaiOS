//
//  TableViewExts.swift
//  ZainFramework
//
//  Created by ZainAnjum on 06/05/2019.
//

import UIKit
public extension UITableView {
    @available(iOS 10.0, *)
    func beginRefreshing() {

        guard let refreshControl = refreshControl, !refreshControl.isRefreshing else {
            return
        }
        // Start the refresh animation
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged) 
        let top: CGFloat 
              if #available(iOS 11.0, *) {
                 top  = self.adjustedContentInset.top
              } else {
                  top = 160
              }
            let y = self.refreshControl!.frame.maxY + top
        self.setContentOffset(CGPoint(x: 0, y: -y), animated:true) 
    }
    @available(iOS 10.0, *)
    func endRefreshing() {
        refreshControl?.endRefreshing()
    }
    
    func setEmptyMessageZain(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        if #available(iOS 13.0, *) {
            messageLabel.textColor = .label
        } else {
            messageLabel.textColor = .black
        }
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restoreZain() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
public struct Chapter: Decodable {
    let name: String
}
//Searcing extention
public extension Array where Element == Chapter{
    func matching(_ text: String?) -> [Chapter] {
        if let text = text, text.count > 0{
            return self.filter{
                $0.name.lowercased().contains(text.lowercased())
            }
        }else{
            return self
        }
    }
}
