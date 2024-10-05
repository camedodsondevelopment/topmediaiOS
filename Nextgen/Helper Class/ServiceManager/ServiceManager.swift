//
//  ServiceManager.swift
//  DemoServiceManage
//
//  Created by Zestbrains on 11/06/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

struct MultiPartDataType {
    var mimetype: String  = "image/png"
    var fileName: String  = "swift.png"
    var fileData: Data?
    var keyName: String = ""
}

typealias APIResponseBlock = ((_ response: JSON,_ isSuccess: Bool,_ error: String ,_ statusCode : Int?)->())
typealias APIResponseBlockWithStatusCode = ((_ response: NSDictionary?,_ isSuccess: Bool,_ error: String? ,_ statusCode : Int?)->())
typealias APIFailureResponseBlock = ((_ response: NSDictionary?,_ isSuccess: Bool,_ error: String? ,_ statusCode : Int?)->())

enum ApiURL {
    case none
    case baseURL
    case baseURLMain
    
    //Authentication
    case login
    case signup
    case forgotPassword
    case checkSocialAvaibilty
    case SocialRegister
    case logout
    case deleteAccount
    case editProfile
    case changePassword
    case SendOTP
    case VerifyOTP
    case GetProfile
    case VersionChecker
    case helpRequest
    case upadteCryptoAddress
    case getHomeList
    case getVideoList
    case likePost
    case followUser
    case removeFollowingUser
    case blockUser
    case unblockUser
    case getAgoraToken
    case notifyToAllFollowers
    case liveOffStatus
    case getUserLiveStatus
    case inviteUsersForStreaming
    
    case postCreate
    case editPost
    case postHide
    case postReport
    case postDelete
    case postDetails
    case postLists
    case searchUser
    
    case commentList
    case commentCreate
    case subCommentCreate
    case commentLike
    
    case profilePost
    case profileLiked
    case profileMedia
    case getOtherUserProfile
    case getProfileViewer
    
    case getFollowingList
    case getFollowersList
    case reportUser
    case getNotificationList
    case RemoveAllNotifications
    
    case termsConditions
    case privacyPolicy
    
    func strURL() -> String {
        var str: String  = ""
        
        switch self {
        case .none :
            return ""
        case .baseURL:
            return ApiURL.baseURLMain.strURL() + "api/V1/"
        case .baseURLMain :
            return "https://srv541383.hstgr.cloud/" // "https://cryptowestapi.dodsondevelopment.tech/public/"  //"https://dodson-development.com/cryptowest/public/"
        case .login :
            str = "login"
        case .signup :
            str = "signup"
        case .forgotPassword :
            str = "forgot_password"
        case .checkSocialAvaibilty :
            str = "social_login"
        case .SocialRegister :
            str = "social_register"
        case .deleteAccount :
            str = "user/delete_profile"
        case .logout:
            str = "user/logout"
        case .editProfile:
            str = "user/update/profile"
        case .changePassword:
            str = "user/update/password"
        case .SendOTP:
            str = "send_otp"
        case .VerifyOTP:
            str = "verify_otp"
        case .GetProfile :
            str = "user/profile"
        case .VersionChecker :
            str = "version_checker"
        case .upadteCryptoAddress :
            str = "user/update/crypto_address"
        case .getHomeList :
            str = "user/home"
        case .getVideoList :
            str = "posts/video_list"
        case .likePost :
            str = "posts/like_unlike/"
        case .followUser :
            str = "user/follow/"
        case .removeFollowingUser :
            str = "user/remove_follower/"
        case .blockUser :
            str = "block/add/"
        case .unblockUser :
            str = "block/remove/"
        case .helpRequest :
            str = "user/help_request"
        case .postCreate :
            str = "posts/create"
        case .editPost :
            str = "posts/edit"
        case .postHide :
            str = "posts/hide"
        case .postReport :
            str = "posts/report"
        case .postDelete :
            str = "posts/delete/"
        case .postDetails :
            str = "posts/details/"
        case .postLists :
            str = "posts/list"
        case .searchUser :
            str = "user/search_user"
        case .profilePost :
            str = "posts/all_non_media"
        case .profileLiked :
            str = "posts/like_comment"
        case .profileMedia :
            str = "posts/all_media"
        case .getOtherUserProfile :
            str = "user/details/"
        case .getProfileViewer :
            str = "user/viewer_list"
        case .commentList :
            str = "posts/comment/list"
        case .commentCreate :
            str = "posts/comment/create"
        case .subCommentCreate :
            str = "posts/comment/reply/create"
        case .commentLike :
            str = "posts/comment/like_unlike/"
        case .getFollowingList :
            str = "user/following"
        case .getFollowersList :
            str = "user/follower"
        case .reportUser :
            str = "user/report"
        case .getNotificationList :
            str = "user/notification"
        case .RemoveAllNotifications :
            str = "user/notification/remove_all"
        case .termsConditions :
            str = "content/terms&conditions"
        case .privacyPolicy :
            str = "content/privacy_policy"
        case .getAgoraToken:
            str = "user/agora_token_generator"
        case .notifyToAllFollowers:
            str = "user/send_notifications_to_all_users"
        case .liveOffStatus:
            str = "user/live_status/off"
        case .getUserLiveStatus:
            str = "user/live_status"
        case .inviteUsersForStreaming:
            str = "user/send_notifications_to_selected_users"
        }
    
        return ApiURL.baseURL.strURL() + str
    }
}

