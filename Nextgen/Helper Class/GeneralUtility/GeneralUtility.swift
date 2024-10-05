//
//  GeneralUtility.swift
//  MotoTP Customer
//
//  Created by Himanshu Visroliya on 15/11/21.
//

import UIKit
import AVFoundation
import MobileCoreServices
import SDWebImage
import Haptico

extension UIDevice {
    var hasNotch: Bool {
        
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            return bottom > 0
            
        } else {
            return false
        }
    }
}

class GeneralUtility: NSObject {
    
    // MARK: - Shared Instance
    static let sharedInstance : GeneralUtility = {
        let instance = GeneralUtility()
        return instance
    }()
    
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    func setStatusBar(view:UIView, mode:String) {
        if #available(iOS 13, *)
        {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            let height = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            let statusBar = UIView(frame: (keyWindow?.windowScene?.statusBarManager?.statusBarFrame) ?? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
            statusBar.backgroundColor = mode == "light" ? .white : .black
            keyWindow?.addSubview(statusBar)
        } else {
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
                statusBar.backgroundColor = mode == "light" ? .white : .black
            }
            UIApplication.shared.statusBarStyle = mode == "light" ? .lightContent : .default
        }
    }
    
    func getCommonHeaderHeight() -> CGFloat {
        if UIDevice.current.hasNotch {
            return 140
        }
        return 114
    }
    
    func buttonShadowWithApp(btnSubmit: UIButton) {
        btnSubmit.layer.shadowColor = UIColor.AppColor.cgColor
        btnSubmit.layer.shadowOpacity = 0.28
        btnSubmit.layer.shadowOffset = .zero
        btnSubmit.layer.shadowRadius = 6
        let pathh = UIBezierPath(roundedRect: CGRect(x: 26, y: 26, width: btnSubmit.frame.width * 0.8, height: 52), cornerRadius: 58)
        
        btnSubmit.layer.shadowPath = pathh.cgPath
        btnSubmit.layer.cornerRadius = 12
    }
    
    func localToUTC(date:String, fromFormat: String, toFormat: String, withUTC: Bool = false) -> String {
        
        let dateFormatter = DateFormatter()
        if withUTC {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        dateFormatter.dateFormat = fromFormat
        let dt = dateFormatter.date(from: date)
        dateFormatter.dateFormat = toFormat
        
        return dateFormatter.string(from: dt!)
    }
    
    func getCommonHeaderHeightWithuotCornerRadius() -> CGFloat {
        if UIDevice.current.hasNotch {
            return 110
        }
        return 80
    }
    
    func animateTableview(tableview: UITableView, subtype : CATransitionSubtype? ) {
        let transition = CATransition()
        transition.type = CATransitionType.push
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.fillMode = CAMediaTimingFillMode.forwards
        transition.duration = 0.5
        transition.subtype = subtype
        tableview.layer.add(transition, forKey: "UITableViewReloadDataAnimationKey")
        tableview.reloadData()
    }
    
    func addButtonTapHaptic() {
        Haptico.shared().generate(.light)
    }
    
    func addErrorHaptic() {
        Haptico.shared().generate(.error)
    }
    
    func addSuccessHaptic() {
        Haptico.shared().generate(.success)
    }
    
    func addWarningHaptic() {
        Haptico.shared().generate(.warning)
    }
    
    class func createActivityIndi() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        spinner.color = .black
        spinner.hidesWhenStopped = true
        return spinner
    }
    
    func setImageWithSDWEBImage(imgView: UIImageView?, placeHolderImage: UIImage?, imgPath: String, isWithoutFade: Bool = false) {
        UIView.performWithoutAnimation {
            let imageNew = imgPath
            if let _ = URL(string: imageNew), let imgView = imgView {
                DispatchQueue.main.async {
                    var thumbnailSize = imgView.frame.size
                    thumbnailSize.width *= UIScreen.main.scale
                    thumbnailSize.height *= UIScreen.main.scale
                    SDImageCoderHelper.defaultScaleDownLimitBytes = UInt(imgView.frame.size.width * imgView.frame.size.height * 4)
                    let optins: SDWebImageOptions = [.retryFailed]
                    if isWithoutFade == false {
                        imgView.sd_imageTransition = .fade
                    }
                    imgView.sd_setImage(with: URL(string: imgPath), placeholderImage: placeHolderImage, options: optins, context: [.imageThumbnailPixelSize : thumbnailSize])
                }
                
            } else {
                DispatchQueue.main.async {
                    imgView?.sd_imageTransition = .none
                    imgView?.image = placeHolderImage
                }
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    //MARK:- ERROR MESSAGE
    
    func showErrorMessage(message: String) {
        
        var viewcontroller = UIApplication.topViewController()
        if ((viewcontroller as? LoadingDailog) != nil) {
            viewcontroller = UIApplication.topViewController()?.presentingViewController
        }
        CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: viewcontroller!, andMessage: message)
    }
    
    func showSuccessMessage(message: String) {
        
        var viewcontroller = UIApplication.topViewController()
        if ((viewcontroller as? LoadingDailog) != nil) {
            viewcontroller = UIApplication.topViewController()?.presentingViewController
        }
        CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: viewcontroller!, andMessage: message)
    }
    
    class func getPath(fileName: String) -> String {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
    }
    
    class func copyFile(fileName: NSString) {
        let dbPath: String = getPath(fileName: fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
//            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
                print("path : \(dbPath)")
            } catch _ as NSError {
//                error = error1
            }
        }
    }
    
