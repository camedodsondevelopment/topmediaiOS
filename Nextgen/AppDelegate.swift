//
//  AppDelegate.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import IQKeyboardManagerSwift
import FBSDKCoreKit
import GoogleSignIn
import Firebase
import SwiftyJSON
import FirebaseMessaging
import AVFAudio

let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate ?? AppDelegate()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceToken:String = ""
    var fcmRegTokenMessage: String = ""
    
    var Applanguage : String {
        get {
            let lanague = UserDefaults.standard.string(forKey: "app_lang") ??  Locale.current.languageCode
            Bundle.setLanguage(lanague ?? "en")
            return lanague ?? "en"
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "app_lang")
            Bundle.setLanguage(newValue)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarConfiguration.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.toolbarConfiguration.tintColor = UIColor(named: "tabbarSelected")
        UITextView.appearance().tintColor = UIColor(named: "tabbarSelected")
        UITextField.appearance().tintColor = UIColor(named: "tabbarSelected")

        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        FirebaseApp.configure()
        DynamicLinks.performDiagnostics(completion: nil)
        Messaging.messaging().delegate = self
        
        print("Applanguage: ", Applanguage)
        
        setDefualtNavigationForapp()
        
        registerForRemoteNotification()
        UIApplication.shared.applicationIconBadgeNumber = 0
        checkMode()
        appVersionChecker()
        
        let emptyImage = UIImage()
        UITabBar.appearance().backgroundImage = emptyImage
        UITabBar.appearance().tintColor = .lightGray

        
        let appDelegates = UIApplication.shared.windows.first
        
        if UserDefaults.standard.bool(forKey: "Mode") {
            appDelegates?.overrideUserInterfaceStyle = .dark
        }else {
            appDelegates?.overrideUserInterfaceStyle = .light
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        
        return true
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        appVersionChecker()
    }
    
    //MARK: FACEBOOK LOGIN AND GOOGLE LOGIN
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        
        if let _ = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            return true
        }
        
        //for Google Login
        let handled: Bool = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        
        //for facebook
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    //MARK: dynamic link
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!)
        { (dynamiclink, error) in
            
            guard error == nil else{
                print("Error:\(String(describing: error))")
                return
            }
            guard let inCommingURL = dynamiclink?.url else { return }
            print("Incomming Web Page URL: \(inCommingURL)")
            let strURL = inCommingURL.absoluteString
            print("strURL : ",strURL)
            
            if strURL.contains("post_id")
            {
                let ID = strURL.components(separatedBy: "=")[1]
                let vc : PostDetailsVC = PostDetailsVC.instantiate(appStoryboard: .Home)
                vc.postID = ID
                UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return handled
    }
    
}


