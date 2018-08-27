import UIKit
import PhoneNumberKit
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


class STREditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,  UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate{
    var currentView : UITextField?
    let phoneNumberKit = PhoneNumberKit()
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    @IBOutlet weak var countryCodeText: UITextField!
    @IBOutlet weak var phoneText: PhoneNumberTextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet var scrollViewBottom: NSLayoutConstraint!
    var selectedImage : UIImage?
    var dataArrayObj : [Dictionary<String,AnyObject>]?
    var dataSortValue : NSArray?
    var sortCountryCode : String?
    var responseData : ((Dictionary<String,AnyObject>)->())?
    var countryArray : NSArray?
    var isImageChanged : Bool?
    
    var localTimeZoneAbbreviation: String { return TimeZone.autoupdatingCurrent.identifier ?? "UTC" }
    var config:CLDConfiguration!
    var cloudinary: CLDCloudinary!
    var profileURL:String?
    @IBOutlet var scrollView: UIScrollView!
    let imagePicker = UIImagePickerController()
    @IBOutlet var pickerView : UIPickerView?
    override func viewDidLoad() {
        super.viewDidLoad()
         isImageChanged = false
        self.title = "Update Profile"
        profileURL  = "";
        customizeNavigationforAll(self)
        self.navigationController?.navigationBar.isTranslucent = false
        imagePicker.delegate = self
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 200)
    