    func createImageFromString(text: String, size: CGFloat = 16) -> UIImage {
        let attributes : [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.AppColor,
            NSAttributedString.Key.font:  Font(.installed(.TitilliumRegular), size: .custom(size)).instance
        ]
        
        
        let textSize = text.size(withAttributes: attributes)
        
        let renderer = UIGraphicsImageRenderer(size: textSize)
        let image = renderer.image(actions: { context in
            text.draw(with: .zero, options: [.usesLineFragmentOrigin], attributes: attributes, context: nil)
        })
        
        return image
    }
}

func setView(view: UIView, hidden: Bool) {
    UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
        view.isHidden = hidden
    })
}


//MARK: - NSDate Extention for UTC date
extension NSDate {
    func getStrCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.current
        //dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self as Date)
    }
}


func getDateFromString(date:String, fromFormate : String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'") -> Date {
    
    // NSLog("Str date :%@ ",date)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormate //"yyyy-MM-dd HH:mm:ss"
    //dateFormatter.timeZone = TimeZone.current
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let dt = dateFormatter.date(from: date)
    return dt ?? Date()
}


func getStrDateFromDate(date:Date , formate : String = "dd MMM hh:mm a" ) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = formate
    dateFormatter.locale = Locale.current
    let dt = dateFormatter.string(from: date)
    return dt
}


func getStrDateFromDate(date: String ,fromFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", toFormat: String = "dd-MMM-yyyy hh:mm a") -> (String) {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormat
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    let dt = dateFormatter.date(from: date) ?? Date()
    
    dateFormatter.dateFormat = toFormat
    let date = dateFormatter.string(from: dt)
    
    return date
}

enum StoryBoardsCases {
    
    case LoginRegister
    case TrackingRide
    
    func storyBoard() -> UIStoryboard {
        var storyB: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        switch self {
        case .LoginRegister :
            storyB = UIStoryboard(name: "Main", bundle: Bundle.main)
        case .TrackingRide :
            storyB = UIStoryboard(name: "TrackingRide", bundle: Bundle.main)
        }
        
        return storyB
    }
}

extension UIImageView{
    func downloadImage(url:String){
      //remove space if a url contains.
        let stringWithoutWhitespace = url.replacingOccurrences(of: " ", with: "%20", options: .regularExpression)
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_setImage(with: URL(string: stringWithoutWhitespace), placeholderImage: UIImage(named: "profile-user"))
    }
}

// MARK: - Device Type
enum UIUserInterfaceIdiom: Int {
    case Unspecified
    case Phone
    case Pad
}

struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6PLUS      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPHONE_XS_MAX     = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 896.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

// MARK: - Screen Size
struct ScreenSize {
    static let WIDTH         = UIScreen.main.bounds.size.width
    static let HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.WIDTH, ScreenSize.HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.WIDTH, ScreenSize.HEIGHT)
}

// MARK: - Hex to UIcolor
func hexStringToUIColor (hex:String) -> UIColor {
    
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}


//MARK: - UIApplication Extension
extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}

//MARK: - check string nil
func createString(value: AnyObject) -> String
{
    var returnString: String = ""
    if let str: String = value as? String
    {
        returnString = str
    }
    else if let str: Int = value as? Int
    {
        returnString = String.init(format: "%d", str)
    }
    
    else if let _: NSNull = value as? NSNull
    {
        returnString = String.init(format: "")
    }
    return returnString
}

//MARK: - check string nil
func createFloatToString(value: AnyObject) -> String
{
    var returnString: String = ""
    if let str: String = value as? String
    {
        returnString = str
    }
    else if let str: Float = value as? Float
    {
        returnString = String.init(format: "%.2f", str)
    }
    else if let _: NSNull = value as? NSNull
    {
        returnString = String.init(format: "")
    }
    return returnString
}

func createDoubleToString(value: AnyObject) -> String
{
    var returnString: String = ""
    if let str: String = value as? String
    {
        returnString = str
    }
    else if let str: Float = value as? Float
    {
        returnString = String.init(format: "%.1f", str)
    }
    else if let _: NSNull = value as? NSNull
    {
        returnString = String.init(format: "")
    }
    return returnString
}

//MARK: - check string nil
func createIntToString(value: AnyObject) -> String
{
    var returnString: String = ""
    if let str: String = value as? String
    {
        returnString = str
    }
    else if let str: Int = value as? Int
    {
        returnString = String.init(format: "%d", str)
    }
    else if let _: NSNull = value as? NSNull
    {
        returnString = String.init(format: "")
    }
    return returnString
}

func createStringToint(value: AnyObject) -> Int
{
    var returnString: Int = 0
    
    if ( value as? String ?? "") == "" {
        returnString = 0
        
    } else {
        returnString = Int(value as? String ?? "")!
    }
    
    return returnString
}
func creatArray(value: AnyObject) -> NSMutableArray
{
    var tempArray = NSMutableArray()
    
    if let arrData: NSArray = value as? NSArray
    {
        tempArray = NSMutableArray.init(array: arrData)
    }
    else if let _: NSNull = value as? NSNull
    {
        tempArray = NSMutableArray.init()
    }
    
    return tempArray
}
class CircleControl: UIControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}
func creatDictnory(value: AnyObject) -> NSMutableDictionary
{
    var tempDict = NSMutableDictionary()
    
    if let DictData: NSDictionary = value as? NSDictionary
    {
        tempDict = NSMutableDictionary.init()
        tempDict.addEntries(from:DictData as? [AnyHashable : Any] ?? [:])
    }
    else if let _: NSNull = value as? NSNull
    {
        tempDict = NSMutableDictionary.init()
    }
    
    return tempDict
}

