import UIKit
import PhoneNumberKit
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


class STRShipmentDetailViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate {
    
    var dataNextRow:Dictionary<String,AnyObject>?
    var index: NSInteger?
    var controlsActive :Bool?
    var controlsIntransit: Bool?
    var isEditable: Bool?
    var flipped =  false
    @IBOutlet var vwDetails: STRItemDetailView!
    @IBOutlet var vwCameraControl: UIView!
    
    
    
    @IBOutlet var btnImage: UIButton!
    
    @IBOutlet var vwNextCellControls: UIView!
    
    @IBOutlet var vwBottomControlHeight: NSLayoutConstraint!

    
    @IBOutlet var btnNextDelivery: UIButton!
    
    
    @IBOutlet var btnStatus: UIButton!
    
    @IBAction func btnStatus(_ sender: AnyObject) {
    }
    @IBOutlet var lblTitleNext: UILabel!
    
    @IBOutlet var lblSubTitleNext: UILabel!
    @IBOutlet var vwBottomControls: UIView!
    
    @IBOutlet var lblTitle: UILabel!
    
    @IBOutlet var lblSubTitle: UILabel!
    
    @IBOutlet var lblAddress: UILabel!
    
    
    
    @IBOutlet var lbl3: UILabel!
    
    @IBOutlet var lbl4: UILabel!
    @IBOutlet var lblSubDetail: UILabel!
    
    
    @IBOutlet var imgCamImage: UIImageView!
    
    
    @IBOutlet var txtName: UITextField!
    
    
    @IBOutlet var txtPhoneNumber: UITextField!
    
    
    @IBOutlet var imgOption: UIImageView!
    
    @IBOutlet var imgChatIcon: UIImageView!
    
    
    @IBOutlet var imgCloseicon: UIImageView!
    
    
    @IBOutlet var scrlView: UIScrollView!
    
    @IBAction func btnOption(_ sender: AnyObject) {
    }
    
