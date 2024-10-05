//
//  ToastView.swift
//  Nextgen
//
//  Created by Zain Anjum on 16/07/2023.
//

import UIKit

class ToastView: UIView {


    class ToastView: UIView {
        
        let imageView: UIImageView = {
            let img = UIImageView()
            img.contentMode = .scaleAspectFit
            return img
        }()
        
        let messageLabel: UILabel = {
            let label = UILabel()
            label.font = .font(textStyle: .semiBold, size: 10)
            label.numberOfLines = 0
            return label
        }()
        
        
        override func awakeFromNib() {
            setupViews()
        }
        
        func setupViews() {
            layer.cornerRadius = 20
            addSubview(imageView)
            addSubview(messageLabel)
            addConstraintsWithFormat(format: "H:|-16-[v0(14)]-10-[v1]|", views: imageView,messageLabel)
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        func setupToast(type: ToastType, message: String) {
            switch type {
            case .error:
                imageView.image = UIImage(named: "ico_info")?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = .themeRed
            messageLabel.textColor = .themeRed
                backgroundColor = .themeLightRed
            case .warning:
                imageView.image = UIImage(named: "ico_info")?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = .themePeach
                messageLabel.textColor = .themePeach
                backgroundColor = .themeBGPeach
            case .success:
                imageView.image = UIImage(named: "ico_tick")
    //            imageView.tintColor = .themeGreen
                messageLabel.textColor = .themeGreen
                backgroundColor = .themeLightGreen
            }
            messageLabel.text = message
        }
        
    }
    enum ToastType {
        case error
        case warning
        case success
        
    }

}