func localToUTC(dateStr: String,fromFomate : String , ToFormate : String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFomate
    dateFormatter.calendar = Calendar.current
    dateFormatter.timeZone = TimeZone.current
    
    if let date = dateFormatter.date(from: dateStr) {
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = ToFormate
        
        return dateFormatter.string(from: date)
    }
    return ""
}


func UTCToLocal(date:String,fromFomate : String , ToFormate : String) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFomate
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = ToFormate
    var str = ""
    if dt != nil
    {
        str = dateFormatter.string(from: dt!)
    }
    return str
}

//MARK: - Get Dictionary From Dictionary
func getDictionaryFromDictionary(dictionary:NSDictionary, key:String) -> NSDictionary {
    
    if let value = dictionary[key] as? NSDictionary {
        
        let string = NSString.init(format: "%@", value as CVarArg) as String
        if (string == "null" || string == "NULL" || string == "nil") {
            return NSDictionary()
        }
        return value
    }
    return NSDictionary()
}
//MARK: - Get Array From Dictionary
func getArrayFromDictionary(dictionary:NSDictionary, key:String) -> NSArray {
    
    if let value = dictionary[key] as? NSArray {
        
        let string = NSString.init(format: "%@", value as CVarArg) as String
        if (string == "null" || string == "NULL" || string == "nil") {
            return NSArray()
        }
        return value
    }
    return NSArray()
}

//MARK: - Get Array From Dictionary
func getDictionryArrayFromDictionary(dictionary:NSDictionary, key:String) -> [NSDictionary] {
    
    if let value = dictionary[key] as? [NSDictionary] {
        
        let string = NSString.init(format: "%@", value as CVarArg) as String
        if (string == "null" || string == "NULL" || string == "nil") {
            return [NSDictionary]()
        }
        return value
    }
    return [NSDictionary]()
}

//MARK: - Set Color Method
func setColor(r: Float, g: Float, b: Float, aplha: Float)-> UIColor {
    return UIColor(red: CGFloat(Float(r / 255.0)), green: CGFloat(Float(g / 255.0)) , blue: CGFloat(Float(b / 255.0)), alpha: CGFloat(aplha))
}
//MARK: - Color
struct Color
{
    static let textColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0)
    static let keyboardHeaderColor = UIColor(red: 27.0 / 255.0, green: 170.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
}

/// to set the colors of  strings
func changeTextColors(fullStr: String, str: String,color1:UIColor,color2:UIColor) -> NSAttributedString
{
    let AttributeString = NSMutableAttributedString(string: fullStr)
    let ran = (fullStr as NSString).range(of: fullStr)
    AttributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: color1, range:ran)
    let range = (fullStr as NSString).range(of: str)
    AttributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: color2 , range: range)
    return AttributeString
}


func addAttributesToCustomString(fullStr: String, str: String,attribute : [NSAttributedString.Key : Any]) -> NSAttributedString
{
    let AttributeString = NSMutableAttributedString(string: fullStr)
    let range = (fullStr as NSString).range(of: str)
    AttributeString.addAttributes(attribute, range: range)
    return AttributeString
}

class TextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension UITextField{
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


extension UIBezierPath {
    
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGFloat, topRightRadius: CGFloat, bottomLeftRadius: CGFloat, bottomRightRadius: CGFloat){
        
        self.init()
        
        let path = CGMutablePath()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        if topLeftRadius != 0 {
            path.move(to: CGPoint(x: topLeft.x + topLeftRadius, y: topLeft.y))
        } else {
            path.move(to: topLeft)
        }
        
        if topRightRadius != 0 {
            path.addLine(to: CGPoint(x: topRight.x - topRightRadius, y: topRight.y))
            path.addArc(tangent1End: topRight, tangent2End: CGPoint(x: topRight.x, y: topRight.y + topRightRadius), radius: topRightRadius)
        }
        else {
            path.addLine(to: topRight)
        }
        
        if bottomRightRadius != 0 {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - bottomRightRadius))
            path.addArc(tangent1End: bottomRight, tangent2End: CGPoint(x: bottomRight.x - bottomRightRadius, y: bottomRight.y), radius: bottomRightRadius)
        }
        else {
            path.addLine(to: bottomRight)
        }
        
        if bottomLeftRadius != 0 {
            path.addLine(to: CGPoint(x: bottomLeft.x + bottomLeftRadius, y: bottomLeft.y))
            path.addArc(tangent1End: bottomLeft, tangent2End: CGPoint(x: bottomLeft.x, y: bottomLeft.y - bottomLeftRadius), radius: bottomLeftRadius)
        }
        else {
            path.addLine(to: bottomLeft)
        }
        
        if topLeftRadius != 0 {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + topLeftRadius))
            path.addArc(tangent1End: topLeft, tangent2End: CGPoint(x: topLeft.x + topLeftRadius, y: topLeft.y), radius: topLeftRadius)
        }
        else {
            path.addLine(to: topLeft)
        }
        
        path.closeSubpath()
        cgPath = path
    }
}

//MARK: - UIView Extension

@IBDesignable
open class VariableCornerRadiusView: UIView  {
    
    private func applyRadiusMaskFor() {
        let path = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        //layer.mask = shape
        self.layer.insertSublayer(shape, at: 0)
        //shape.backgroundColor = UIColor.white.cgColor
        //layer.addSublayer(shape)
        
        //        self.addShadow()
        
    }
    
