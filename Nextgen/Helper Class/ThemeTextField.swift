//
//  ThemeTextField.swift
//  Nextgen
//
//  Created by Zain Anjum on 18/07/2023.
//

import UIKit

class ThemeTextField: UITextField {
    override func awakeFromNib() {
        layer.cornerRadius = 10
//        layer.borderWidth = 0.1
        
//        if overrideUserInterfaceStyle == .dark {
//            backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
//            
//        }else {
//            backgroundColor = #colorLiteral(red: 0.9750029445, green: 0.9782454371, blue: 0.9813424945, alpha: 1)
//        }
//        
        
//        backgroundColor = UIColor.secondaryLabel.withAlphaComponent(0.5)
    }
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)

       override open func textRect(forBounds bounds: CGRect) -> CGRect {
           return bounds.inset(by: padding)
       }

       override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
           return bounds.inset(by: padding)
       }

       override open func editingRect(forBounds bounds: CGRect) -> CGRect {
           return bounds.inset(by: padding)
       }
}