//MARK: - Push notification
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Called to let your app know which action was selected by the user for a given notification.
        let userInfo = response.notification.request.content.userInfo as NSDictionary
                
        print("USER INFO : \(userInfo)")
        
        if let broadcaster = userInfo["broadcaster_noti"] as? Int, broadcaster == 1 {
            if broadcasters.count == 4 {
                GeneralUtility().showErrorMessage(message: "There are already 4 broadcasters. The limit for joiner is 4.")
                return
            }
            channelName = userInfo["channel_name"] as? String ?? ""
            isABroadcaster = true
            joinStreamingAs(joinerType: "broadcaster")

        }else if let channelN = userInfo["channel_name"] as? String, channelN.count > 0 {
            channelName = channelN
            isABroadcaster = false
            broadcasterName = userInfo["broadcaster_name"] as? String ?? ""
            bcasterProfileImage = userInfo["profile_pic_url"] as? String ?? ""
            
            joinStreamingAs(joinerType: "audience")
            
        }else{
            handlePushNotification(userInfo: JSON(userInfo))
        }
    }
    
    func joinStreamingAs(joinerType:String){
        if let vc = UIApplication.shared.topViewController(), vc is CustomTabBarController {
            let parameter : [String : Any] =
            [
                "channel_name" : channelName,
                "uid" : NextgenUser.shared.id,
                "type" : joinerType
            ]
            
            ServiceManager.shared.postRequest(ApiURL: .getAgoraToken, parameters: parameter, Success: { (response, Success, message, statusCode) in
                
                let responseDcit = response.dictionaryValue
                if let token = responseDcit["data"]?.stringValue, token.count > 0 {
                    let vc = BecomeLiveViewController.instantiate(appStoryboard: .Home) as! BecomeLiveViewController
                    vc.modalPresentationStyle = .fullScreen
                    vc.agoraSDKToken = token
                    vc.joinerType = joinerType
                    UIApplication.shared.topMostViewController()?.present(vc, animated: true)
                }else{
                    CommonClass().showAlertWithTitleFromVC(vc: UIApplication.shared.topMostViewController() ?? UIViewController(), andMessage: responseDcit["message"]?.stringValue ?? "")
                }
                
            }, Failure: { (response, Success, message, statusCode) in
                print("Failure Response:",response)
            })
        }
    }
    
    //MARK: - Register Remote Notification Methods // <= iOS 9.x
    func registerForRemoteNotification() {
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        UIApplication.shared.registerForRemoteNotifications()
                    })
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    //MARK: - Remote Notification Methods // <= iOS 9.x
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        self.deviceToken = deviceTokenString
        
        print("deviceToken" ,deviceTokenString)
        Messaging.messaging().delegate = self
        getFCMToken()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let data_item = userInfo as NSDictionary
        let push_type = data_item.value(forKey: "push_type") as! String
        print(push_type)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // MARK: - UNUserNotificationCenter Delegate // >= iOS 10
    //Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("User Info = ",notification.request.content.userInfo)
        if let userInfo = notification.request.content.userInfo as? [String : Any] {
            print("\(String(describing: userInfo))")
            if let broadcaster = userInfo["broadcaster_noti"] as? Int, broadcaster == 1 {
                if broadcasters.count == 4 {
                    GeneralUtility().showErrorMessage(message: "There are already 4 broadcasters. The limit for joiner is 4.")
                    return
                }
                channelName = userInfo["channel_name"] as? String ?? ""
                isABroadcaster = true
                
                completionHandler([.alert, .badge, .sound])
                
            }else if let channelN = userInfo["channel_name"] as? String, channelN.count > 0 {
                channelName = channelN
                broadcasterName = userInfo["broadcaster_name"] as? String ?? ""
                bcasterProfileImage = userInfo["profile_pic_url"] as? String ?? ""
                isABroadcaster = true
                
                completionHandler([.alert, .badge, .sound])
            }else{
                let jsonUserInfo = JSON(userInfo)
                let pushType = jsonUserInfo["aps"]["push_type"].intValue
                            
                guard let topVc = UIApplication.topViewController() else { return }
                
                switch pushType {
                case 1:
                    
                    if let _ = topVc as? ChatDetailsVC {
                        
                    } else {
                        completionHandler([.alert, .badge, .sound])
                    }
                    
                default :
                    completionHandler([.alert, .badge, .sound])
                    print("pushType : " , pushType)
                }
                
                
                completionHandler([.alert, .badge, .sound])
                print("pushType : " , pushType)
            }
        }
        completionHandler([.alert, .badge, .sound])
    }
    
    func handlePushNotification(userInfo : JSON){
        print("handlePushNotification")
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let aps = userInfo["aps"]
        
        if aps != .null {
            
            var pushType = aps["push_type"].intValue
            let payLoad = userInfo["payload"]
            var from_user_id = payLoad["from_user_id"].stringValue
            var sender_name = payLoad["sender_name"].stringValue
            var objectID = payLoad["data"]["object_id"].stringValue
            
            if pushType == 0 {
                pushType = userInfo["push_type"].intValue
            }
            
            if objectID == "" {
                objectID = userInfo["object_id"].stringValue
            }
            
            if from_user_id == "" {
                from_user_id = userInfo["from_user_id"].stringValue
            }
            
            if sender_name == "" {
                sender_name = userInfo["sender_name"].stringValue
            }
            
            switch pushType {
            case 1 :
                print("Push Type 1")
                self.openChatDetaild(objectId: objectID, from_user_id: from_user_id, sender_name: sender_name, profileImage: userInfo["sender_profile"].stringValue)
                
            default :
                break
            }
        }
    }
    
    func openChatDetaild(objectId: String, from_user_id: String, sender_name: String, profileImage : String) {
        
        GeneralUtility().addButtonTapHaptic()
        
        let vc: ChatDetailsVC = ChatDetailsVC.instantiate(appStoryboard: .Chat)
        vc.chatVM.otherUserID = from_user_id
        let otherUSer = ModelOtherUserProfile(fromJson: .null)
        otherUSer.id = (from_user_id as NSString).integerValue
        otherUSer.name = sender_name
        otherUSer.profileImage = profileImage
        vc.otherUserObj = otherUSer
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
}


