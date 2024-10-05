//
//  CreatePostVC.swift
//  Nextgen
//
//  Created by Himanshu Visroliya on 20/08/22.
//

import UIKit
import AVKit
import Photos

struct selectVideoImage {
    var thumbImage : UIImage
    var sendToAPI : MultiPartDataType
    var thumbImageData : MultiPartDataType? = nil
    var isChanged : Bool = false
    var isVideo : Bool = false
}

class CreatePostVC: UIViewController {
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var collectionMedia: UICollectionView!
    @IBOutlet weak var postBtn:UIButton!
        
    
    //MARK: - VARIABLES
    var arrMedia : [selectVideoImage] = []{
        didSet {
            collectionMedia.reloadData()
        }
    }
    
    var picker = UIImagePickerController();
    var mediaTypes = ["public.image" ,"public.movie"]
    var selectedImage = UIImage()
    var isEditPostID = 0
    
    
    //MARK: - VIEWCONTROlLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionMedia.registerCell(type: AddMediaCVC.self)
        collectionMedia.setDefaultProperties(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        arrMedia.removeAll()
        txtDescription.text = ""
        setupUI()
    }
    
    func setupUI(){
        if let editPost = AppShare.shared.singlePost {
            isEditPostID = editPost.id
            txtDescription.text = editPost.descriptionField
            
            
            AppShare.shared.singlePost = nil
        }
    }
    
    //MARK: - BUTTON ACTIONS
    @IBAction func btnAddPhotoClick(_ sender: Any) {
        addImageVideo(type: 1)
    }
    
    @IBAction func btnCameraClicks(_ sender: Any) {
        addImageVideo(type: 0)
    }
    
    @IBAction func btnCreatePostClicks(_ sender: Any) {
        WSCreatePost()
    }
}

//MARK: - UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CreatePostVC  : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            return arrMedia.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMediaCVC", for: indexPath) as! AddMediaCVC
        
        if indexPath.section == 0 {
            cell.viewAddMedia.isHidden = false
        }else {
            cell.viewAddMedia.isHidden = true
            cell.imgMedia.image = arrMedia[indexPath.row].thumbImage
            
            cell.deleteCloser = {
                CommonClass().showAlertWithTitleFromVC(vc: self, title: Constant.APP_NAME, andMessage: "Are you sure want to delete this media?".localized, buttons: ["Yes".localized , "No".localized]) { index in
                    
                    if index == 0 {
                        self.arrMedia.remove(at: indexPath.row)
                        
                        collectionView.reloadData()
                    }
                }
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            addImageVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
        return .zero
    }
}

