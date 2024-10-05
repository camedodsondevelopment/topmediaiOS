//
//  ThemeTextField.swift
//  Nextgen
//
//  Created by Zain Anjum on 16/07/2023.
//

import UIKit

class ThemeTextField: UITextField {


    class ThemeTextField: UITextField {
        
        var padding = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        
        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        
        func updatePadding(_ newPadding: CGFloat) {
            padding = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: newPadding)
        }
        var isBordered = false
        @IBInspectable
        var borded: Bool {
            get {
                return false
            }
            set {
                isBordered = newValue
            }
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            if isBordered {
                layer.borderWidth = 1
                layer.borderColor = UIColor.black.withAlphaComponent(0.16).cgColor
            } else {
                layer.borderWidth = 0
            }
            textColor = .black
            font = .font(textStyle: .regular, size: 12)
            layer.cornerRadius = 22
            clipsToBounds = true
        }
        
        let eyeButton = UIButton()
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 14, height: 14))
        
        func setupAccessoryImageAndEyeButton(isTick: Bool, isEye: Bool) {
            // Create the stack view
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .center
            
            // Create the eye button
            
            eyeButton.setImage(UIImage(named: "ico_view_pass"), for: .normal)
            eyeButton.addAction(for: .touchUpInside) { [unowned self] in
                isSecureTextEntry = !isSecureTextEntry
            }
            // Add any custom configuration or target-action for the button as needed
            
            // Create the image view
            
            let image = UIImage(named: "ico_tick")
            imageView.image = image
            
            // Add the eye button and image view to the stack view
            stackView.addArrangedSubview(eyeButton)
            stackView.addArrangedSubview(imageView)
            
            eyeButton.isHidden = !isEye
            imageView.isHidden = !isTick
            // Set the stack view as the rightView of the text field
            //        rightView = stackView
            addSubview(stackView)
            stackView.bringSubviewToFront(eyeButton)
            addConstraintsWithFormat(format: "H:[v0]-16-|", views: stackView)
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            if isTick && isEye {
                updatePadding(70)
            } else {
                updatePadding(40)
            }
        }
        
        func unHideTickImage() {
            imageView.isHidden = false
            updatePadding(70)
        }
        
        func hideTickImage() {
            imageView.isHidden = true
            updatePadding(40)
        }
        
        func inValid() {
            layer.borderWidth = 1
            layer.borderColor = UIColor.themeRed.cgColor
            backgroundColor = .themeLightRed
            textColor = .red
        }
        
        func isWeak() {
            layer.borderWidth = 0
            backgroundColor = .themeBGPeach
            textColor = .themePeach
        }
        
        func valid() {
            if isBordered {
                layer.borderWidth = 1
                layer.borderColor = UIColor.black.withAlphaComponent(0.16).cgColor
            } else {
                layer.borderWidth = 0
            }
            backgroundColor = .white
            textColor = .black
        }
        
    }

    extension UIControl {
        func addAction(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping()->()) {
            @objc class ClosureSleeve: NSObject {
                let closure:()->()
                init(_ closure: @escaping()->()) { self.closure = closure }
                @objc func invoke() { closure() }
            }
            let sleeve = ClosureSleeve(closure)
            addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
            objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

}