    @IBInspectable
    open var topLeftRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    open var topRightRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    open var bottomLeftRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable
    open var bottomRightRadius: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        applyRadiusMaskFor()
        //        add_shadow(demoView: self, height: 2)
    }
}

extension UIView {
    
    //MARK: - IBInspectable
    
    //Set Corner Radious
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                //                self.addShadow()
            }
        }
    }
    @IBInspectable var shadowButton: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow(shadowColor: hexStringToUIColor(hex: "1D1D1D1A").withAlphaComponent(0.1).cgColor, shadowOffset: CGSize(width: 0, height: 0), shadowOpacity: 1, shadowRadius: 9)
            }
        }
    }
    @IBInspectable var shadowHomeBottom: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow(shadowColor: hexStringToUIColor(hex: "000000").withAlphaComponent(0.05).cgColor, shadowOffset: CGSize(width: 0, height: 0), shadowOpacity: 1, shadowRadius: 6)
            }
        }
    }
    @IBInspectable var SmallShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadowSmall()
            }
        }
    }
    
    @IBInspectable var AppColorShadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.colorShadow()
            }
        }
    }
    
    //shadow changes =
    @IBInspectable var shadowForTextFields: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.clipsToBounds = false
                //layer.cornerRadius = 17.0
                layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.04).cgColor
                layer.shadowOpacity = 1
                layer.shadowRadius = 10
                layer.shadowOffset = CGSize(width: 0, height: 3)
            }
        }
    }
    
    func add_shadow(demoView : UIView,height : CGFloat){
        
        let radius: CGFloat = demoView.frame.width //change it to .height if you need spread for height
        let shadowPath = UIBezierPath(rect: CGRect(x: -1, y: -1, width: radius + 0.5 , height:height - 4.0))
        //Change 2.1 to amount of spread you need and for height replace the code for height
        
        demoView.layer.cornerRadius = 0.0
        demoView.layer.shadowColor = UIColor.darkGray.cgColor
        demoView.layer.shadowOffset = CGSize(width: 0.1, height: 0.2)  //Here you control x and y
        demoView.layer.shadowOpacity = 0.2
        demoView.layer.shadowRadius = 2.0 //Here your control your blur
        demoView.layer.masksToBounds =  false
        demoView.layer.shadowPath = shadowPath.cgPath
    }
    
    func addShadow(shadowColor: CGColor = UIColor.darkGray.cgColor,
                   shadowOffset: CGSize = CGSize.zero,
                   shadowOpacity: Float = 0.5,
                   shadowRadius: CGFloat = 16) {
        
        layer.cornerRadius = self.cornerRadius
        layer.shadowColor = hexStringToUIColor(hex: "A7A7A740").withAlphaComponent(0.25).cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addInnerAndBottom() {
        let vwShadow = UIImageView()
        self.superview?.addSubview(vwShadow)
        superview?.bringSubviewToFront(self)
        vwShadow.isUserInteractionEnabled = self.isUserInteractionEnabled
        
        vwShadow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vwShadow.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            vwShadow.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            vwShadow.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            vwShadow.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        ])
        
        vwShadow.cornerRadius = self.cornerRadius
        //vwShadow.backgroundColor = UIColor.appColor //.withAlphaComponent(0.5)
        vwShadow.contentMode = .scaleToFill
        //vwShadow.image = #imageLiteral(resourceName: "ic_buttonShadow")
        //vwShadow.addShadow(shadowColor: UIColor.appColor.cgColor, shadowOffset: CGSize(width: 0, height: 10), shadowOpacity: 0.3, shadowRadius: 6)
    }
    
    
    func colorShadow(shadowOffset: CGSize = CGSize.zero,
                     shadowOpacity: Float = 0.6,
                     shadowRadius: CGFloat = 4.0) {
        
        layer.shadowColor = hexStringToUIColor(hex: "#173647").cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addShadowSmall(shadowColor: CGColor = hexStringToUIColor(hex: "000000").withAlphaComponent(0.8).cgColor,
                        shadowOffset: CGSize = CGSize(width: 0.0, height: 4.0),
                        shadowOpacity: Float = 0.2,
                        shadowRadius: CGFloat = 3.0) {
        layer.cornerRadius = self.cornerRadius
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    @IBInspectable var cornerRadius:CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    /// to add round corner and autoupdate when the view's frame change
    ///
    /// - Parameter corners:
    /// for topLeft - layerMinXMinYCorner,
    /// for topRight - layerMaxXMinYCorner,
    /// for bottomLeft - layerMinXMaxYCorner,
    /// for bottomRight - layerMaxXMaxYCorner,
    ///
    func roundCornersWithMask(corners:CACornerMask, radius: CGFloat) {
        //self.clipsToBounds = false
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    
    
    func shadowWithMaskedCorner(corners:CACornerMask, radius: CGFloat,
                                shadowColor: CGColor = UIColor.darkGray.cgColor,
                                shadowOffset: CGSize = CGSize.zero,
                                shadowOpacity: Float = 0.5,
                                shadowRadius: CGFloat = 2.8) {
        //self.clipsToBounds = false
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        
        
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func roundCornersWithShadow(corners:UIRectCorner, radius: CGFloat) {
        
        let shadowLayer = CAShapeLayer()
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        
        shadowLayer.path = path.cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.lightGray.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: -4.0)
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = 2
        
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    //Set Round
    @IBInspectable var Round:Bool {
        set {
            self.layer.cornerRadius = self.frame.size.height / 2.0
        }
        get {
            return self.layer.cornerRadius == self.frame.size.height / 2.0
        }
    }
    //Set Border Color
    @IBInspectable var borderColor:UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
    }
    //Set Border Width
    @IBInspectable var borderWidth:CGFloat {
        set {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    //Set Shadow in View
    func addShadowView(width:CGFloat=0.2, height:CGFloat=0.2, Opacidade:Float=0.7, maskToBounds:Bool=false, radius:CGFloat=0.5){
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Opacidade
        self.layer.masksToBounds = maskToBounds
    }
    struct NLInnerShadowDirection: OptionSet {
        let rawValue: Int
        
        static let None = NLInnerShadowDirection([])
        static let Left = NLInnerShadowDirection(rawValue: 1 << 0)
        static let Right = NLInnerShadowDirection(rawValue: 1 << 1)
        static let Top = NLInnerShadowDirection(rawValue: 1 << 2)
        static let Bottom = NLInnerShadowDirection(rawValue: 1 << 3)
        static let All = NLInnerShadowDirection(rawValue: 15)
    }
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
    func removeInnerShadow() {
        for view in self.subviews {
            if (view.tag == 2639) {
                view.removeFromSuperview()
                break
            }
        }
    }
    
    func addInnerShadow() {
        let c = UIColor()
        let color = c.withAlphaComponent(0.5)
        
        self.addInnerShadowWithRadius(radius: 3.0, color: color, inDirection: NLInnerShadowDirection.All)
    }
    
    func addInnerShadowWithRadius(radius: CGFloat, andAlpha: CGFloat) {
        let c = UIColor()
        let color = c.withAlphaComponent(alpha)
        
        self.addInnerShadowWithRadius(radius: radius, color: color, inDirection: NLInnerShadowDirection.All)
    }
    
    func addInnerShadowWithRadius(radius: CGFloat, andColor: UIColor) {
        self.addInnerShadowWithRadius(radius: radius, color: andColor, inDirection: NLInnerShadowDirection.All)
    }
    
    func addInnerShadowWithRadius(radius: CGFloat, color: UIColor, inDirection: NLInnerShadowDirection) {
        self.removeInnerShadow()
        
        let shadowView = self.createShadowViewWithRadius(radius: radius, andColor: color, direction: inDirection)
        
        self.addSubview(shadowView)
    }
    
    func createShadowViewWithRadius(radius: CGFloat, andColor: UIColor, direction: NLInnerShadowDirection) -> UIView {
        let shadowView = UIView(frame: CGRect(x: -5,y: 0-5,width: self.bounds.size.width+10,height: self.bounds.size.height+10))
        shadowView.backgroundColor = UIColor.clear
        shadowView.tag = 2639
        
        let colorsArray: Array = [ andColor.cgColor, UIColor.clear.cgColor ]
        
        if direction.contains(.Top) {
            let xOffset: CGFloat = 0.0
            let topWidth = self.bounds.size.width
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.startPoint = CGPoint(x:0.5,y: 0.0)
            shadow.endPoint = CGPoint(x:0.5,y: 1.0)
            shadow.frame = CGRect(x: xOffset,y: 0,width: topWidth,height: radius)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        
        if direction.contains(.Bottom) {
            let xOffset: CGFloat = 0.0
            let bottomWidth = self.bounds.size.width
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.startPoint = CGPoint(x:0.5,y: 1.0)
            shadow.endPoint = CGPoint(x:0.5,y: 0.0)
            shadow.frame = CGRect(x:xOffset,y: self.bounds.size.height - radius, width: bottomWidth,height: radius)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        
        if direction.contains(.Left) {
            let yOffset: CGFloat = 0.0
            let leftHeight = self.bounds.size.height
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.frame = CGRect(x:0,y: yOffset,width: radius,height: leftHeight)
            shadow.startPoint = CGPoint(x:0.0,y: 0.5)
            shadow.endPoint = CGPoint(x:1.0,y: 0.5)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        
        if direction.contains(.Right) {
            let yOffset: CGFloat = 0.0
            let rightHeight = self.bounds.size.height
            
            let shadow = CAGradientLayer()
            shadow.colors = colorsArray
            shadow.frame = CGRect(x:self.bounds.size.width - radius,y: yOffset,width: radius,height: rightHeight)
            shadow.startPoint = CGPoint(x:1.0,y: 0.5)
            shadow.endPoint = CGPoint(x:0.0,y: 0.5)
            shadowView.layer.insertSublayer(shadow, at: 0)
        }
        return shadowView
    }
    
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.1, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.1, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
@IBDesignable extension UINavigationController {
    @IBInspectable var barTintColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            navigationBar.barTintColor = uiColor
        }
        get {
            guard let color = navigationBar.barTintColor else { return nil }
            return color
        }
    }
}
@IBDesignable class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = .white
    @IBInspectable var secondColor: UIColor = .clear
    
    @IBInspectable var vertical: Bool = true
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        
        layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: -0.58, b: -0.76, c: 0.43, d: -3.4, tx: 0.55, ty: 2.98))
        
        layer.bounds = self.bounds.insetBy(dx: -0.5*self.bounds.size.width, dy: -0.5*self.bounds.size.height)
        
        layer.position = self.center
        return layer
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        applyGradient()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        applyGradient()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    //MARK: -
    
    func applyGradient() {
        //updateGradientDirection()
        layer.sublayers = [gradientLayer]
    }
    
    func updateGradientFrame() {
        gradientLayer.frame = bounds
    }
    
    //    func updateGradientDirection() {
    //        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    //    }
}

var isIphoneXOrLonger: Bool {
    // 812.0 / 375.0 on iPhone X, XS.
    // 896.0 / 414.0 on iPhone XS Max, XR.
    return UIScreen.main.bounds.height / UIScreen.main.bounds.width >= 896.0 / 414.0
}

struct MyUserDefaults {
    static let UserData = "Userdata"
    static let Filter = "Filter"
}

//MARK: - Get/Set UserDefaults
func setMyUserDefaults(value:Any, key:String) {
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}

func getMyUserDefaults(key:String)->Any {
    return UserDefaults.standard.value(forKey: key) ?? ""
}

class UserInfo {
    
    //MARK: - Shared Instance
    static let sharedInstance : UserInfo = {
        let instance = UserInfo()
        return instance
    }()
    
    
    //MARK: - Set and Get Login Status
    func isUserLogin() -> Bool {
        if let strLoginStatus:Bool = UserDefaults.standard.bool(forKey: "login") as Bool? {
            let status:Bool = strLoginStatus
            if  status == true {
                return true
            }
        }
        return false
    }
    
    //MARK: - Set and Get Location Status
    func isLocationAllow() -> Bool {
        if let strLoginStatus:Bool = UserDefaults.standard.bool(forKey: "location") as Bool? {
            let status:Bool = strLoginStatus
            if  status == true {
                return true
            }
        }
        return false
    }
    
    //MARK: - Set and Get Location Status
    func isLocationServiceOn() -> Bool {
        if let strLoginStatus:Bool = UserDefaults.standard.bool(forKey: "LocationService") as Bool? {
            let status:Bool = strLoginStatus
            if  status == true {
                return true
            }
        }
        return false
    }
    
    //MARK: - Set and Get RespondMode Status
    func isRespondModeOn() -> Bool {
        if let strLoginStatus:Bool = UserDefaults.standard.bool(forKey: "respondMode") as Bool? {
            let status:Bool = strLoginStatus
            if  status == true {
                return true
            }
        }
        return false
    }
    
    func setUserLogin(isLogin:Bool) {
        
        UserDefaults.standard.set(isLogin, forKey: "login")
        UserDefaults.standard.synchronize()
    }
    
    func setUserLocation(isAllow:Bool) {
        
        UserDefaults.standard.set(isAllow, forKey: "location")
        UserDefaults.standard.synchronize()
    }
    
    func setLocationService(isEnable:Bool) {
        
        UserDefaults.standard.set(isEnable, forKey: "LocationService")
        UserDefaults.standard.synchronize()
    }
    
    func setLoginUser(loginUser:String) {
        
        UserDefaults.standard.set(loginUser, forKey: "loginUser")
        UserDefaults.standard.synchronize()
    }
    
    func setResponsMode(isOn:Bool) {
        
        UserDefaults.standard.set(isOn, forKey: "respondMode")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - Set and Get Register Status
    func isUserRegister() -> Bool {
        
        if let strRegisterStatus:Bool = UserDefaults.standard.bool(forKey: "register") as Bool? {
            let status:Bool = strRegisterStatus
            if  status == true {
                return true
            }
        }
        return false
    }
    
    func setUserRegister(isRegister:Bool) {
        
        UserDefaults.standard.set(isRegister, forKey: "register")
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - Set and Get Logined user details
    func getUserInfo(key: String) -> String {
        
        if let dictUserInfo:NSDictionary = UserDefaults.standard.dictionary(forKey: "Userdata") as NSDictionary? {
            print("Userdata : ",dictUserInfo)
            if let strValue = dictUserInfo.value(forKey: key) {
                return "\(strValue)"
            }
        }
        return ""
        //        if let dictUserInfo:NSDictionary = UserDefaults.standard.dictionary(forKey: "result") as NSDictionary? {
        ////            print("Userdata : ",dictUserInfo)
        //            if let strValue = dictUserInfo.value(forKey: key) {
        //                return "\(strValue)"
        //            }
        //        }
        //        return ""
    }
    
    //MARK: - Set and Get Logined user details
    func getUserTokan(key: String) -> String {
        
        if let dictUserInfo:NSDictionary = UserDefaults.standard.dictionary(forKey: "Userdata") as NSDictionary? {
            print("Userdata : ",dictUserInfo)
            if let strValue = dictUserInfo.value(forKey: key) {
                return "\(strValue)"
            }
        }
        return ""
    }
    
    func setUserInfo(dictData: NSDictionary) {
        
        if UserDefaults.standard.object(forKey: "Userdata") != nil {
            UserDefaults.standard.removeObject(forKey: "Userdata")
            UserDefaults.standard.synchronize()
        }
        
        let dictData = try? NSKeyedArchiver.archivedData(withRootObject: dictData, requiringSecureCoding: false)
        UserDefaults.standard.set(dictData, forKey: "Userdata")
        UserDefaults.standard.synchronize()
    }
}

class Alerts {
    
    static func showActionsheet(viewController: UIViewController, title: String, message: String, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for (index, (title, style)) in actions.enumerated() {
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index)
            }
            alertViewController.addAction(alertAction)
        }
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}

@IBDesignable class BigSwitch: UISwitch {
    
    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setup()
        }
    }
    
    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
}

class Slider: UISlider {
    
    @IBInspectable var thumbImage: UIImage?
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let thumbImage = thumbImage {
            self.setThumbImage(thumbImage, for: .normal)
        }
    }
    
    @IBInspectable var SliderScale : CGFloat = 1 {
        didSet{
            setup()
        }
    }
    
    //from storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    //from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup(){
        self.transform = CGAffineTransform(scaleX: SliderScale, y: SliderScale)
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
        super.prepareForInterfaceBuilder()
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: self)
    }
    
    var comperyear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY"
        return dateFormatter.string(from: self)
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    var dayname: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
    
    var monthname: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self)
    }
    
    var dayAndMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        return dateFormatter.string(from: self)
    }
    
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
}