//MARK: - GENERAL METHOD
extension CreatePostVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// - Parameter  type: 0 - camera , 1 gallery
    func addImageVideo(type : Int? = nil)  {
        
        if self.arrMedia.count >= 5 {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: "You can upload maximum 5 videos/images in a single post".localized)
            return
        }
        
        picker.mediaTypes = mediaTypes
        picker.videoMaximumDuration = 30.0
        picker.delegate = self

        if let type = type{
            if type == 0 {
                cameraAuthorization()
            }else {
                openGallery()
            }
        }else {
            let alert = UIAlertController(title: "Choose image/Video".localized, message: nil, preferredStyle: .actionSheet)

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
            
            alert.addAction(cameraAction)
            alert.addAction(galleryAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }
        
    }
    
    func cameraAuthorization() {
        DispatchQueue.main.async {
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
            if(UIImagePickerController .isSourceTypeAvailable(.camera)){
                self.picker.sourceType = .camera
                self.picker.allowsEditing = false
                self.picker.cameraDevice = .front
                
                //to stop parent viewcontroller dismiss
                self.definesPresentationContext = true
                self.picker.modalPresentationStyle = .overFullScreen
                self.present(self.picker, animated: true, completion: nil)
            } else {
                CommonClass.sharedInstance.showAlertWithTitleFromVC(vc: self, andMessage: "You don't have camera".localized)
            }
        }
    }
    
    func openGallery() {
        DispatchQueue.main.async {
            PHPhotoLibrary.requestAuthorization { result in
                
                if result == .authorized {
                    DispatchQueue.main.async {
                        self.picker.sourceType = .photoLibrary
                        self.picker.allowsEditing = false
                        self.present(self.picker, animated: true, completion: nil)
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
            let alert = UIAlertController(title: Constant.APP_NAME, message: "Please allow your ".localized + type + "setting to capture or select image for further process.".localized, preferredStyle: .alert)

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
            
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
        
            if mediaType  == "public.image" {
                
                var img = UIImage()
                if let image = info[.editedImage] as? UIImage {
                    img = image
                }else if let image = info[.originalImage] as? UIImage {
                    img = image
                }
                selectedImage = img
                
                let apiData = MultiPartDataType(mimetype: "image/jpeg", fileName: "swift.jpeg", fileData: img.jpegData(compressionQuality: 0.5), keyName: "file[\(self.arrMedia.count)]")
                self.arrMedia.append(selectVideoImage(thumbImage: img, sendToAPI: apiData, isChanged: true, isVideo: false))

            }
            
            if mediaType == "public.movie" {
                //video
                let videoToCompress = info[UIImagePickerController.InfoKey.mediaURL] as? URL
                
                if let url = videoToCompress , let img = url.generateThumbnail() {
                    
                    guard let compressedData = NSData(contentsOf: url) else { return }

                    let apiData = MultiPartDataType(mimetype: "video/mp4", fileName: "video.mp4", fileData: compressedData as Data, keyName: "file[\(self.arrMedia.count)]")
                    let apiThumbData = MultiPartDataType(mimetype: "image/jpeg", fileName: "swift.jpeg", fileData: img.jpegData(compressionQuality: 0.5), keyName: "thumb_image[\(self.arrMedia.count)]")
                    
                    self.arrMedia.append(selectVideoImage(thumbImage: img, sendToAPI: apiData, thumbImageData: apiThumbData, isChanged: true, isVideo: true))
                }
            }
        }
    }
}


extension CreatePostVC {
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        SHOW_CUSTOM_LOADER()
        exportSession.exportAsynchronously { () -> Void in
            self.HIDE_CUSTOM_LOADER()
            handler(exportSession)
        }
    }
}

//MARK: - API call
extension CreatePostVC {
    
    func WSCreatePost() {
        if (arrMedia.count == 0) && (txtDescription.text!.isEmpty) {
            GeneralUtility().showErrorMessage(message: "Please select video/image or enter description to create post".localized)
            return
        }
        var parameters:[String:Any] = ["description" : txtDescription.text!]

        var apiURL: ApiURL = .postCreate
        if isEditPostID > 0 {
            parameters["id"] = isEditPostID
            apiURL = .editPost
        }
        
        parameters["is_video"] = "0"
        if (arrMedia.count > 0), arrMedia.filter({$0.isVideo}).count == arrMedia.count {
            parameters["is_video"] = "1"
        }
        
        var arrAPIMedia = self.arrMedia.map({$0.sendToAPI})
        arrAPIMedia.append(contentsOf: self.arrMedia.compactMap({$0.thumbImageData}))
        
        let cView = CustomActivityView(text: "Sending...")
        view.addSubview(cView)
        postBtn.isEnabled = false
        ServiceManager.shared.postMultipartRequest(ApiURL: apiURL, imageVideoParameters: arrAPIMedia, parameters: parameters) { response, isSuccess, error, statusCode in
            
            cView.removeFromSuperview()
            self.postBtn.isEnabled = true
            appDelegate.setHomeRoot()
        } Failure: { response, isSuccess, error, statusCode in
            //fail
            cView.removeFromSuperview()
            self.postBtn.isEnabled = true
        }
    }
    
}

extension URL {
    
    func generateThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            // Swift 5.3
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)

            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)

            return nil
        }
    }

}
