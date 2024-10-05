//
//  CurrentLocationManager.swift
//  LocationManagerDemo
//
//  Created by Mac 3 on 07/12/21.
//

import Foundation
import UIKit
import CoreLocation

final class LocationManager: NSObject {
    
    enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
        case unknown = "Some Unknown Error occurred"
    }
    
    typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    private var locationCompletionHandler: LocationClosure?
    
    typealias ReverseGeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    private var geoLocationCompletionHandler: ReverseGeoLocationClosure?
    
    private var locationManager:CLLocationManager?
    var locationAccuracy = kCLLocationAccuracyBest
    
    var myCurrentLattitude: NSNumber = 0.0
    var myCurrentLongitude: NSNumber = 0.0
    var checkWheatherUserDenied: Bool = true
    
    private var lastLocation:CLLocation?
    private var reverseGeocoding = false
    var lastAuthStatus: CLAuthorizationStatus = .denied
    
    //Singleton Instance
    static let shared: LocationManager = {
        let instance = LocationManager()
        // setup code
        return instance
    }()
    
    private override init() {}
    
    //MARK:- Destroy the LocationManager
    deinit {
        destroyLocationManager()
    }
    
    //MARK:- Private Methods
    func setupLocationManager() {
        
        //Setting of location manager
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
    }
    
    private func destroyLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
        lastLocation = nil
    }
    
    @objc private func sendPlacemark() {
        guard let _ = lastLocation else {
            
            self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            
            lastLocation = nil
            return
        }
        
        self.reverseGeoCoding(location: lastLocation)
        lastLocation = nil
    }
    
    @objc private func sendLocation() {
        guard let _ = lastLocation else {
            self.didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            lastLocation = nil
            return
        }
        self.didComplete(location: lastLocation,error: nil)
        lastLocation = nil
    }
    
    //MARK:- Public Methods
    
    /// Check if location is enabled on device or not
    ///
    /// - Parameter completionHandler: nil
    /// - Returns: Bool
    func isLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    /// Get current location
    ///
    /// - Parameter completionHandler: will return CLLocation object which is the current location of the user and NSError in case of error
    func getLocation(completionHandler:@escaping LocationClosure) {
        
        //Resetting last location
        lastLocation = nil
        
        self.locationCompletionHandler = completionHandler
        
        setupLocationManager()
    }
    
    
    /// Get Reverse Geocoded Placemark address by passing CLLocation
    ///
    /// - Parameters:
    ///   - location: location Passed which is a CLLocation object
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the CLLocation and NSError in case of error
    func getReverseGeoCodedLocation(location:CLLocation,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(location: location)
        }
        
    }
    
    /// Get Latitude and Longitude of the address as CLLocation object
    ///
    /// - Parameters:
    ///   - address: address given by the user in String
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the address entered and NSError in case of error
    func getReverseGeoCodedLocation(address:String,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(address: address)
        }
    }
    
    /// Get current location with placemark
    ///
    /// - Parameter completionHandler: will return Location,Placemark and error
    func getCurrentReverseGeoCodedLocation(completionHandler:@escaping ReverseGeoLocationClosure) {
        
        if !reverseGeocoding {
            
            reverseGeocoding = true
            
            //Resetting last location
            lastLocation = nil
            
            self.geoLocationCompletionHandler = completionHandler
            
            setupLocationManager()
        }
    }
    
    //MARK:- Reverse GeoCoding
    private func reverseGeoCoding(location:CLLocation?) {
        CLGeocoder().reverseGeocodeLocation(location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                  NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
             NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                if let _ = location {
                    self.didCompleteGeocoding(location: location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                            [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                      NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    private func reverseGeoCoding(address:String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                  NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
             NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                if let placemark = placemarks?[0] {
                    self.didCompleteGeocoding(location: placemark.location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                            [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                      NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //MARK:- Final closure/callback
    private func didComplete(location: CLLocation?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        locationCompletionHandler?(location,error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    private func didCompleteGeocoding(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        geoLocationCompletionHandler?(location,placemark,error)
        locationManager?.delegate = nil
        locationManager = nil
        reverseGeocoding = false
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0] as CLLocation
        
        myCurrentLattitude = NSNumber(value: userLocation.coordinate.latitude)
        myCurrentLongitude = NSNumber(value: userLocation.coordinate.longitude)
        
        print("user Home latitude = \(userLocation.coordinate.latitude)")
        print("user Home longitude = \(userLocation.coordinate.longitude)")
        
        lastLocation = locations.last
        if let location = locations.last {
            let locationAge = -(location.timestamp.timeIntervalSinceNow)
            if (locationAge > 5.0) {
                print("old location \(location)")
                return
            }
//            if location.horizontalAccuracy < 0 {
//                self.locationManager?.stopUpdatingLocation()
//                self.locationManager?.startUpdatingLocation()
//                return
//            }
            if self.reverseGeocoding {
                self.sendPlacemark()
            } else {
                self.sendLocation()
            }
        }
    }
    
//    func mangeLocationPopup(isFromForeground: Bool = false) {
//        if LocationManager.shared.isLocationEnabled() {
//            switch LocationManager.shared.getCurrentAuthStatus() {
//            case .denied:
//                print("denied")
//                showAppUpdatePopup()
//            case .notDetermined:
//                print("notDetermined")
//                showAppUpdatePopup()
//            case .restricted:
//                print("restricted")
//                showAppUpdatePopup()
//            case .authorizedAlways:
//                print("authorizedAlways")
////                if !isFromForeground {
////                    showAppUpdatePopup()
////                }
//            case .authorizedWhenInUse:
//                print("authorizedWhenInUse")
////                if !isFromForeground {
////                    showAppUpdatePopup()
////                }
//            @unknown default:
//                print("default")
//                showAppUpdatePopup()
//            }
//        } else {
//            showAppUpdatePopup()
//        }
//    }
    
    func getCurrentAuthStatus() -> CLAuthorizationStatus {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            checkWheatherUserDenied = true
            self.lastAuthStatus = .denied
            return .denied
        case .notDetermined:
            checkWheatherUserDenied = true
            self.lastAuthStatus = .notDetermined
            return .notDetermined
        case .restricted:
            checkWheatherUserDenied = true
            self.lastAuthStatus = .restricted
            return .restricted
        case .authorizedAlways:
            checkWheatherUserDenied = false
            self.lastAuthStatus = .authorizedAlways
            return .authorizedAlways
        case .authorizedWhenInUse:
            checkWheatherUserDenied = false
            self.lastAuthStatus = .authorizedWhenInUse
            return .authorizedWhenInUse
        @unknown default:
            checkWheatherUserDenied = true
            self.lastAuthStatus = .denied
            return .denied
        }
    }
    
    func goAppSettingForLocationSetting() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.lastAuthStatus = status
        switch status {
            
        case .authorizedWhenInUse,.authorizedAlways:
            self.locationManager?.startUpdatingLocation()
            
        case .denied:
            let deniedError = NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.denied.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.denied.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.denied.rawValue])
            
            if reverseGeocoding {
                didCompleteGeocoding(location: nil, placemark: nil, error: deniedError)
            } else {
                didComplete(location: nil,error: deniedError)
            }
            
        case .restricted:
            if reverseGeocoding {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code: Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            } else {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code: Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            }
            
        case .notDetermined:
            self.locationManager?.requestLocation()
            
        @unknown default:
            didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.unknown.rawValue,
              NSLocalizedFailureReasonErrorKey:LocationErrors.unknown.rawValue,
         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.unknown.rawValue]))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        self.didComplete(location: nil, error: error as NSError?)
    }
    
}
