//
//  EditProfileVC.swift
//  Nextgen
//
//  Created by jacky on 12/09/22.
//

import UIKit
import SwiftyJSON
import SKCountryPicker
import MediaPlayer


class EditProfileVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var countryViewNew: UIView!
    
    
    @IBOutlet weak var imgUserBG: UIImageView!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var aboutLbl: UILabel!
    
    @IBOutlet weak var bioTextView:UITextView!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var dob:UITextField!
    
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var txtMobile: UITextField!
    
    @IBOutlet weak var publicBtn: UISwitch!
    @IBOutlet weak var privateBtn: UISwitch!
    

    // MARK: - VARIABLES
    var isProfileImageChangd : Bool = false
    var isBGImageChangd : Bool = false
    var selectedCountryInd : Int = 0
    var isPublicProfile : Bool = true
    var countryShortCode : String = "US"
    var audioPlayer: AVAudioPlayer?
    var destinationUrl:URL? = nil

    //MARK: - VIEWCONTROller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialUI()
        let countryTap = UITapGestureRecognizer(target: self, action: #selector(countyTap_))
        countryViewNew.addGestureRecognizer(countryTap)
        countryViewNew.isUserInteractionEnabled = true
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgUserBG.isUserInteractionEnabled = true
        imgUserBG.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func countyTap_(){
        GeneralUtility().addButtonTapHaptic()
    }
    
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismissVC()
    }
    
    @IBAction func btnNextTapped(_ sender: UIButton) {
        GeneralUtility().addButtonTapHaptic()
        
        if validateData() {
            self.WSEditProfile()
        }
    }
    
    @IBAction func changeBGPressed(_ sender: UIButton) {
        changeBG()
    }
    
    @objc  func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        changeBG()
    }
    
    func changeBG(){
        GeneralUtility().addButtonTapHaptic()
        ImagePickerManager().pickImage(self) { img in
            self.isBGImageChangd = true
            self.imgUserBG.image = img
        }
    }
    
    @IBAction func btnChangeProfileImageClick(_ sender: Any) {
        GeneralUtility().addButtonTapHaptic()
        ImagePickerManager().pickImage(self) { img in
            self.isProfileImageChangd = true
            self.imgProfile.image = img
        }
    }
    
    @IBAction func btnPublicClicks(_ sender: Any) {
        setPublicPrivate(isPublic: true)
    }
    
    @IBAction func btnPrivateClicks(_ sender: Any) {
        setPublicPrivate(isPublic: false)
    }
    
    @IBAction func btnCountryPickerClicks(_ sender: Any) {
        
        CountryPickerWithSectionViewController.presentController(on: self, configuration: { countryController in
            countryController.configuration.flagStyle = .circular
            
        }) { [weak self] country in
            
            guard let self = self else { return }
            self.lblCountryCode.text = country.dialingCode ?? ""
            self.countryShortCode = country.countryCode
        }
    }
    
    @IBAction func openMusicClicks(_ sender: UIButton) {
        openDocumentPicker()
    }

}

//MARK: - GENERAL FUNCTIONS
extension  EditProfileVC {
    
    func setInitialUI() {
        bioTextView.layer.cornerRadius = 10
        txtName.delegate = self
        txtUsername.delegate = self
        bindData()
    }

    func setPublicPrivate(isPublic : Bool) {
        isPublicProfile = isPublic
        
        if isPublic {
            publicBtn.isOn = true
            privateBtn.isOn = false
        }else {
            publicBtn.isOn = false
            privateBtn.isOn = true
        }
    }
    
    private func bindData() {
        let obj = NextgenUser.shared
        
        GeneralUtility().setImageWithSDWEBImage(imgView: imgProfile, placeHolderImage: placeholderImage, imgPath: obj.profileImage)
        GeneralUtility().setImageWithSDWEBImage(imgView: imgUserBG, placeHolderImage: nil, imgPath: obj.backgroundImage)

        isPublicProfile = (obj.profileViewing == "public")
        setPublicPrivate(isPublic: isPublicProfile)
        
        txtName.text = obj.name
        aboutLbl.text = obj.about
        username.text = obj.name + obj.username
        txtEmail.text = obj.email
        txtUsername.text = obj.username
        dob.text = obj.dateOfBirth
        bioTextView.text = obj.about

        if let countryInd = arrCountry.firstIndex(where: {$0.code.lowercased() == obj.countryShortCode.lowercased()}) {
            self.selectedCountryInd = countryInd
        }
        
        countryShortCode = obj.countryIsoCode
        lblCountryCode.text = obj.countryCode == "" ? "+1" : obj.countryCode
        txtMobile.text = obj.mobile
        
        txtName.textColor = UIColor(named: "tabbarSelected")
        txtEmail.textColor = UIColor(named: "tabbarSelected")
        txtUsername.textColor = UIColor(named: "tabbarSelected")
        dob.textColor = UIColor(named: "tabbarSelected")
        bioTextView.textColor = UIColor(named: "tabbarSelected")

    }

}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension EditProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCountry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTVC") as? CountryTVC {
            cell.lblName.text = arrCountry[indexPath.row].name
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountryInd = indexPath.row
    }
    
}

