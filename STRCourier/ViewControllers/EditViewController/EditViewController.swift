import UIKit
import PhoneNumberKit
import Crashlytics
import Cloudinary

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EditViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,  UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate{
    @IBOutlet var vwSave: UIView!
        @IBOutlet var bottomLayout: NSLayoutConstraint!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet var lastNmaeText: B68UIFloatLabelTextField!
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var countryCodeText: UITextField!
    
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet var pickerView : UIPickerView?
    let phoneNumberKit = PhoneNumberKit()
     var currentView : UITextField?
    
    let imagePicker = UIImagePickerController()
  
    var removeLocally : Bool! = false
    var selectedImage : UIImage?
    var dataArrayObj : [Dictionary<String,AnyObject>]?
    var dataSortValue : NSArray?
    var sortCountryCode : String?
    var responseData : ((Dictionary<String,AnyObject>)->())?
    var countryArray : NSArray?
    var isImageChanged : Bool?
    var config:CLDConfiguration!
    var cloudinary: CLDCloudinary!
    var profileURL:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        config = CLDConfiguration(cloudName:"drvjylp2e")
        cloudinary = CLDCloudinary(configuration: config)
         isImageChanged = false
        profileURL = ""
        self.sortCountryCode = ""
        self.title = "Edit Profile"
        customizeNavigationforAll(self)
        self.navigationController?.navigationBar.isTranslucent = false
        imagePicker.delegate = self
    
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 200)
       // getUSerProfile()
        getCountries()
        setUpFont()
        addKeyboardNotifications()
        self.setUserDetail()
    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0, animations: { () -> Void in
                self.bottomLayout.constant = keyboardFrame.size.height
        }, completion: { (completed: Bool) -> Void in
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0, animations: { () -> Void in
             self.bottomLayout.constant = 0.0
        }, completion: { (completed: Bool) -> Void in
            
        }) 
    }
    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    func setUpFont()
    {
        self.vwSave.layer.cornerRadius = 5.0
        nameLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        btnSave.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);
        passwordText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        confirmText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        emailText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        nameText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        lastNmaeText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        countryCodeText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        phoneText.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Regular", size: 14.0)! // Note the !
        ]
        passwordText.attributedPlaceholder = NSAttributedString(string: "NEW PASSWORD", attributes:attributes)
        confirmText.attributedPlaceholder = NSAttributedString(string: "CONFIRM PASSWORD", attributes:attributes)
        emailText.attributedPlaceholder = NSAttributedString(string: "EMAIL", attributes:attributes)
        nameText.attributedPlaceholder = NSAttributedString(string: "FIRST NAME", attributes:attributes)
        lastNmaeText.attributedPlaceholder = NSAttributedString(string: "FIRST NAME", attributes:attributes)
        countryCodeText.attributedPlaceholder = NSAttributedString(string: "PHONE", attributes:attributes)
        phoneText.attributedPlaceholder = NSAttributedString(string: "", attributes:attributes)
    }
    override func viewDidAppear(_ animated: Bool) {
         NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UPDATEPROFILENOTIFICATION"), object: nil))
    }
   
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        // Do any additional setup after loading the view
        scrollView.contentSize = CGSize(width: view.frame.width,  height: view.frame.height + 200)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }

    
    @IBAction func onClickSaveButton(_ sender: AnyObject) {
        
//        if removeLocally == true {
//            deleteImage()
//        }
        
        if isValidate() {
            
            if(self.isImageChanged)!
             {
             self.imageUploadToCloudinary(successBlock: {
                self.updateUserProfile()
             }, errorBlock: {
             utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Error uploading profile image", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
             })
             }
             else{
             self.updateUserProfile()
             }
        }
        
    }
    
    func updateUserProfile() {
        
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
                var paramDict: Dictionary<String,String>?
        if(self.isImageChanged)! && !removeLocally
        {
            paramDict = ["given_name":nameText.text!, "family_name":lastNmaeText.text!, "MobileNumber" : phoneText.text!, "MobileCode": self.sortCountryCode!, "picture" : self.profileURL!]
        }
        else if removeLocally == true
        {
            paramDict = ["given_name":nameText.text!, "family_name":lastNmaeText.text!, "MobileNumber" : phoneText.text!, "MobileCode": self.sortCountryCode!,"picture":"0"]
            self.removeLocally = false
            
        }
        else
            
        {
            paramDict = ["given_name":nameText.text!, "family_name":lastNmaeText.text!, "MobileNumber" : phoneText.text!, "MobileCode": self.sortCountryCode!]
        }
       
        
        
        generalApiobj.hitApiwith(paramDict as! Dictionary<String, AnyObject>, serviceType: .strUpdateUserProfile, success: { (response) in
            DispatchQueue.main.async {
                
                let dataMessage = response["message"] as? String
                
                if dataMessage == "OK" {
                    
                   let dataDictionary = response["data"] as! Dictionary<String,AnyObject>?
                    let firstName = dataDictionary!["given_name"] as! String
                    let lastName = dataDictionary!["family_name"] as! String
                    let KeyArray = Array(dataDictionary!.keys)
                    if KeyArray.contains("MobileNumber") {
                        let mobileNumber = dataDictionary! ["MobileNumber"] as! String
                        utility.setCountryDialCode(mobileNumber)
                    }
                    if KeyArray.contains("MobileCode") {
                        let country = dataDictionary!["MobileCode"] as! String
                        utility.setCountryCode(country)
                     self.getCountryDisplayCode(code: utility.getCountryCode())
                    }
                    if KeyArray.contains("picture") {
                        let profileUrl = dataDictionary!["picture"] as! String
                        utility.setUserProfileURL(profileUrl)
                    }
                   
                    
                   utility.setUserFirstName(firstName)
                   utility.setUserLastName(lastName)
                  
                    self.setUserDetail()
                }
                DispatchQueue.main.async {
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Profile Updated", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UPDATEPROFILENOTIFICATION"), object: nil))
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    self.editScreenLog(true)
                    
                }
                
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                //                utility.setUserToken(" ")
                //                self.presentLogin()
                NSLog(" %@", err)
            }
        }
        
    }
    
    
    func updateUserProfileApi() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        
        responseData = {(dict) in
            if(dict["status"]?.intValue != 1)
            {
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(dict["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
                    self.editScreenLog(false)
                    return
                }
            }
            
            DispatchQueue.main.async {
                 utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Profile Updated", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UPDATEPROFILENOTIFICATION"), object: nil))
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.editScreenLog(true)
                self.getUSerProfile()
            }
        }
        self.UploadRequest()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if dataArrayObj == nil {
            return 0
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return dataArrayObj!.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        
        let aStr = String(format: "%@", (dataArrayObj![row]["name"] as? String)!)
        
        return aStr;
        
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField .resignFirstResponder()
        return true
    }



    @IBAction func onImageClick(_ sender: AnyObject) {
        
        let actionSheetTitle = "";
        let remove       = "Remove"
        let imageClicked = "Take Picture";
        let ImageGallery = "Choose Photo";
        let  cancelTitle = "Cancel";
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles:remove,imageClicked , ImageGallery)
        actionSheet.show(in: self.view)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            
            isImageChanged = true
            selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            
            
            profileImage.imageView!.contentMode = UIViewContentMode.scaleAspectFit
            
            selectedImage = selectedImage?.resizeWithV(640)
            profileImage .setBackgroundImage(selectedImage, for: UIControlState())
            profileImage!.layer.borderWidth = 1
            profileImage!.layer.masksToBounds = false
            profileImage!.layer.borderColor = UIColor.clear.cgColor
            profileImage!.layer.cornerRadius = profileImage!.frame.height/2
            profileImage!.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if(buttonIndex == 1)
        {
            removeLocally  = true
            self.profileImage .setBackgroundImage(UIImage(named: "default_profile" ), for:
                UIControlState())
        }
        else if(buttonIndex == 2)
        {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            self.perform(#selector(presentv), with: nil, afterDelay: 0)
            
        }
        else if(buttonIndex == 3)
        {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.perform(#selector(presentv), with: nil, afterDelay: 0)
        }
    }
    
    func presentv(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let aStr = String(format: "%@(+%@)", (dataArrayObj![row]["shortCode"] as? String)!, (dataArrayObj![row]["dialCode"] as? String)! )
        countryCodeText.text = aStr
        self.sortCountryCode = dataArrayObj![row]["shortCode"] as? String
        
    }
    func getCountryDisplayCode(code:String){
        print(code)
        if code == "" {
            return
        }
        let dict = self.dataArrayObj?.filter{ $0["shortCode"] as? String == code }
        if (dict != nil && dict?.count != 0){
        let aStr = String(format: "%@(+%@)", (dict![0]["shortCode"] as? String)!, (dict![0]["dialCode"] as? String)! )
        self.countryCodeText.text = aStr
        }
    }
    
    func getUSerProfile()->(){
        let generalApiobj = GeneralAPI()
        
        let someDict:[String:String] = ["":""]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strApiGetUSerProfile, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                guard let data = response["data"] as? [String:AnyObject],let readerGetProfileResponse = data["readerGetProfileResponse"] as? [String:AnyObject] else{
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                
               // self.setUserDetail(readerGetProfileResponse)
            }
        }) { (err) in
            DispatchQueue.main.async {
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                NSLog(" %@", err)
            }
        }
        
    }
    
    func setUserDetail() -> () {
        self.nameLabel!.text = "\(utility.getUserFirstName()!) \(utility.getUserLastName()!)"
        self.nameText!.text = "\(utility.getUserFirstName()!)"
        self.lastNmaeText!.text = "\(utility.getUserLastName()!)"
        self.emailText!.text = "\(utility.getUserEmail()!)"
        self.phoneText!.text = "\(utility.getCountryDialCode()!)"
        print("country code \(utility.getCountryCode()!)")
     //   self.countryCodeText!.text = "\(utility.getCountryCode()!)"
//        self.phoneText!.text = "\(data["mobile"]!)"
//        let aStr = String(format: "%@(+%@)", "\(data["countryCode"]!)", "\(data["countryDialCode"]!)" )
//        self.countryCodeText!.text = aStr
//        self.emailText!.text = "\(data["email"]!)"
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
           
        var url :URL!
        if(utility.getUserProfileURL() != nil || utility.getUserProfileURL() != " "){
            url = URL(string: "\(utility.getUserProfileURL()!)")
            if url == nil {
                return
            }
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            if data == nil {return}
            DispatchQueue.main.async(execute: {
                
                self.selectedImage = UIImage(data: data!)
                self.profileImage .setBackgroundImage(self.selectedImage, for:
                    UIControlState())
                
                self.profileImage!.layer.borderWidth = 1
                self.profileImage!.layer.masksToBounds = false
                self.profileImage!.layer.borderColor = UIColor.white.cgColor
                self.profileImage!.layer.cornerRadius = self.profileImage!.frame.height/2
                self.profileImage!.clipsToBounds = true
            });
          }
        }