// MARK: APP NAV STACK
extension AppDelegate {
    
    func checkMode(){
        if UserDefaults.standard.string(forKey: "mode") == "dark"{
            self.window?.overrideUserInterfaceStyle = .dark
        }else{
            self.window?.overrideUserInterfaceStyle = .light
        }
    }
    
    
    func setDefualtNavigationForapp() {
        if NextgenUser.shared.token == "" {
            self.setLoginScreen()
        } else {
            let vc: LaunchDashboardVC = LaunchDashboardVC.instantiate(appStoryboard: .Home)
            let win = self.window ?? UIApplication.shared.windows.first
            win!.rootViewController = vc
            win!.makeKeyAndVisible()
        }
    }
    
    func setLoginScreen() {
        NextgenUser.shared.clear()
        
        let vc: LaunchVc = LaunchVc.instantiate(appStoryboard: .main)
        let win = self.window ?? UIApplication.shared.windows.first
        
        if(win != nil){
            UIView.transition(with: win!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                let nav:UINavigationController = UINavigationController(rootViewController: vc)
                nav.isNavigationBarHidden = true
                
                win!.rootViewController = nav
                
                win!.makeKeyAndVisible()
                
                
            }, completion: { completed in
                
            })
        } else {
            
        }
    }
    
    func setHomeRoot() {
        let vc = TabHome()
        let win = self.window ?? UIApplication.shared.windows.first
        let nav: UINavigationController = UINavigationController(rootViewController: vc)

        if(win != nil){
            UIView.transition(with: win!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                nav.isNavigationBarHidden = true
                win!.rootViewController = nav
                win!.makeKeyAndVisible()
                
            }, completion: { completed in
                
            })
        }
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        fcmRegTokenMessage  = "\(fcmToken ?? "")"
        FirestoreCommonMethod.shared.savePushTokens(token: appDelegate.fcmRegTokenMessage)
    }
    
    func getFCMToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.fcmRegTokenMessage  = "\(token)"
                FirestoreCommonMethod.shared.savePushTokens(token: appDelegate.fcmRegTokenMessage)
            }
        }
    }
    
}


extension AppDelegate {
    
    func appVersionChecker() {
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        var peraDic = [String:Any]()
        peraDic["type"] = "ios"
        peraDic["version"] = appVersion
        peraDic[kDeviceID] = (UIDevice.current.identifierForVendor?.uuidString ?? "")
        print(peraDic)
        
        ServiceManager.shared.postRequest(ApiURL: .VersionChecker, parameters: peraDic, isShowErrorAlerts: false) { response, isSuccess, error, statusCode in
            
            let is_force_update = response["data"]["is_force_update"].stringValue
            if statusCode == 412 {
                DispatchQueue.main.async {
                    if(is_force_update == "1"){
                        showAppUpdatePopup(isForceUpdate: true, Message: error)
                    }
                    else{
                        showAppUpdatePopup(isForceUpdate: false, Message: error)
                    }
                }
            }
            
        } Failure: { response, isSuccess, error, statusCode in
            
            let is_force_update = response["data"]["is_force_update"].stringValue
            if statusCode == 412 {
                DispatchQueue.main.async {
                    if(is_force_update == "1"){
                        showAppUpdatePopup(isForceUpdate: true, Message: error)
                    }
                    else{
                        showAppUpdatePopup(isForceUpdate: false, Message: error)
                    }
                }
            }
        }
    }
}