func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
    
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = Date()
    let earliest = now < date ? now : date
    let latest = (earliest == now) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago"
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago"
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago"
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago"
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now"
    }
    
}

extension UIViewController {
    
    func classname() -> String {
        return NSStringFromClass(self.classForCoder).components(separatedBy: ".").last ?? ""
    }
    
    func addButtonTapHaptic() {
        Haptico.shared().generate(.light)
    }
    
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}

class AutoExpandingTextView: UITextView {
    
    private var heightConstraint: NSLayoutConstraint!
    
    var maxHeight: CGFloat = 100 {
        didSet {
            heightConstraint?.constant = maxHeight
        }
    }
    
    private var observer: NSObjectProtocol?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        heightConstraint = heightAnchor.constraint(equalToConstant: maxHeight)
        observer = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.heightConstraint.isActive = self.contentSize.height > self.maxHeight
            self.isScrollEnabled = self.contentSize.height > self.maxHeight
            self.invalidateIntrinsicContentSize()
        }
    }
}


extension UITextView {
    
    private class PlaceholderLabel: UILabel { }
    
    private var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap( { $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            addSubview(label)
            return label
        }
    }
    
    @IBInspectable
    var placeholderColor: UIColor {
        get {
            return placeholderLabel.textColor
        }
        set{
            self.placeholderLabel.textColor = newValue
        }
    }
    
