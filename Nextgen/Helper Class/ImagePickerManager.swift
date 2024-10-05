//
//  ImagePickerManager.swift
//  Youunite
//
//  Created by Mac on 11/12/20.
//  Copyright © 2020 ZestBrains PVT LTD. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CropViewController

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image".localized, message: nil, preferredStyle: .actionSheet)
    var isRoundSqaure = true
    var isForFront = false
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    
    override init(){
        super.init()
        let cameraAction = UIAlertAction(title: "Camera".localized, style: .default){
            UIAlertAction in
            self.cameraAuthorization()
        }
        let galleryAction = UIAlertAction(title: "Gallery".localized, style: .default){
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel){
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
//        alert.view.tintColor = UIColor.appColor
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }
    
    func pickImage(_ viewController: UIViewController, isForFront: Bool = false, isRoundSqaure: Bool = false, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        self.isForFront = isForFront
        self.isRoundSqaure = isRoundSqaure
        if !self.isForFront {
            alert.popoverPresentationController?.sourceView = self.viewController!.view
            viewController.present(alert, animated: true, completion: nil)
            
        } else {
            self.cameraAuthorization()
        }
    }
    
    func cameraAuthorization() {
        
        DispatchQueue.main.async {
            self.alert.dismiss(animated: true, completion: nil)
            
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            switch (authStatus){
            
            case .restricted, .denied:
                self.showPermisionAlert(type: "Camera")
                
            case .authorized:
                self.cameraOpen()
                
            case .notDetermined:
                print("notDetermined")
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //access allowed
                        self.cameraOpen()
                    } else {
                        //access denied
                        self.cameraAuthorization()
                    }
                })
                
            @unknown default:
                print("notDetermined")
            }
        }
    }
    
    func cameraOpen(){
        DispatchQueue.main.async {
            self.alert.dismiss(animated: true, completion: nil)
            if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                self.picker.sourceType = .camera
                self.picker.allowsEditing = false
                if self.isForFront {
                    self.picker.cameraDevice = .front
                }
                //to stop parent viewcontroller dismiss
                self.viewController!.definesPresentationContext = true
                self.picker.modalPresentationStyle = .overFullScreen
                self.viewController!.present(self.picker, animated: true, completion: nil)
            } else {
                CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: self.viewController!, andMessage: "You don't have camera".localized)
            }
        }
    }
    
    func openGallery() {
        DispatchQueue.main.async {
            self.alert.dismiss(animated: true, completion: nil)
            PHPhotoLibrary.requestAuthorization { [weak self] result in
                guard let self = self else { return }
                if result == .authorized {
                    DispatchQueue.main.async {
                        self.picker.sourceType = .photoLibrary
                        self.picker.allowsEditing = false
                        //to stop parent viewcontroller dismiss
                        self.viewController!.present(self.picker, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showPermisionAlert(type:"photo gallery")
                    }
                }
            }
        }
    }
    
    func showPermisionAlert(type:String) {
        
        DispatchQueue.main.async {
            self.alert = UIAlertController(title: Constant.APP_NAME, message: "Please allow your ".localized + type + "setting to capture or select image for further process.".localized, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings".localized, style: .default) { (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            
            self.alert.addAction(settingsAction)
            self.alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
            self.viewController?.present(self.alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let chosenImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage ?? UIImage()
        picker.dismiss(animated: true, completion: nil)
        
        if self.isRoundSqaure {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                let cropController = CropViewController(croppingStyle: .circular, image: chosenImage)
                cropController.delegate = self
                
                if #available(iOS 13.0, *) {
                    cropController.modalPresentationStyle = .fullScreen
                }
                
                self.viewController?.present(cropController, animated: true, completion: nil)
            }
        } else {
            self.pickImageCallback?(chosenImage.wxCompress())
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
}

extension ImagePickerManager : CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        cropViewController.dismiss(animated: true, completion: {
            let squareImg = self.makeRoundImg(img: image)
            self.pickImageCallback?(squareImg.wxCompress())
        })
    }
    
    func makeRoundImg(img: UIImage) -> UIImage {
        let imageV = UIImageView.init(image: img)
        let imgLayer = CALayer()
        imgLayer.frame = imageV.bounds
        imgLayer.contents = imageV.image?.cgImage
        imgLayer.masksToBounds = true

        imgLayer.cornerRadius = imageV.frame.size.width / 2

        UIGraphicsBeginImageContext(imageV.bounds.size)
        imgLayer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
}