        getUSerProfile()
        self.revealViewController().panGestureRecognizer().isEnabled = false
        getCountries()
       
    }
    override func viewDidLayoutSubviews() {
        scrollView.isScrollEnabled = true
        // Do any additional setup after loading the view
        scrollView.contentSize = CGSize(width: view.frame.width,  height: view.frame.height + 200)
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
       
        
        let aStr = String(format: "%@", (dataArrayObj![row]["countryName"] as? String)!)
        
        return aStr;
       
    }
    @IBAction func btnDeleteProfile(_ sender: AnyObject) {
        
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let aStr = String(format: "%@(+%@)", (dataArrayObj![row]["shortCode"] as? String)!, (dataArrayObj![row]["dialCode"] as? String)! )
        countryCodeText.text = aStr
        
        self.sortCountryCode = dataArrayObj![row]["shortCode"] as? String
       
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func backToDashbaord(_ sender: AnyObject) {
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.initSideBarMenu()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField .resignFirstResponder()
        return true
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
                
                self.setUserDetail(readerGetProfileResponse)
            }
        }) { (err) in
            DispatchQueue.main.async {
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                NSLog(" %@", err)
            }
        }
        
    }
    
    func setUserDetail(_ data: Dictionary<String,AnyObject>) -> () {
        self.firstnameText!.text = "\(data["firstName"]!)"
        self.lastnameText!.text = "\(data["lastName"]!)"
        self.phoneText!.text = "\(data["mobile"]!)"
        self.cityText!.text = "\(data["city"]!)"
        self.sortCountryCode = "\(data["countryCode"]!)"
        
        let aStr = String(format: "%@(+%@)", "\(data["countryCode"]!)", "\(data["countryDialCode"]!)" )
        self.countryCodeText!.text = aStr
        self.emailText!.text = "\(data["email"]!)"
        let url = URL(string: "\(data["profileImage"]!)")
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
             if data == nil {return}
            DispatchQueue.main.async(execute: {
               
                self.selectedImage = UIImage(data: data!)
                self.profileImage .setBackgroundImage(self.selectedImage, for:
                    UIControlState())
                self.profileImage!.layer.borderWidth = 1
                self.profileImage!.layer.masksToBounds = false
                self.profileImage!.layer.borderColor = UIColor.clear.cgColor
                self.profileImage!.layer.cornerRadius = self.profileImage!.frame.height/2
                self.profileImage!.clipsToBounds = true
            });
            
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: AnyObject) {
        
        if isValidate() {
          updateUserProfileApi()
            
         /*   if(self.isImageChanged)
            {
            self.imageUploadToCloudinary(successBlock: {
                  updateUserProfileApi()
            }, errorBlock: {
                 utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Error uploading profile image", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
            })
            }
            else{
                updateUserProfileApi()
            }*/
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
                return
                }
            }
        
            DispatchQueue.main.async {
            
           NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UPDATEPROFILENOTIFICATION"), object: nil))
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                }
        }
        
        self.UploadRequest()
        
    }
    
    @IBAction func selectimageClicked(_ sender: AnyObject) {
       
        
        let actionSheetTitle = "Images";
        let imageClicked = "Take Photo";
        let ImageGallery = "Select Photo";
        let  cancelTitle = "Cancel Button";
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles:imageClicked , ImageGallery)
        actionSheet.show(in: self.view)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            
            isImageChanged = true
            
            selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            
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
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            
            self.perform(#selector(presentv), with: nil, afterDelay: 0)
            
        }
        else if(buttonIndex == 2)
        {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
             self.perform(#selector(presentv), with: nil, afterDelay: 0)
        }
    }
    
    func presentv(){
         self.present(imagePicker, animated: true, completion: nil)
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if textField == countryCodeText {
            resignText()
            textField.inputView = pickerView
            textField.inputAccessoryView = toolBar()
        }
        if textField == cityText {
            
        }
        if textField == newPasswordText {
            animateViewMoving(true, moveValue: 100)

           
        }
        if textField == confirmPasswordText {
            animateViewMoving(true, moveValue: 100)

           
        }
    }
    func resignText() {
        firstnameText.resignFirstResponder()
        lastnameText.resignFirstResponder()
        phoneText.resignFirstResponder()
        cityText.resignFirstResponder()
        newPasswordText.resignFirstResponder()
        confirmPasswordText.resignFirstResponder()
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
            parseNumber(aStr)
        }
        
        if textField == cityText {
        }
        if textField == newPasswordText {
            animateViewMoving(false, moveValue: 100)
        }
        if textField == confirmPasswordText {
            animateViewMoving(false, moveValue: 100)
        }
    }
    
    func parseNumber(_ number: String) -> Bool {
        
        var istrue: Bool?
        
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            print(phoneNumber.countryCode)
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneText {
            guard let text = textField.text else { return true }
            
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= 10
        }
        return true
        
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
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                NSLog(" %@", err)
            }
        }
    }
    
    
    func addpopup(_ dataArray : NSArray){
        let popup =  Bundle.main.loadNibNamed("STRPopupSort", owner: self, options: nil)! .first as! STRPopupSort
        popup.tag=10001
        popup.sortDataCountry = dataArray as [AnyObject]
        popup.frame=(self.navigationController?.view.frame)!;
        popup.layoutIfNeeded()
        
        self.navigationController?.view.addSubview(popup)
        
        popup.layoutSubviews()
        
        popup.closureTable = {(sortString)in
            
            print(sortString)
            self.sortCountryCode = sortString["shortCode"] as? String
             self.navigationController?.view.viewWithTag(10001)?.removeFromSuperview()
        }
        popup.setUpPopup(4)
        
    }
    
    
    
    
    func isValidate() -> Bool {
        if firstnameText.text == "" {
           createAlert(TextMessage.fillFirstName.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
        if lastnameText.text == "" {
            createAlert(TextMessage.fillLastName.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
        if phoneText.text == "" {
            
            
            
            createAlert(TextMessage.fillPhone.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }else{
            let aStr = String(format: "%@", phoneText.text!)
            let istrue: Bool =  parseNumber(aStr)
            if istrue == false {
                return false
            }
            
        }
        if cityText.text == "" {
            createAlert(TextMessage.fillCity.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
        if firstnameText.text == "" {
            createAlert(TextMessage.fillCountry.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
       
        if confirmPasswordText.text != newPasswordText.text {
            createAlert(TextMessage.confirmpassword.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
        return true
    }
    
    func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String)
    {
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancelTitle)
        alert.show()
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
        request.setValue(utility.getUserToken(), forHTTPHeaderField:"sid")

        if(selectedImage == nil)
        {
              MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            return
        }
        
        let image_data = UIImageJPEGRepresentation(selectedImage!, 0.0)
        
        if(image_data == nil)
        
        {
              MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            return
                
        }
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"firstName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(firstnameText.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"lastName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(lastnameText.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"mobile\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(phoneText.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\" \"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(sortCountryCode!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"organization\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("Organization\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"timezone\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(localTimeZoneAbbreviation)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"password\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(newPasswordText.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        if isImageChanged == true{
        
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
        if(currentView?.tag<107)
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
              //  self.objectSignatureimage = (result?.resultJson["url"])! as! String;
                successBlock()
            }
            else
            {
                errorBlock()
            }
        }
    }
    
    
    
    
    
    
}

extension UIImage {
    func resizeWith(_ percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithV(_ width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