//
//        
//        utility.setUserFirstName(data["firstName"]! as! String)
//        utility.setUserLastName(data["lastName"]! as! String)
//        utility.setCountryDialCode((data["countryDialCode"] as? String)!)
//        utility.setCountryCode((data["countryCode"] as? String)!)

        
//        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
//            
//           if url == nil {
//                return
//            }
//            
//            
        
//
//        }
    }

    

    

    
    
    func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String)
    {
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancelTitle)
        alert.show()
    }
    
    func isValidate() -> Bool {
        if nameText.text == "" {
            createAlert(TextMessage.fillFirstName.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
        
        if lastNmaeText.text == "" {
            createAlert(TextMessage.fillLastName.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }

//                if phoneText.text == "" {
//
//
//
//            createAlert(TextMessage.fillPhone.rawValue, alertMessage: "", alertCancelTitle: "OK")
//            return false
//        }
//                else{
//                    let aStr = String(format: "%@", phoneText.text!)
////                    let istrue: Bool =  parseNumber(aStr)
////                    if istrue == false {
////                        return false
////                    }
//        }
//
//        if countryCodeText.text == "" {
//            createAlert(TextMessage.countryCode.rawValue, alertMessage: "", alertCancelTitle: "OK")
//            return false
//        }
               if confirmText.text != passwordText.text {
            createAlert(TextMessage.confirmpassword.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
             return true
    }
    
    func createPicker() {
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 250, width: view.frame.width, height: 250))
        pickerView!.clipsToBounds = true
        pickerView!.layer.borderWidth = 1
        pickerView!.layer.borderColor = UIColor.lightGray.cgColor
        pickerView!.layer.cornerRadius = 5;
        pickerView!.layer.shadowOpacity = 0.8;
        pickerView!.layer.shadowOffset = CGSize(width: 0.0, height: 0.0);
        pickerView!.dataSource = self
        pickerView!.delegate = self
        pickerView!.backgroundColor = UIColor.white
        
    }
    
    func getCountries()  {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        
        
        generalApiobj.hitApiwith([:], serviceType: .strApiGetCountries, success: { (response) in
            DispatchQueue.main.async {
                
                print(response["data"])
                
                let dataDictionary = response["data"] as! [Dictionary<String,AnyObject>]?
                
                self.dataArrayObj = dataDictionary
                var names = [String]()
                var countries = [String]()
                for blog in self.dataArrayObj! {
                    if let name = blog["name"] as? String {
                        names.append(name)
                    }
                    if let name = blog["dialCode"] as? String {
                        countries.append(name)
                    }
                }
                
                
             self.createPicker()
               self.getCountryDisplayCode(code: utility.getCountryCode())
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                NSLog(" %@", err)
            }
        }
    }
    
    
    func parseNumber(_ number: String) -> Bool {
        
        var istrue: Bool?
        
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            print(phoneNumber.countryCode)
//            var countryCode = ""
//            if self.sortCountryCode!  == "" {
//                countryCode = self.sortCountryCode!
//            }
//            phoneNumberKit.countryCode(for: countryCode)
            //            let phoneNumber = try PhoneNumber(rawNumber: number)
            //            print(String(phoneNumber.countryCode))
            //            if let regionCode = phoneNumberKit.mainCountryForCode(phoneNumber.countryCode) {
            //                let country = Locale.currentLocale().displayNameForKey(NSLocale.Key.countryCode, value: regionCode)
            //                print(country)
            istrue = true
            // }
        }
        catch {
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            createAlert(TextMessage.notValidNumber.rawValue, alertMessage: "", alertCancelTitle: "OK")
            istrue = false
            print("Something went wrong")
        }
        return istrue!
    }
    
    func UploadRequest()
    {
        let url = URL(string: String(format: "%@%@", Kbase_url, "/reader/updateProfile" ))
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
    
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(utility.getDevice(), forHTTPHeaderField:"deviceId")
        request.setValue("traquer", forHTTPHeaderField:"AppType")
         request.setValue("courier", forHTTPHeaderField:"role")
        request.setValue(utility.getUserToken(), forHTTPHeaderField:"sid")
        
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"firstName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(nameText.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"lastName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(lastNmaeText.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"mobile\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(phoneText.text!)\r\n".data(using: String.Encoding.utf8)!)
        if(sortCountryCode != nil)
        {
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"countryCode\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(sortCountryCode!)\r\n".data(using: String.Encoding.utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"organization\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("Organization\r\n".data(using: String.Encoding.utf8)!)
        
        if(passwordText.text != "")
        {
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"password\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(passwordText.text!)\r\n".data(using: String.Encoding.utf8)!)
        }
        
        if isImageChanged == true{
            
            if(selectedImage == nil)
            {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.editScreenLog(false)

                return
            }
            
            let image_data = UIImageJPEGRepresentation(selectedImage!, 0.0)
            
            if(image_data == nil)
                
            {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.editScreenLog(false)

                return
                
            }

                    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                    body.append("Content-Disposition:form-data; name=\"profileImage\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
                    body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                    body.append(image_data!)
                    body.append("\r\n".data(using: String.Encoding.utf8)!)
                    
                    
                    body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
                    
        }
        
        
        request.httpBody = body as Data
        
        
        
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                self.editScreenLog(false)
                return
            }
            
            let dict = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves);
            
            self.responseData!(dict as! Dictionary<String, AnyObject>)
        }) 
        
        task.resume()
        
        
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }

    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if textField == countryCodeText {
            resignText()
            textField.inputView = pickerView
            textField.inputAccessoryView = toolBar()
        }
    }
    func resignText() {
        nameText.resignFirstResponder()
        
        phoneText.resignFirstResponder()
       
        passwordText.resignFirstResponder()
        confirmText.resignFirstResponder()
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        currentView = textField
        textField.inputAccessoryView = self.toolBar()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField == phoneText
        {
            let aStr = String(format: "%@", phoneText.text!)
            if(aStr == "")
            {
                self.countryCodeText.text = ""
            }
           // parseNumber(aStr)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == phoneText)
        {
            let maxLength = 10
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString as NSString
            return newString.length <= maxLength
        }
        return true
    }
    func toolBar()-> UIToolbar {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STREditProfileVC.nextMove)),
            UIBarButtonItem(title: "Previous", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STREditProfileVC.previousMove)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STREditProfileVC.done))]
        numberToolbar.sizeToFit()
        return numberToolbar
    }
    
    func  nextMove(){
        if(currentView?.tag<105)
        {
            let vw = self.view.viewWithTag((currentView?.tag)!+1) as? UITextField
            vw?.becomeFirstResponder()
        }
    }
    func previousMove(){
        if(currentView?.tag>101)
        {
            let vw = self.view.viewWithTag((currentView?.tag)!-1) as? UITextField
            vw?.becomeFirstResponder()
        }
        
    }
    func done(){
        
        currentView?.resignFirstResponder()
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        if up == false {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: +150)
        }else{
            self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: -150)
        }
        
        UIView.commitAnimations()
    }
    func deleteImage(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["deleteProfileImage":"1" as AnyObject], serviceType: .strApiDeleteUserProfile, success: { (response) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UPDATEPROFILENOTIFICATION"), object: nil))
                self.profileImage .setBackgroundImage(UIImage(named: "default_profile" ), for:
                    UIControlState())
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                NSLog(" %@", err)
            }
        }
        

    }

    /*Fabric event loging*/

    
    func editScreenLog(_ success:Bool){
    var didSuceed:String?
    var pwd:String?
    var img:String?
     if(passwordText.text != "")
       {
        pwd = "YES"
       }
       else{
        pwd = "No"
        }
        if isImageChanged == true {
            img = "YES"
        }else{
            img = "NO"
        }
        if success{
            didSuceed = "YES"
        }
        else{
            didSuceed = "NO"
        }
        Answers.logCustomEvent(withName: "EDIT PROFILE", customAttributes: ["Password Change":pwd!,
            "Image Upload":img!,"Success":didSuceed!])
    }
    func imageUploadToCloudinary(successBlock:@escaping (()->()),errorBlock:@escaping (()->())){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        
        
        let uploader = cloudinary.createUploader()
        let imageProfileData = UIImagePNGRepresentation(self.selectedImage!) as Data?
        uploader.upload(data: imageProfileData!, uploadPreset: "nlnltoua"){ result , error in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil
            
            if((result) != nil && error == nil)
            {
                self.profileURL = (result?.resultJson["url"])! as! String;
                successBlock()
            }
            else
            {
                errorBlock()
            }
        }
    }
    
  }