    @IBInspectable
    var placeholder: String {
        get {
            return subviews.compactMap( { $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.text = newValue.localized
            placeholderLabel.numberOfLines = 0
            placeholderLabel.textColor = self.placeholderColor
            placeholderLabel.alpha = 1
            let width = frame.width - textContainer.lineFragmentPadding * 2
            // let size = placeholderLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            placeholderLabel.sizeToFit()
            //placeholderLabel.frame.size.height = size.height
            placeholderLabel.frame.size.width = width
            placeholderLabel.autoresizesSubviews = true
            placeholderLabel.autoresizingMask = [.flexibleWidth]
            placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding, y: textContainerInset.top)
            
            //for hide/unhide textview when user
            textStorage.delegate = self
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
    
}

extension UITextView: NSTextStorageDelegate {
    
    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
}


///attributed text of add images
extension UILabel {
    /// add imaeg after text
    func addTrailing(image: UIImage, text:String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])
        
        string.append(attachmentString)
        self.attributedText = string
    }
    
    /// add image before text
    func addLeading(image: UIImage, text:String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)
        
        let string = NSMutableAttributedString(string: "  " + text, attributes: [:])
        mutableAttributedString.append(string)
        self.attributedText = mutableAttributedString
    }
}

func changeTextColor(fullStr: String, str: String , color : UIColor) -> NSAttributedString {
    
    let AttributeString = NSMutableAttributedString(string: fullStr)
    let range = (fullStr as NSString).range(of: str)
    AttributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: range)
    return AttributeString
}
extension UIView {
    
