import UIKit
import AVKit
import AVFoundation

typealias anyActionAlias = ((_ sender : Any) -> Void)
typealias buttonActionAlias = ((_ sender: UIButton) -> Void)
typealias controlActionAlias = ((_ sender: UIControl) -> Void)
typealias voidCloser = (() -> Void)
typealias intCloser = ((Int) -> Void)
typealias stringCloser = ((String) -> Void)
typealias boolCloser = ((Bool) -> Void)

private let _sharedInstance = CommonClass()

class CommonClass: NSObject {
    
    //MARK: - Shared Instance
    static let sharedInstance : CommonClass = {
        let instance = CommonClass()
        return instance
    }()
    
    func showAlertWithTitleFromVC(vc:UIViewController, andMessage message:String)
    {
        showAlertWithTitleFromVC(vc: vc, title: Constant.APP_NAME, andMessage: message, buttons: ["Okay".localized]) { (index) in
        }
    }
    
    func showLogoutAlertWithTitleFromVC(vc:UIViewController, title:String, andMessage message:String, buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
        
        var newMessage = message
        if newMessage == "The Internet connection appears to be offline.".localized {
            newMessage = LocalValidation.internetNotConnected
        }
        
        GeneralUtility().addErrorHaptic()
        let alertController = UIAlertController(title: title, message: newMessage, preferredStyle: .alert)
        for index in 0..<buttons.count    {
            
            let action = UIAlertAction(title: buttons[index], style: .destructive, handler: {
                (alert: UIAlertAction!) in
                if(completion != nil){
                    completion(index)
                }
            })
            
            alertController.addAction(action)
        }
        vc.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithTitleFromVC(vc:UIViewController, title:String, andMessage message:String, buttons:[String], completion:((_ index:Int) -> Void)!) -> Void {
        
        var newMessage = message
        if newMessage == "The Internet connection appears to be offline.".localized {
            newMessage = LocalValidation.internetNotConnected
        }
        GeneralUtility().addErrorHaptic()
        
        let alertController = UIAlertController(title: title, message: newMessage, preferredStyle: .alert)
        for index in 0..<buttons.count    {
            
            let action = UIAlertAction(title: buttons[index], style: .default, handler: {
                (alert: UIAlertAction!) in
                if(completion != nil){
                    completion(index)
                }
            })
            
            alertController.addAction(action)
        }
        vc.present(alertController, animated: true, completion: nil)
    }
    
}

func errorMessage(message:String)
{
    CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: UIApplication.topViewController()! , andMessage: message)
    
}

func dynamicFontSize(_ FontSize: CGFloat) -> CGFloat {
    let screenWidth = UIScreen.main.bounds.size.width
    let calculatedFontSize = screenWidth / 375 * FontSize
    return calculatedFontSize
}

//MARK: - VALID EMAIL CHECK

func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    let result = emailTest.evaluate(with: testStr)
    return result
}

//MARK: - TABLEVIEW EXTENSIONS


//MARK: - TEXTFIELD
class PaddingTextField: UITextField {
    
    @IBInspectable var paddingLeft: CGFloat = 0
    @IBInspectable var paddingRight: CGFloat = 0
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + paddingLeft, y: bounds.origin.y,
                      width: bounds.size.width - paddingLeft - paddingRight, height: bounds.size.height);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }}


//MARK: - VIBRATE

enum Vibration {
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    @available(iOS 13.0, *)
    case soft
    @available(iOS 13.0, *)
    case rigid
    case selection
    case oldSchool
    
    public func vibrate() {
        switch self {
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .soft:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        case .rigid:
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .oldSchool:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}