//MARK: - GENERAL METHOD
extension EditProfileVC {
    
    func WSEditProfile() -> Void {
        audioPlayer?.stop()
        self.startActivityIndicator()
        let Parameter : [String:Any] = [
            "profile_viewing" : isPublicProfile ? "public" : "private",
            "about" : bioTextView.text ?? "",
            "name" : txtName.text ?? "",
            "email" : txtEmail.text ?? "",
            "dob" : dob.text ?? "",
            "username" : txtUsername.text ?? "",
            "country_code_short" : arrCountry[selectedCountryInd].code,
            "country_iso_code" : countryShortCode,
            "mobile" : txtMobile.text ?? "",
            "country_code" : lblCountryCode.text ?? "",
        ]

        var arrIMGDATA : [MultiPartDataType] = []
        
        if isBGImageChangd {
            arrIMGDATA.append(MultiPartDataType(mimetype: "image/jpeg", fileName: "profileBGImg.jpeg", fileData: imgUserBG.image?.jpegData(compressionQuality: 0.5), keyName: "background_image"))
        }
        
        if isProfileImageChangd {
            arrIMGDATA.append(MultiPartDataType(mimetype: "image/jpeg", fileName: "profileImg.jpeg", fileData: imgProfile.image?.jpegData(compressionQuality: 0.5), keyName: "profile_image"))
        }
        
        if let audioURL = destinationUrl {
            do {
                let audioData = try Data(contentsOf: audioURL)
                arrIMGDATA.append(MultiPartDataType(mimetype: "audio/m4a", fileName: "profileSong", fileData: audioData, keyName: "audio_file"))
            } catch {
                print("Unable to load data: \(error)")
            }
            
        }
        
        ServiceManager.shared.postMultipartRequest(ApiURL: .editProfile, imageVideoParameters: arrIMGDATA , parameters: Parameter) { (response, isSuccess, message, statuscode) in
            
            if isSuccess == true{
                self.isProfileImageChangd = false
                self.isBGImageChangd = false
                NextgenUser.shared.setData(dict: response["data"])
                self.navigationController?.popViewController(animated: true)
                self.dismissVC()
            }
            
            print("Sucess", (response, isSuccess, message, statuscode))
            self.stopActivityIndicator()
            
        } Failure: { (response, isSuccess, message, statuscode) in
            print("Failure", (response, isSuccess, message, statuscode))
            self.stopActivityIndicator()
        }
    }
    
}

extension EditProfileVC {
    
    // TODO: Validation
    func validateData() -> Bool {
        guard (txtEmail.text?.removeWhiteSpace().count)! > 0  else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.EmailNameMissing)
            return false
        }
        
        guard (txtEmail.text)!.removeWhiteSpace().isEmail() else
        {
            CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.ValidEmail)
            return false
        }
        
        if let dobString = dob.text {
            let dobArray = dobString.components(separatedBy: "-")
            var date:Int = 0
            var month:Int = 0
            if dobArray.count == 3 {
                date = Int(dobArray[2]) ?? 0
                month = Int(dobArray[1]) ?? 0
            }else{
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.dobMissing)
                return false
            }
            
            if month == 0 {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.monthValidate)
                return false
            }
            
            if date == 0 {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.dateValidate)
                return false
            }
            
            if month > 12 {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.monthValidate)
                return false
            }
            
            if date > 31 {
                CommonClass().showAlertWithTitleFromVC(vc: self, andMessage: AlertMessage.dateValidate)
                return false
            }
        }
        
        
        return true
    }
    
}

//MARK: - GENERAL METHOD
extension EditProfileVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        if textField == txtMobile {
            textField.text = GeneralUtility.sharedInstance.format(with: "XXX-XXX-XXXX", phone: newString)
            return false
        }
        
        if textField == dob {
            textField.text = GeneralUtility.sharedInstance.format(with: "XXXX-XX-XX", phone: newString)
            return false
        }
        
        if textField == txtName {
            if string == " " {
                return false
            }
        }
        
        if textField == txtUsername {
            if string == " " {
                return false
            }
        }
        
        return true
    }
}

extension EditProfileVC: UIDocumentPickerDelegate {
    func openDocumentPicker() {
        var documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [UTType.audio]
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: UIDocumentPickerMode.import)
        }
        documentPicker.delegate = self
        // set popover controller for iPad
        if let popoverController = documentPicker.popoverPresentationController {
            popoverController.sourceView = self.view //set your view name here
        }
        present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let _ = url.startAccessingSecurityScopedResource()
        let asset = AVURLAsset(url: url)
        guard asset.isComposable else {
            print("Your music is Not Composible")
            return
        }
        addAudio(audioUrl: url)
    }

    func addAudio(audioUrl: URL) {
        // lets create your destination file url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        guard let destinationUrl = destinationUrl else { return }
        print(destinationUrl)
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            self.playMusic(url: destinationUrl)
        } else {
            // if the file doesn't exist you can use NSURLSession.sharedSession to download the data asynchronously
            print("Downloading...")
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    self.playMusic(url: destinationUrl)
                    
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                    
                }
            }).resume()
        }
    }

    func playMusic(url: URL) {
        if let player = audioPlayer, player.isPlaying {
            audioPlayer?.stop()
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