    func addShadowView() {
        //Remove previous shadow views
        superview?.viewWithTag(119900)?.removeFromSuperview()
        //Create new shadow view with frame
        let shadowView = UIView(frame: frame)
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true
        superview?.insertSubview(shadowView, belowSubview: self)
    }
}

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

struct Constant {
    
    //----------------------------------------------------------------
    //MARK:- KEY CONST -
    
    static let userProfileImage = UIImage(named: "ic_user_placeholder")
    static let defualtPlaceholder = UIImage(named: "ic_placeholder")
    static let MapBoxPublicToken = "pk.eyJ1IjoiaGltYW5zaHV2emVzdGJyYWlucyIsImEiOiJja3dkYWtlOGcwajdoMm5uMTgyenQ2cDd4In0.T_bedArVluKMxqIQepHCuA"
    static let kStaticRadioOfCornerRadios: CGFloat = 0
    static let ALERT_OK = "OK"
    static let ALERT_DISMISS = "Okay".localized
    static let KEY_IS_USER_LOGGED_IN = "USER_LOGGED_IN"
    static let GoogleMapKey = "AIzaSyBQXwC_zxukdLojGOafj2c0wG3FE5PeF0Q"
    
    static var APP_NAME: String = Bundle.main.displayName ?? ""
}

extension UITextField {
    
    func addInputViewDatePicker(target: Any, selector: Selector) {
        
        let screenWidth = UIScreen.main.bounds.width
        
        //Add DatePicker as inputView
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.maximumDate =  Date()
        self.inputView = datePicker
        
        //Add Tool Bar as input AccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        let doneBarButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancelBarButton, flexibleSpace, doneBarButton], animated: false)
        
        self.inputAccessoryView = toolBar
    }
    
    @objc func cancelPressed() {
        self.resignFirstResponder()
    }
}

extension Array {
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}

extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attrString = NSMutableAttributedString()
        if (self.attributedText != nil) {
            attrString.append( self.attributedText!)
        } else {
            attrString.append( NSMutableAttributedString(string: self.text!))
            attrString.addAttribute(NSAttributedString.Key.font, value: self.font!, range: NSMakeRange(0, attrString.length))
        }
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}

extension UIColor{
    //Colors are computed class properties. To refrence the class, use self
    
