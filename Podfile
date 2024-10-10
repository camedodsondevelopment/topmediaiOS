# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Nextgen' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Nextgen
  pod 'Firebase/Auth'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseDynamicLinks'
  pod 'FirebaseFirestore'
  pod 'FirebaseMessaging'
  pod 'FirebaseDatabase'
  pod 'FBSDKLoginKit'
  pod 'AEOTPTextField'
  pod 'Alamofire', '~> 5.2'
  pod 'IQKeyboardManagerSwift'
  pod 'SwiftyJSON'
  pod 'CropViewController'
  pod 'SKCountryPicker'
  pod 'Haptico'
  pod 'lottie-ios'
  pod 'SDWebImage', '~> 5.0'
  pod 'NewPopMenu'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'Lightbox'
  pod 'GoogleSignIn'
  pod 'GSPlayer'
  pod 'AgoraRtcEngine_iOS'
  
end

# Set the minimum deployment target for all pods to iOS 13
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