class ServiceManager: NSObject {
    
    static let shared: ServiceManager = ServiceManager()
    let manager: Session
    
    var headers: HTTPHeaders {
        let lastToken = NextgenUser.shared.token
        var appLanguageDataPass = ""
        switch appDelegate.Applanguage {
        case "en":
            appLanguageDataPass = "en"
        case "es":
            appLanguageDataPass = "es"
        case "zh-Hans":
            appLanguageDataPass = "ca"
        case "hi":
            appLanguageDataPass = "hi"
        case "fr":
            appLanguageDataPass = "fr"
        case "de":
            appLanguageDataPass = "de"
        default :
            break
        }
        
        var header: HTTPHeaders = ["Accept": "application/json","Accept-Language":appLanguageDataPass]
        
        if !lastToken.isEmpty {
            header["vAuthorization"] = "Bearer \(lastToken)"
        }
        return header
    }
    var paramEncode: ParameterEncoding = URLEncoding.default
    
    
    var pushHeaders: HTTPHeaders {
//        let header: HTTPHeaders = ["Content-Type": "application/json", "Authorization": "key=\("AAAAoaCu6q8:APA91bG1C2lzjruLaEPejwaX0YWN_1TgQ1cIfO9BQDPSsS1HAZMVDCtarqRHuKfPWrOaDKjQ24vx9ez2-yh35FykQ1sxfO0UlTepDXwMzOTUGC5Ucr4sEYrA3Pbq_DaWk7XY3yB2nyY2")"]
        let header: HTTPHeaders = ["Content-Type": "application/json", "Authorization": "Bearer AAAAoaCu6q8:APA91bG1C2lzjruLaEPejwaX0YWN_1TgQ1cIfO9BQDPSsS1HAZMVDCtarqRHuKfPWrOaDKjQ24vx9ez2-yh35FykQ1sxfO0UlTepDXwMzOTUGC5Ucr4sEYrA3Pbq_DaWk7XY3yB2nyY2"]
        return header
    }
    
    override init() {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60*2
        configuration.timeoutIntervalForResource = 60*2
        
        manager = Session(configuration: configuration)
        
        super.init()
    }
    