    class var AppColor: UIColor {
        return hexStringToUIColor(hex: "#tabbarSelected")
    }
    class var AppBlueColor: UIColor {
        return #colorLiteral(red: 0.9333333333, green: 0.737254902, blue: 0.2862745098, alpha: 1)
    }
}

public extension UICollectionView {
    
    /**
     Register nibs faster by passing the type - if for some reason the `identifier` is different then it can be passed
     - Parameter type: UITableViewCell.Type
     - Parameter identifier: String?
     */
    func registerCell(type: UICollectionViewCell.Type, identifier: String? = nil) {
        let cellId = String(describing: type)
        register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: identifier ?? cellId)
    }
    
    /**
     DequeueCell by passing the type of UICollectionViewCell and IndexPath
     - Parameter type: UICollectionViewCell.Type
     - Parameter indexPath: IndexPath
     */
    func dequeueCell<T: UICollectionViewCell>(withType type: UICollectionViewCell.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as? T
    }
    
}

extension UICollectionView {
    
    func setDefaultProperties(vc: Any){
        self.dataSource = vc as? UICollectionViewDataSource
        self.delegate = vc as? UICollectionViewDelegate
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

public extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

//MARK:- tableview register
extension UITableView {
    func registerNib(_ className : UITableViewCell?) {
        self.register(UINib(nibName: "\(className ?? UITableViewCell())", bundle: nil), forCellReuseIdentifier: "\(className ?? UITableViewCell())")
    }
}
public extension UITableView {
    
    /**
     Register nibs faster by passing the type - if for some reason the `identifier` is different then it can be passed
     - Parameter type: UITableViewCell.Type
     - Parameter identifier: String?
     */
    func registerCell(type: UITableViewCell.Type, identifier: String? = nil) {
        let cellId = String(describing: type)
        register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: identifier ?? cellId)
    }
    
    /**
     DequeueCell by passing the type of UITableViewCell
     - Parameter type: UITableViewCell.Type
     */
    func dequeueCell<T: UITableViewCell>(withType type: UITableViewCell.Type) -> T? {
        return dequeueReusableCell(withIdentifier: type.identifier) as? T
    }
    
    /**
     DequeueCell by passing the type of UITableViewCell and IndexPath
     - Parameter type: UITableViewCell.Type
     - Parameter indexPath: IndexPath
     */
    func dequeueCell<T: UITableViewCell>(withType type: UITableViewCell.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as? T
    }
    
}

public extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

//MARK- uicollectionview cell register
extension UICollectionView {
    func registerNib(_ className : UICollectionViewCell?) {
        self.register(UINib(nibName: "\(className ?? UITableViewCell())", bundle: nil), forCellWithReuseIdentifier: "\(className ?? UITableViewCell())")
    }
}

extension UITableView {
    /**
     Calculates the total height of the tableView that is required if you ware to display all the sections, rows, footers, headers...
     */
    func contentHeight() -> CGFloat {
        var height = CGFloat(0)
        for sectionIndex in 0..<numberOfSections {
            for rowIndex in 0..<numberOfRows(inSection: sectionIndex){
                height += rectForRow(at: IndexPath.init(row: rowIndex, section: sectionIndex)).size.height
            }
            //            height += rect(forSection: sectionIndex).size.height
        }
        return height
    }
    
}

extension UITableView {
    func setDefaultProperties(_ toClass : AnyObject){
        self.separatorStyle = .none
        self.dataSource = toClass as? UITableViewDataSource
        self.delegate = toClass as? UITableViewDelegate
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor(named: "AppWhiteFontColor")
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = Font(.installed(.TitilliumRegular), size: .standard(.S16)).instance //UIFont.appFont_PoppinsSemiBold(Size: 18)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}

/// to change the text color of some text in the any string
func setColorForText(_ fullString : String ,
                     _ textToFind: String, attributes : [NSAttributedString.Key : Any]) -> NSMutableAttributedString {
    
    let attrString = NSMutableAttributedString(string: fullString)
    let range = (fullString as NSString).range(of: textToFind, options: .caseInsensitive)
    
    attrString.addAttributes(attributes, range: range)
    return attrString
}

extension UIView {
    
    func hideAnimated(in stackView: UIStackView) {
        if !self.isHidden {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.isHidden = true
                    self.alpha = 0
                    stackView.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
    
    func showAnimated(in stackView: UIStackView) {
        if self.isHidden {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.isHidden = false
                    self.alpha = 1
                    stackView.layoutIfNeeded()
                },
                completion: nil
            )
        }
    }
    
}

extension UIViewController {
    func scrollToTop() {
        func scrollToTop(view: UIView?) {
            guard let view = view else { return }
            
            switch view {
            case let scrollView as UIScrollView:
                if scrollView.scrollsToTop == true {
                    scrollView.setContentOffset(CGPoint(x: 0.0, y: -scrollView.contentInset.top), animated: true)
                    scrollView.contentOffset = .zero
                    return
                }
            default:
                break
            }
            
            for subView in view.subviews {
                scrollToTop(view: subView)
            }
        }
        
        scrollToTop(view: view)
    }
    
    var isScrolledToTop: Bool {
        if self is UITableViewController {
            return (self as! UITableViewController).tableView.contentOffset.y == 0
        }
        for subView in view.subviews {
            if let scrollView = subView as? UIScrollView {
                return (scrollView.contentOffset.y == 0)
            }
        }
        return true
    }
}

extension UIScrollView {
    
    public var currentPage : Int {
        let pageWidth = self.frame.size.width
        return Int((self.contentOffset.x + pageWidth / 2) / pageWidth)
    }
}