    @IBAction func btnShowDetails(_ sender: AnyObject) {
        self.vwDetails.tblItemDetail.reloadData()
        UIView.transition(with: self.vwDetails, duration: 1.0, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
            if(!self.flipped){
                self.vwDetails.isHidden =  false
                self.view .bringSubview(toFront: self.vwDetails)
                self.flipped = true
            }
            }, completion: nil)
         self.vwCameraControl.isHidden =  true
    }
    
    @IBAction func btnChat(_ sender: AnyObject) {
        if(self.controlsActive == false)
        {
            utility.createAlert("", alertMessage: "No data for shipment", alertCancelTitle: "OK", view: self)
            return
        }
        let VW = STRReportIssueViewController(nibName: "STRReportIssueViewController", bundle: nil)
        VW.issueID = "\(self.shipmentData!["issueId"] as! NSInteger)"
        VW.shipmentNo = self.shipmentData!["shipmentNo"] as! String
        VW.caseNo = self.shipmentData!["caseNo"] as! String
        self.navigationController?.pushViewController(VW, animated: true)
    }
    @IBAction func btnClose(_ sender: AnyObject) {
        if(!flipped)
        {
        self.navigationController?.popViewController(animated: true)
        }
        else{
            UIView.transition(with: self.vwCameraControl, duration: 1.0, options: UIViewAnimationOptions.transitionFlipFromLeft, animations: {
                self.vwCameraControl.isHidden =  false
                    self.view .bringSubview(toFront: self.vwCameraControl)
                    self.flipped = false
                }, completion: nil)
            self.vwDetails.isHidden =  true
        }
    }
    
    @IBAction func btnDone(_ sender: AnyObject) {
        if(self.controlsActive == false)
        {
              utility.createAlert("", alertMessage: "No data for shipment", alertCancelTitle: "OK", view: self)
            return
        }
        if(self.controlsIntransit == false)
        {
            utility.createAlert("", alertMessage: "Shipment not in transit.", alertCancelTitle: "OK", view: self)
            return
        }
       
        if(validate())
        {
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.labelText = "Loading"
            
            responseData = {(dict) in
                if(dict["status"]?.int32Value != 1)
                {
                    DispatchQueue.main.async {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(dict["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    self.controlsIntransit = false
                    self.txtName.isEnabled = false
                    self.txtPhoneNumber.isEnabled = false
                    self.btnImage.isEnabled = false
                     MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                }
            }

            
            UploadRequest()
            
        }
    }
    var responseData :((Dictionary<String,AnyObject>)->())?
    var caseNo:String!
    var shipmentNo:String!
    var currentView: UITextField?
    var selectedImage: UIImage?
    let phoneNumberKit = PhoneNumberKit()
    let imagePicker = UIImagePickerController()
    var shipmentData: Dictionary<String,AnyObject>?
    var shipmentImages: [Dictionary<String,AnyObject>]?
    override func viewDidLoad() {
        super.viewDidLoad()
        controlsActive = false
        controlsIntransit = false
        addKeyboardNotifications()
        imagePicker.delegate = self
        getShipmentData()
        self.vwBottomControls.isHidden = false;
        self.vwNextCellControls.isHidden = true
        if(!isEditable!)
        {
            self.txtName.isEnabled = false
            self.txtPhoneNumber.isEnabled = false
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: textField delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentView = textField
        textField.inputAccessoryView = self.toolBar()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
              return true
    }
   func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if((string == " ") && (textField == self.txtPhoneNumber))
        {
            return false
        }
    if textField == self.txtPhoneNumber {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 10
    }
        return true
    }
    func toolBar()-> UIToolbar {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STRShipmentDetailViewController.nextMove)),
            UIBarButtonItem(title: "Previous", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STRShipmentDetailViewController.previousMove)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STRShipmentDetailViewController.done))]
        numberToolbar.sizeToFit()
        return numberToolbar
    }
    
    func  nextMove(){
        if(currentView?.tag<102)
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
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(STRShipmentDetailViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(STRShipmentDetailViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    // MARK:- Notification
    func keyboardWillShow(_ notification: Notification) {
        self.scrlView.setContentOffset(CGPoint(x: 0, y: 360), animated: true)
        self.scrlView.isScrollEnabled = false
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.scrlView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.scrlView.isScrollEnabled = true
    }
    
    func validate()-> Bool{
         let rootViewController: UIViewController = UIApplication.shared.windows[0].rootViewController!
        if(txtPhoneNumber.text == "" && txtName.text == "")
        {
            utility.createAlert(TextMessage.enterValues.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
            return false
        }
        if(txtName.text == "")
        {
            utility.createAlert(TextMessage.fillLastName.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
            return false

        }
        if(txtPhoneNumber.text == "")
        {
            utility.createAlert(TextMessage.fillPhone.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
            return false

        }else{
            let aStr = String(format: "%@", txtPhoneNumber.text!)
            let istrue: Bool =  parseNumber(aStr)
            if istrue == false {
                 utility.createAlert(TextMessage.phonenumber.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
                return false
            }
            
        }
        return true
    }

    func parseNumber(_ number: String) -> Bool {
        let rootViewController: UIViewController = UIApplication.shared.windows[0].rootViewController!
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
            utility.createAlert(TextMessage.notValidNumber.rawValue, alertMessage: "", alertCancelTitle: "OK", view: rootViewController)
            istrue = false
            print("Something went wrong")
        }
        return istrue!
    }
    
    //MARK: camera picker and image capture section
    @IBAction func btnImage(_ sender: AnyObject) {
        
        if(self.controlsActive == false)
        {
            utility.createAlert("", alertMessage: "No data for shipment", alertCancelTitle: "OK", view: self)
            return
        }
        if(self.controlsIntransit == false)
        {
              utility.createAlert("", alertMessage: "Shipment not in transit.", alertCancelTitle: "OK", view: self)
            return
        }
        let actionSheetTitle = "Images";
        let imageClicked = "Take Photo";
        let ImageGallery = "Select Photo";
        let  cancelTitle = "Cancel Button";
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles:imageClicked , ImageGallery)
        actionSheet.show(in: self.view)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if (info[UIImagePickerControllerOriginalImage] as? UIImage) != nil {
            
            selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            selectedImage = selectedImage?.resizeWithV(640)
            self.imgCamImage.image=selectedImage
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
    
    //MARK: Api tasks
    
    func getShipmentData()->(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        let someDict:[String:String] = ["caseNo":self.caseNo,"shipmentNo":self.shipmentNo]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strGetShipmentDetails, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerGetShipmentDetailsResponse = data["readerGetShipmentDetailsResponse"] as? [String:AnyObject], let items  = readerGetShipmentDetailsResponse["items"] as? [[String:AnyObject]]  else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.controlsActive = true
                self.vwDetails.tableData = items
                self.shipmentData = readerGetShipmentDetailsResponse
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
               
                guard let shipmentImages = readerGetShipmentDetailsResponse["shipmentImages"] as? [[String:AnyObject]]  else{
                     self.setUpData()
                    return
                }
                
                self.shipmentImages = shipmentImages
                self.setUpData()

            }
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                NSLog(" %@", err)
            }
        }
        
    }
    func setUpData()->(){
        
        if(shipmentData!["shipStatus"] as! NSInteger == 40)
        {
           self.controlsIntransit = true
        }
        self.lblTitle.text = shipmentData!["h1"] as? String
        self.lblAddress.text = shipmentData!["l1"] as? String
        self.lblSubDetail.text = "\(shipmentData!["l8"] as! String) | \(shipmentData!["l9"] as! String)"
        self.lbl3.text = "\(shipmentData!["h1"] as! String) | \(shipmentData!["l2"] as! String)"
        self.lbl4.text = "\(shipmentData!["l10"] as! String) | \(shipmentData!["l11"] as! String)"
        self.txtName.text = shipmentData!["l6"] as? String
        self.txtPhoneNumber.text = shipmentData!["l7"] as? String
        
        if(self.shipmentImages != nil)
        {
        self.imgCamImage.setImageWith(URL(string:self.shipmentImages![0]["full"] as! String ), placeholderImage: UIImage(named: "cameraicon"))
        }
        }
    
    
    func UploadRequest()
    {
        let url = URL(string: String(format: "%@%@", Kbase_url, "/reader/deliverShipment" ))
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        //define the multipart request type
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(utility.getDevice(), forHTTPHeaderField:"deviceId")
        request.setValue("traquer", forHTTPHeaderField:"AppType")
        request.setValue(utility.getUserToken(), forHTTPHeaderField:"sid")
        
        
        
        
        let body = NSMutableData()
        
        let fname = "test.png"
        let mimetype = "image/png"
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"caseNo\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(self.caseNo!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"shipmentNo\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(self.shipmentNo!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"recipientMobile\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(self.txtPhoneNumber.text!)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\" recipientName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(self.txtName.text!)\r\n".data(using: String.Encoding.utf8)!)
        
       
        
        if(selectedImage != nil)
        {
            let image_data = UIImageJPEGRepresentation(selectedImage!, 0.0)
            body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Disposition:form-data; name=\"images[]\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
            body.append(image_data!)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
            
        }
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
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
            print(dict as! Dictionary<String, AnyObject>)
            self.responseData!(dict as! Dictionary<String, AnyObject>)
        }) 
        
        task.resume()
        
        
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(UUID().uuidString)"
    }


}