    // MARK:- API CAlling methods
    func postRequest(ApiURL : ApiURL , strURLAdd : String = "",
                     parameters : [String: Any] ,
                     isShowLoader : Bool = true,
                     isPassHeader : Bool = true,
                     additionalHeader : HTTPHeaders = [:],
                     isShowErrorAlerts : Bool = true,
                     Success successBlock:@escaping APIResponseBlock,
                     Failure failureBlock:@escaping APIResponseBlock) {
        
        print(ApiURL)
        
        do {
            
            var header : HTTPHeaders = additionalHeader
            if isPassHeader {
                header = self.headers
                
                print(header)
                
            }
            
            if ServiceManager.checkInterNet() {
                
                if isShowLoader {
                    SHOW_CUSTOM_LOADER()
                }
                
                let url = try getFullUrl(relPath: ApiURL.strURL() + strURLAdd)
                
                //printing headers and parametes
                printStart(header: header ,Parameter: parameters , url: url)
                
                _ = manager.request(url, method: .post, parameters: parameters, encoding: paramEncode, headers: header).responseData(completionHandler: { (resObj) in
                    
                    self.printSucess(json: resObj)
                    
                    let statusCode = resObj.response?.statusCode ?? 0
                    
                    switch resObj.result {
                    case .success(let json) :
                        print("SuccessJSON \(json)")
                        
                        self.handleSucess(json: json, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                        
                    case .failure(let err) :
                        print(err)
                        
                        if let data = resObj.data, let str = String(data: data, encoding: String.Encoding.utf8){
                            print("Server Error: " + str)
                        }
                        
                        self.handleFailure(json: "", error: err, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                    }
                    
                })
            }
            
        } catch let error {
            self.jprint(items: error)
            //            HIDE_CUSTOM_LOADER()
        }
    }
    
    func postRequestForSendFCM(ApiURL : String, strURLAdd : String = "",
                               parameters : [String: Any] ,
                               isShowLoader : Bool = true,
                               isPassHeader : Bool = true,
                               additionalHeader : HTTPHeaders = [:],
                               isShowErrorAlerts : Bool = true,
                               Success successBlock:@escaping APIResponseBlock,
                               Failure failureBlock:@escaping APIResponseBlock) {
        
        do {
            
            var header : HTTPHeaders = additionalHeader
            if isPassHeader {
                header = self.pushHeaders
            }
            
            if ServiceManager.checkInterNet() {
                
                if isShowLoader {
                    DispatchQueue.main.async {
                        SHOW_CUSTOM_LOADER()
                    }
                }
                
                let url = try getFullUrl(relPath: ApiURL + strURLAdd)
                
                // printing headers and parametes
                printStart(header: header, Parameter: parameters, url: url)
                
                _ = manager.request(url, method: .post, parameters: nil, encoding: BodyStringEncoding(body: JSON(parameters).rawString(.ascii, options: .sortedKeys) ?? ""), headers: header).responseData(completionHandler: { (resObj) in
                    
                    if isShowLoader {
                        DispatchQueue.main.async {
                            HIDE_CUSTOM_LOADER()
                        }
                    }
                    
                    self.printSucess(json: resObj)
                    
                    let statusCode = resObj.response?.statusCode ?? 0
                    
                    switch resObj.result {
                    case .success(let json) :
                        print("SuccessJSON \(json)")
                        
                        self.handleSucess(json: json, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                        
                    case .failure(let err) :
                        print(err)
                        
                        if let data = resObj.data, let str = String(data: data, encoding: String.Encoding.utf8){
                            print("Server Error: " + str)
                        }
                        
                        self.handleFailure(json: "", error: err, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                    }
                    
                })
            }
            
        } catch let error {
            self.jprint(items: error)
            if isShowLoader {
                DispatchQueue.main.async {
                    HIDE_CUSTOM_LOADER()
                }
            }
        }
    }
    
    func getRequest(newAPIURL: String = "", ApiURL : ApiURL , strAddInURL : String = "",
                    parameters : [String: Any] ,
                    isShowLoader : Bool = true,
                    isPassHeader : Bool = true,
                    isShowErrorAlerts : Bool = true,
                    Success successBlock:@escaping APIResponseBlock,
                    Failure failureBlock:@escaping APIResponseBlock) {
        
        do {
            
            var header : HTTPHeaders = []
            if isPassHeader {
                header = self.headers
            }
            
            if ServiceManager.checkInterNet() {
                
                if isShowLoader {
                    SHOW_CUSTOM_LOADER()
                }
                
                let strURL = (newAPIURL == "" ? ApiURL.strURL() : newAPIURL) + strAddInURL
                let url = try getFullUrl(relPath: strURL)
                
                //printing headers and parametes
                printStart(header: header ,Parameter: parameters , url: url)
                
                _ = manager.request(url, method: .get, parameters: parameters, encoding: paramEncode, headers: header).responseData(completionHandler: { (resObj) in
                    
                    HIDE_CUSTOM_LOADER()
                    
                    self.printSucess(json: resObj)
                    
                    let statusCode = resObj.response?.statusCode ?? 0
                    
                    switch resObj.result {
                    case .success(let json) :
                        print("SuccessJSON \(json)")
                        
                        self.handleSucess(json: json, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                        
                    case .failure(let err) :
                        print(err)
                        
                        if let data = resObj.data, let str = String(data: data, encoding: String.Encoding.utf8){
                            print("Server Error: " + str)
                        }
                        
                        self.handleFailure(json: "", error: err, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                    }
                    
                })
            }
        }catch let error {
            self.jprint(items: error)
            HIDE_CUSTOM_LOADER()
        }
    }
    
    func putRequest(ApiURL : ApiURL ,
                    parameters : [String: Any] ,
                    isShowLoader : Bool = true,
                    isPassHeader : Bool = true,
                    isShowErrorAlerts : Bool = true,
                    Success successBlock:@escaping APIResponseBlock,
                    Failure failureBlock:@escaping APIResponseBlock) {
        
        do {
            
            var header : HTTPHeaders = []
            if isPassHeader {
                header = self.headers
            }
            
            if ServiceManager.checkInterNet() {
                if isShowLoader {
                    SHOW_CUSTOM_LOADER()
                }
                
                let url = try getFullUrl(relPath: ApiURL.strURL())
                
                //printing headers and parametes
                printStart(header: header ,Parameter: parameters , url: url)
                
                _ = manager.request(url, method: .put, parameters: parameters, encoding: paramEncode, headers: header).responseData(completionHandler: { (resObj) in
                    
                    HIDE_CUSTOM_LOADER()
                    
                    self.printSucess(json: resObj)
                    
                    let statusCode = resObj.response?.statusCode ?? 0
                    
                    switch resObj.result {
                    case .success(let json) :
                        print("SuccessJSON \(json)")
                        
                        self.handleSucess(json: json, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                        
                    case .failure(let err) :
                        print(err)
                        
                        if let data = resObj.data, let str = String(data: data, encoding: String.Encoding.utf8){
                            print("Server Error: " + str)
                        }
                        
                        self.handleFailure(json: "", error: err, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                    }
                    
                })
            }
            else
            {
                
            }
            
        }catch let error {
            self.jprint(items: error)
            HIDE_CUSTOM_LOADER()
        }
    }
    
    func postMultipartRequest(ApiURL : ApiURL ,
                              imageVideoParameters : [MultiPartDataType],
                              parameters : [String: Any] ,
                              isShowLoader : Bool = true,
                              isPassHeader : Bool = true,
                              isShowErrorAlerts : Bool = true,
                              Success successBlock:@escaping APIResponseBlock,
                              Failure failureBlock:@escaping APIResponseBlock) {
        
        do {
            
            var header : HTTPHeaders = []
            if isPassHeader {
                header = self.headers
            }
            
            if ServiceManager.checkInterNet() {
                if isShowLoader {
                    SHOW_CUSTOM_LOADER()
                }
                
                let url = try getFullUrl(relPath: ApiURL.strURL())
                
                
                var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
                urlRequest.httpMethod = "POST"
                urlRequest.headers = header
                
                //printing headers and parametes
                printStart(header: header ,Parameter: parameters , url: url)
                
                _ = manager.upload(multipartFormData: { multiPart in
                    for (key, value) in parameters {
                        if let temp = value as? String {
                            multiPart.append(temp.data(using: .utf8)!, withName: key )
                        }
                        if let temp = value as? Int {
                            multiPart.append("\(temp)".data(using: .utf8)!, withName: key )
                        }
                        if let temp = value as? NSArray {
                            temp.forEach({ element in
                                let keyObj = key + "[]"
                                print("keyObj:",keyObj)
                                if let string = element as? String {
                                    print("string:",string)
                                    multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                                } else
                                if let num = element as? Int {
                                    let value = "\(num)"
                                    print("num:",num)
                                    
                                    multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                                }
                            })
                        }else if let temp = value as? Double {
                            multiPart.append("\(temp)".data(using: .utf8)!, withName: key )
                        }
                        
                    }
                    
                    for obj in imageVideoParameters {
                        if let fileData = obj.fileData {
                            multiPart.append(fileData, withName:obj.keyName, fileName: obj.fileName, mimeType: obj.mimetype)
                        }
                    }
                    
                }, with: urlRequest)
                
                .uploadProgress(queue: .main, closure: { progress in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .responseData(completionHandler: { (resObj) in
                    
                    HIDE_CUSTOM_LOADER()
                    
                    self.printSucess(json: resObj)
                    
                    let statusCode = resObj.response?.statusCode ?? 0
                    
                    switch resObj.result {
                    case .success(let json) :
                        print("SuccessJSON \(json)")
                        
                        self.handleSucess(json: json, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                        
                    case .failure(let err) :
                        print(err)
                        
                        if let data = resObj.data, let str = String(data: data, encoding: String.Encoding.utf8){
                            print("Server Error: " + str)
                        }
                        
                        self.handleFailure(json: "", error: err, statusCode: statusCode, isShowErrorAlerts: isShowErrorAlerts, Success: successBlock, Failure: failureBlock)
                    }
                    
                })
            }
            
        }catch let error {
            self.jprint(items: error)
            HIDE_CUSTOM_LOADER()
        }
    }
    
}


// MARK: - Internet Availability

extension ServiceManager {
    
    class func checkInterNet() -> Bool {
        if Connectivity.isConnectedToInternet() {
            return true
        } else {
            let alertController = UIAlertController(title: Constant.APP_NAME, message: "Internet Connection seems to be offline", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            let keyWindow: UIWindow? = UIApplication.shared.windows.first
            keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            return false
        }
    }
    
    // Get Full URL
    func getFullUrl(relPath : String) throws -> URL {
        do {
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www") {
                return try relPath.asURL()
            } else {
                return try (ApiURL.baseURL.strURL() + relPath).asURL()
            }
        } catch let err {
            HIDE_CUSTOM_LOADER()
            throw err
        }
    }
}

//MARK:- Handler functions
extension ServiceManager {
    
    
    func handleSucess(json : Any,isStringJSON : Bool = false, statusCode : Int, isShowErrorAlerts : Bool = true, Success successBlock:@escaping APIResponseBlock, Failure failureBlock:@escaping APIResponseBlock) {
        
        var jsonResponse = JSON(json)
        if isStringJSON {
            jsonResponse = JSON.init(parseJSON: "\(json)")
        }
        let dataResponce:Dictionary<String,Any> = jsonResponse.dictionaryValue
        let errorMessage : String = jsonResponse["message"].string ?? "Something went wrong."
        
        let isShowErrorAlerts = isShowErrorAlerts && (!(errorMessage.localizedCaseInsensitiveContains("You need to register")))
        
        if(statusCode == 307)
        {
            failureBlock(jsonResponse,false,errorMessage, statusCode)
            
            guard isShowErrorAlerts else { return }
            
            if let LIveURL:String = dataResponce["iOS_live_application_url"] as? String{
                if let topController = UIApplication.topViewController() {
                    
                    CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: topController, title: Constant.APP_NAME, andMessage: errorMessage, buttons: ["Open Store"]) { (i) in
                        if let url = URL(string: LIveURL),
                           UIApplication.shared.canOpenURL(url){
                            guard let url = URL(string: "\(url)"), !url.absoluteString.isEmpty else {
                                return
                            }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
        }
        else if(statusCode == 401)
        {
            failureBlock(jsonResponse,false,"User Logged out.", statusCode)
            
            NextgenUser.shared.clear()
            appDelegate.setLoginScreen()
            
            guard isShowErrorAlerts else { return }
            
            CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: errorMessage)
            
            return
            
        }
        else if (statusCode == 412) {
            failureBlock(jsonResponse,false,errorMessage, statusCode)
            
            guard isShowErrorAlerts else { return }
            
            CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: errorMessage)
            return
        }
        
        else if (statusCode == 200){
            successBlock(jsonResponse, true, errorMessage,statusCode)
        }
        
        else {
            failureBlock(jsonResponse,false,errorMessage, statusCode)
            
            guard isShowErrorAlerts else { return }
            
            CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: errorMessage)
            return
        }
    }
    
    func handleFailure(json : Any, isStringJSON : Bool = false, error : AFError, statusCode : Int, isShowErrorAlerts : Bool = true, Success suceessBlock:@escaping APIResponseBlock, Failure failureBlock:@escaping APIResponseBlock) {
        
        var jsonResponse = JSON(json)
        if isStringJSON {
            jsonResponse = JSON.init(parseJSON: "\(json)")
        }
        
        let errorMessage : String = jsonResponse["message"].string ?? "Something went wrong."
        
        let isShowErrorAlerts = isShowErrorAlerts && (!(errorMessage.localizedCaseInsensitiveContains("no record found")))
        
        print(error.localizedDescription)
        print("\n\n===========Error===========")
        print("Error Code: \(error._code)")
        print("Error Messsage: \(error.localizedDescription)")
        
        print("===========================\n\n")
        HIDE_CUSTOM_LOADER()
        
        
        if (error._code == NSURLErrorTimedOut || error._code == 13 ) {
            failureBlock(jsonResponse,true,errorMessage, statusCode)
        }
        else{
            failureBlock(jsonResponse,false,errorMessage, statusCode)
            guard isShowErrorAlerts else { return }
            CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: UIApplication.topViewController()!, andMessage: errorMessage)
            return
        }
    }
    
    func printStart(header : HTTPHeaders,Parameter: [String : Any] , url: URL)  {
        print("**** API CAll Start ****")
        print("**** API URL ****" , url)
        
        print("**** API Header Start ****")
        print(header)
        print("**** API Header End ****")
        print("**** API Parameter Start ****")
        print(Parameter)
        print("**** API Parameter End ****")
    }
    
    func printSucess(json : Any) {
        print("**** API CAll END ****")
        print("**** API Response Start ****")
        print(json)
        print("**** API Response End ****")
    }
    
    func jprint(items: Any...) {
        for item in items {
            print(item)
        }
    }
    
}

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

struct BodyStringEncoding: ParameterEncoding {
    
    private let body: String
    
    init(body: String) { self.body = body }
    
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest else { throw Errors.emptyURLRequest }
        guard let data = body.data(using: .utf8) else { throw Errors.encodingProblem }
        urlRequest.httpBody = data
        return urlRequest
    }
}

extension BodyStringEncoding {
    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension BodyStringEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyURLRequest: return "Empty url request"
        case .encodingProblem: return "Encoding problem"
        }
    }
}
