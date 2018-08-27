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

class STRDetailSliderViewController: UIViewController,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    @IBOutlet var vwSave2: UIView!
    
    @IBOutlet var vwSave: UIView!
    
    @IBOutlet var vwSignature: UIView!
    
    var pickerView : UIPickerView?
    var dataArrayObj : [Dictionary<String,AnyObject>]?
    
    var  signatureImage : UIImage!
    
    @IBOutlet var scrlViewBase: UIScrollView!
    @IBOutlet var blackView: UIView!
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var lblItemList: UILabel!
    @IBOutlet var vwItemList: STRItemDetailView!
    @IBOutlet var lblRecivedBy: UILabel!
    @IBOutlet var lblMediaUploaded: UILabel!
    @IBOutlet var lblMobile: UILabel!
    @IBOutlet var lblReciverName: UILabel!
    @IBOutlet var lblReciverMobile: UILabel!
    @IBOutlet var vwDevilerSlider: CSFileSlideView!
    @IBOutlet var btnDone: UIButton!
    //outletTopView
    @IBOutlet var imgReport: UIImageView!
    @IBOutlet var lblReport: UILabel!
    var config:CLDConfiguration!
    var cloudinary: CLDCloudinary!
    var arrayOfUplodedimageURL:[Dictionary<String,Any>]!
    var objectSignatureimage:Dictionary<String,Any>!
    var codeCountry:String!
    var dialCode:String!
    @IBAction func btnSignature(_ sender: AnyObject) {
        let strSignature = STRSignatureViewController.init(nibName: "STRSignatureViewController", bundle: nil)
        strSignature.fullName =  "\(txtFirstName.text!) \(txtLastName.text!)"
        strSignature.phoneSTr =  txtPhoneNo.text
        
        strSignature.blockGetImage = {(image) in
            self.signatureImage   = image
        }
        
        self.present(strSignature, animated: true, completion:nil)
        
        
    }
    
    
    @IBAction func btnReport(_ sender: AnyObject) {
        if(self.shipmentData == nil)
        {
            return
        }
        let strReportIssue = STRReportIssueNewViewController.init(nibName: "STRReportIssueNewViewController", bundle: nil)
        strReportIssue.caseNo =  self.caseNo
        if(self.shipmentData!["issueId"] != nil)
        {
            strReportIssue.issueID = "\(self.shipmentData!["issueId"] as! NSInteger)"
        }
        strReportIssue.readonly = self.readonly
        strReportIssue.reportType = .strReportCase
        strReportIssue.shipmentId = self.shipmentid
        strReportIssue.shippingNo = self.shipmentData!["shipmentNo"] as? String
        self.navigationController?.pushViewController(strReportIssue, animated: true)
    }
    @IBOutlet var lblBtnDone: UILabel!
    @IBOutlet var viewDelivered: UIView!
    //======================
    @IBOutlet var lblMap: UILabel!
    @IBOutlet var imgMap: UIImageView!
    @IBAction func btnMap(_ sender: AnyObject) {
        
//        let vc =  AKMapViewController(nibName: "AKMapViewController", bundle: nil)
//        vc.statusCode = self.shipmentData!["shipStatus"] as! NSInteger
//        vc.URL = self.shipmentData!["map"] as? String
//        vc.shipmentNo = self.shipmentData!["l4"] as? String
//        vc.status = self.status
//        let location = self.shipmentData!["locations"] as! Dictionary<String, AnyObject>
//        let fromLocation = location["shipFromLocation"] as! Dictionary<String, AnyObject>
//        print("\(fromLocation["coordinates"]!["latitude"]!!)")
//        vc.fromlat = "\(fromLocation["coordinates"]!["latitude"]!!)"
//        vc.fromlong = "\(fromLocation["coordinates"]!["longitude"]!!)"
//        vc.fromAddress  = fromLocation
//        vc.destinationLocation =  self.shipmentData!["h2"] as? String
//        vc.lat = "\(self.shipmentData!["latitude"]!)"
//        vc.long = "\(self.shipmentData!["longitude"]!)"
//        vc.shipmentID = self.shipmentid
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
        
      let vc =  AKMQTTMapViewController(nibName: "AKMQTTMapViewController", bundle: nil)
      vc.statusCode = self.shipmentData!["shipStatus"] as! NSInteger
      vc.URL = self.shipmentData!["map"] as? String
      vc.shipmentNo = self.shipmentData!["l4"] as? String
      vc.status = self.status
      let location = self.shipmentData!["locations"] as! Dictionary<String, AnyObject>
      let fromLocation = location["shipFromLocation"] as! Dictionary<String, AnyObject>
      print("\(fromLocation["coordinates"]!["latitude"]!!)")
      vc.fromlat = "\(fromLocation["coordinates"]!["latitude"]!!)"
      vc.fromlong = "\(fromLocation["coordinates"]!["longitude"]!!)"
      vc.fromAddress  = fromLocation
      vc.destinationLocation =  self.shipmentData!["h2"] as? String
      vc.lat = "\(self.shipmentData!["latitude"]!)"
      vc.long = "\(self.shipmentData!["longitude"]!)"
      vc.shipmentID = self.shipmentid
      self.navigationController?.pushViewController(vc, animated: true)
        
      getCountries()
        
//        let vc =  STRDirectionMapViewController(nibName: "STRDirectionMapViewController", bundle: nil)
//        vc.statusCode = self.shipmentData!["shipStatus"] as! NSInteger
//        vc.URL = self.shipmentData!["map"] as? String
//        vc.shipmentNo = self.shipmentData!["l4"] as? String
//        vc.status = self.status
//        vc.lat = "\(self.shipmentData!["latitude"]!)"
//        vc.long = "\(self.shipmentData!["longitude"]!)"
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBOutlet var lblStatusNew: UILabel!
    
    @IBOutlet var lblLocationNew: MarqueeLabel!
    
    
    @IBOutlet var viewHeader: STRHeaderViewCaseDetail!
    
    //Yellow View UI
    
    @IBOutlet var yellowView: UIView!
    @IBOutlet var txtFirstName: B68UIFloatLabelTextField!
    @IBOutlet var txtLastName: B68UIFloatLabelTextField!
    @IBOutlet var txtCountryCode: B68UIFloatLabelTextField!
    @IBOutlet var txtPhoneNo: B68UIFloatLabelTextField!
    @IBOutlet var fileSliderView: CSFileSlideView!
    @IBOutlet var lblSubbmit: UILabel!
    @IBAction func btnSubmit(_ sender: AnyObject) {
        let status =  self.shipmentData!["shipStatus"] as! NSInteger
        if(self.validate())
        {
            markDelivered();
        }
    }
    @IBOutlet var heightDeliveredView: NSLayoutConstraint!
    @IBOutlet var height: NSLayoutConstraint!
    @IBOutlet var bottomSpace: NSLayoutConstraint!
    @IBOutlet var btnArrow: UIButton!
    @IBAction func btnArrow(_ sender: AnyObject) {
        self.vwItemList.tblItemDetail.reloadData()
        if(self.topLayout.constant == 0)
        {
            self.itemView(false)
            self.imgArrow.image = UIImage(named: "itemuparrow")
            
            self.topLayout.constant = self.view.frame.size.height - 64
            self.vwItemList.stopLocation()
        }
        else
        {
            itemView(true)
            self.imgArrow.image = UIImage(named: "itemdownarrow")
            self.topLayout.constant = 0
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        } )
    }
    @IBAction func btnTouched(_ sender: AnyObject) {
        let status =  self.shipmentData!["shipStatus"] as! NSInteger
        
        if(status == 10)
        {
            self.changeStateOne()
        }
        else if(status == 20)
        {
            self.changeStateOne()
        }
        else if(status == 30)
        {
            self.changeStateOne()
        }
            
        else if(status == 40)
        {
            showDataForm()
        }
        else if(status == 25)
        {
            showDataForm()
        }
        else if(status == 50)
        {
            showDataForm()
        }
      else if(status == 45)
      {
        showDataForm()
      }
        else if(status == 60)
        {
            showDataForm()
        }
    }
    @IBOutlet var topLayout: NSLayoutConstraint!
    var currentView: UITextField?
    let phoneNumberKit = PhoneNumberKit()
    var caseNo:String?
    var caseId:String?
    var shipmentNo:String?
    var shipmentid:String?
    var status:String?
    var shipmentData: Dictionary<String,AnyObject>?
    var shipmentImages: [Dictionary<String,AnyObject>]?
    var tableData: [Dictionary<String,AnyObject>]?
    
    var dataPath: String?
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage?
    var readonly:Bool?
    
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = false
        customNavigationforBack(self)
      //  self.navigationItem.titleView = STRNavigationTitle.setTitle("\(self.caseNo!)", subheading: "")
        codeCountry = ""
        config = CLDConfiguration(cloudName:"drvjylp2e")
        cloudinary = CLDCloudinary(configuration: config)
        super.viewDidLoad()
        setFont()
        addKeyboardNotifications()
        dataFeeding()
        arrayOfUplodedimageURL = [Dictionary<String,String>]();
        objectSignatureimage = Dictionary<String,String>()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        self.createDirectory()
        // Do any additional setup after loading the view.
        
        self.height.priority = 1
        self.heightDeliveredView.priority = 1
        self.revealViewController().panGestureRecognizer().isEnabled = false
        self.vwItemList.blockForItemClicked = { data in
            
            let vw = STRInventoryListViewController(nibName: "STRInventoryListViewController", bundle: nil)
            vw.skuId =  "\(data["skuId"]!)"
            vw.locationName = self.shipmentData!["l4"] as! String
            vw.titleString = self.shipmentData!["caseNo"] as! String
            vw.idValue = "\(data["skuId"]!)"
            vw.flagToShowEdit = true
            self.navigationController?.pushViewController(vw, animated: true)
        }
    }
    func showDataForm(){
        self.height.priority = 150
        self.yellowView.isHidden =  false
        self.vwItemList.isHidden = true
        self.fileSliderView.setFrame()
        self.view.layoutIfNeeded()
        if(self.scrlViewBase.frame.height < self.scrlViewBase.contentSize.height)
        {
            let bottomOffset = CGPoint(x: 0, y: self.scrlViewBase.contentSize.height - self.scrlViewBase.bounds.size.height);
            self.scrlViewBase.setContentOffset(bottomOffset, animated: true)
        }
        
    }
    func poptoPreviousScreen(){
        self.deleteDirectory()
        self.vwItemList.stopLocation()
        self.navigationController?.popViewController(animated: true)
    }
    func sortButtonClicked(_ sender:UIButton){
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    func canRotate() -> Void {}
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if(topLayout.constant == 0)
        {
            return
        }
        if(self.topLayout.constant != (self.view.frame.size.height - 64))
        {
            self.topLayout.constant = self.view.frame.size.height - 64
            self.imgArrow.image = UIImage(named: "itemuparrow")
            
        }
        if(self.scrlViewBase.frame.height < self.scrlViewBase.contentSize.height)
        {
            let bottomOffset = CGPoint(x: 0, y: self.scrlViewBase.contentSize.height - self.scrlViewBase.bounds.size.height);
            self.scrlViewBase.setContentOffset(bottomOffset, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setFont()
    {
        lblReport.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        lblMap.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        lblBtnDone.font =  UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        lblSubbmit.font =  UIFont(name: "SourceSansPro-Semibold", size: 16.0);
        txtFirstName.font = UIFont(name: "SourceSansPro-Regular", size: 15.0);
        txtLastName.font = UIFont(name: "SourceSansPro-Regular", size: 15.0);
        txtCountryCode.font = UIFont(name: "SourceSansPro-Regular", size: 15.0);
        txtPhoneNo.font = UIFont(name: "SourceSansPro-Regular", size: 15.0);
        lblStatusNew.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);
        lblLocationNew.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Regular", size: 13.0)! // Note the !
        ]
        txtFirstName.attributedPlaceholder = NSAttributedString(string: "FIRST NAME", attributes:attributes)
        txtLastName.attributedPlaceholder = NSAttributedString(string: "LAST NAME", attributes:attributes)
        txtCountryCode.attributedPlaceholder = NSAttributedString(string: "PHONE", attributes:attributes)
        txtPhoneNo.attributedPlaceholder = NSAttributedString(string: "", attributes:attributes)
        
        
        lblRecivedBy.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblReciverName.font = UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        lblMobile.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblReciverMobile.font = UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        lblMediaUploaded.font = UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        lblItemList.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);
        self.vwSave.layer.cornerRadius = 5.0
        self.vwSave2.layer.cornerRadius = 5.0
        self.vwSignature.layer.cornerRadius = 5.0
        
    }
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0, animations: { () -> Void in
            self.bottomSpace.constant = keyboardFrame.size.height
        }, completion: { (completed: Bool) -> Void in
            
        })
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0, animations: { () -> Void in
            self.bottomSpace.constant = 0.0
        }, completion: { (completed: Bool) -> Void in
            
        })
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField .resignFirstResponder()
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        currentView = textField
        textField.inputAccessoryView = self.toolBar()
        if textField == txtCountryCode {
            textField.inputView = pickerView
            textField.inputAccessoryView = toolBar()
        }
        
        
        return true
    }
    func resignText() {
        txtFirstName.resignFirstResponder()
        txtLastName.resignFirstResponder()
        txtPhoneNo.resignFirstResponder()
    }
    func createPicker() {
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 250, width: self.view.frame.width, height: 250))
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
        
        
        let aStr = String(format: "%@", (dataArrayObj![row]["name"] as? String)!)
        
        return aStr;
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let aStr = String(format: "%@(+%@)", (dataArrayObj![row]["shortCode"] as? String)!, (dataArrayObj![row]["dialCode"] as? String)! )
        self.codeCountry = dataArrayObj![row]["shortCode"] as? String
        self.dialCode = dataArrayObj![row]["dialCode"] as? String
        txtCountryCode.text = aStr
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
    }
    
    
    func toolBar()-> UIToolbar {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Previous", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STREditProfileVC.previousMove)),
            UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STREditProfileVC.nextMove)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STREditProfileVC.done))]
        numberToolbar.sizeToFit()
        return numberToolbar
    }
    
    func  nextMove(){
        if(currentView?.tag<104)
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
            MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
            createAlert(TextMessage.notValidNumber.rawValue, alertMessage: "", alertCancelTitle: "OK")
            istrue = false
            print("Something went wrong")
        }
        return istrue!
    }
    func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String)
    {
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancelTitle)
        alert.show()
    }
    
    func dataFeeding(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        let someDict:[String:String] = ["caseNo":self.caseNo!,"shipmentid":self.shipmentid!]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strGetShipmentDetails, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                
                guard let data = response["data"] as? [String:AnyObject],let readerGetShipmentDetailsResponse = data["readerGetShipmentDetailsResponse"] as? [String:AnyObject], let items  = readerGetShipmentDetailsResponse["items"] as? [[String:AnyObject]]  else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.blackView.removeFromSuperview()
                print(items)
                self.vwItemList.tableData = items
                self.vwItemList.setTableData()
                self.shipmentData = readerGetShipmentDetailsResponse
                MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                guard let shipmentImages = readerGetShipmentDetailsResponse["shipmentImages"] as? [[String:AnyObject]]  else{
                    self.setUpData()
                    self.getCountries()
                    return
                }
                self.shipmentImages = shipmentImages
                self.setUpData()
                self.getCountries()
            }
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                NSLog(" %@", err)
            }
        }
        
    }
    
    func setUpData(){
        let title = self.shipmentData!["caseNo"] as! String
        self.navigationItem.titleView = STRNavigationTitle.setTitle(title, subheading: self.shipmentData!["l4"] as! String)
        
        self.viewHeader.setUpDataOfHeader(self.shipmentData!)
        self.view.layoutIfNeeded()
        switch self.shipmentData!["shipStatus"] as! NSInteger{
        case 10:
            //new
            lblBtnDone.text = "MARK AS IN TRANSIT"
            self.lblStatusNew.text = "Open"
            self.status = "OPEN"
            break
            
        case 20:
            //scheduled
            lblBtnDone.text = "MARK AS IN TRANSIT"
            self.lblStatusNew.text = "Scheduled"
            self.status = "SCHEDULED"
            break
        case 25:
            // Partial shipped
            lblBtnDone.text = "MARK AS DELIVERED"
           // txtCountryCode.text = "\(utility.getCountryCode()!)(+\(utility.getCountryDialCode()!))"
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "btnAddMedia.png"
                let path = resourcePath + "/" + imgName
                self.fileSliderView.addAssetURL(path)
            }
            self.fileSliderView.cellSelect = { indexPath in
                if(indexPath?.row == 0)
                {
                    self.view.endEditing(true)
                    self.perform(#selector(STRDetailSliderViewController.openCam), with: nil, afterDelay: 0.1);
                }
            }
            self.lblStatusNew.text = "Partial Shipped"
            self.status = "Partial Shipped"
            break
        case 30:
            // soft shipped
            //scheduled
            lblBtnDone.text = "MARK AS IN TRANSIT"
            self.lblStatusNew.text = "Soft Shipped"
            self.status = "Soft Shipped"
            break
            
        case 40:
            // in transit
            lblBtnDone.text = "MARK AS DELIVERED"
          //  txtCountryCode.text = "\(utility.getCountryCode()!)(+\(utility.getCountryDialCode()!))"
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "btnAddMedia.png"
                let path = resourcePath + "/" + imgName
                self.fileSliderView.addAssetURL(path)
            }
            self.fileSliderView.cellSelect = { indexPath in
                if(indexPath?.row == 0)
                {
                    self.view.endEditing(true)
                    self.perform(#selector(STRDetailSliderViewController.openCam), with: nil, afterDelay: 0.1);
                }
            }
            self.lblStatusNew.text = "In Transit"
            self.status = "IN TRANSIT"
            
            break
            
        case 50:
            //soft delivered
            // in transit
            lblBtnDone.text = "MARK AS DELIVERED"
          //  txtCountryCode.text = "\(utility.getCountryCode()!)(+\(utility.getCountryDialCode()!))"
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "btnAddMedia.png"
                let path = resourcePath + "/" + imgName
                self.fileSliderView.addAssetURL(path)
            }
            self.fileSliderView.cellSelect = { indexPath in
                if(indexPath?.row == 0)
                {
                    self.view.endEditing(true)
                    self.perform(#selector(STRDetailSliderViewController.openCam), with: nil, afterDelay: 0.1);
                }
            }
            self.lblStatusNew.text = "Soft Delivered"
            self.status = "Soft Delivered"
            break
            
        case 45:
            //soft delivered
            // in transit
            lblBtnDone.text = "MARK AS DELIVERED"
         //   txtCountryCode.text = "\(utility.getCountryCode()!)(+\(utility.getCountryDialCode()!))"
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "btnAddMedia.png"
                let path = resourcePath + "/" + imgName
                self.fileSliderView.addAssetURL(path)
            }
            self.fileSliderView.cellSelect = { indexPath in
                if(indexPath?.row == 0)
                {
                    self.view.endEditing(true)
                    self.perform(#selector(STRDetailSliderViewController.openCam), with: nil, afterDelay: 0.1);
                }
            }
            self.lblStatusNew.text = "Partial Delivered"
            self.status = "Partial Delivered"
            break

            
        case 60:
            //delivered
            
            //Clear scrollviews
            self.fileSliderView.removeAllImages()
            self.vwDevilerSlider.removeAllImages()
            
            self.height.priority = 1
            self.yellowView.isHidden =  true
            self.vwItemList.isHidden = false
            
            //Update Details related settings
            lblBtnDone.text = "UPDATE DETAILS"
         //   txtCountryCode.text = "\(utility.getCountryCode()!)(+\(utility.getCountryDialCode()!))"
            if let resourcePath = Bundle.main.resourcePath {
                let imgName = "btnAddMedia.png"
                let path = resourcePath + "/" + imgName
                self.fileSliderView.addAssetURL(path)
            }
            
            
            
            self.fileSliderView.cellSelect = { indexPath in
                if(indexPath?.row == 0)
                {
                    self.view.endEditing(true)
                    self.perform(#selector(STRDetailSliderViewController.openCam), with: nil, afterDelay: 0.1);
                }
            }
            
            viewDelivered.superview?.bringSubview(toFront: vwSave2)
            self.heightDeliveredView.priority = 100
            self.viewDelivered.isHidden = false
            self.lblReciverMobile.text = self.shipmentData!["l7"] as? String
            self.lblReciverName.text = self.shipmentData!["l6"] as? String
            if(self.shipmentImages != nil && self.shipmentImages?.count > 0)
            {
                for dict in self.shipmentImages!{
                    self.vwDevilerSlider.addAssetURL(dict["thumb"] as? String)
                }
            }
            else{
                self.lblMediaUploaded.isHidden = true
                self.vwDevilerSlider.isHidden = true
            }
            self.lblStatusNew.text = "Delivered"
            
            self.status = "DELIVERED"
            
            self.vwDevilerSlider.cellSelect = {(indexPath) in
                let url =  self.shipmentImages![(indexPath?.row)!]["full"]! as! String
                if(url != "")
                {
                    self.presentWithImageURL(url)
                }
            }
            break
            
            
        default:
            self.navigationController?.popViewController(animated: true)
            break
        }
        self.lblLocationNew.text = self.shipmentData!["l2"] as? String
    }
    
    //MARK: Image addition in case of picker view
    func openCam(){
        let actionSheetTitle = "Images";
        let imageClicked = "Take Picture";
        let ImageGallery = "Choose Photo";
        let  cancelTitle = "Cancel";
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles:imageClicked , ImageGallery)
        actionSheet.show(in: self.view)
        
    }
    func createDirectory() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsDirectory = paths.first
        dataPath = (documentsDirectory)! + "/ISSUE"
        if (!FileManager.default.fileExists(atPath: dataPath!))
        {
            try! FileManager.default.createDirectory(atPath: dataPath!, withIntermediateDirectories: false, attributes: nil)
        }
    }
    func deleteDirectory(){
        var isDir : ObjCBool = true
        if(FileManager.default.fileExists(atPath: dataPath!, isDirectory: &isDir))
        {
            try! FileManager.default.removeItem(atPath: dataPath!)
        }
    }
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if(buttonIndex == 1)
        {
            imagePicker.sourceType = .camera
            self.perform(#selector(presentv), with: nil, afterDelay: 0)
        }
        else if(buttonIndex == 2)
        {
            imagePicker.sourceType = .photoLibrary
            self.perform(#selector(presentv), with: nil, afterDelay: 0)
        }
    }
    func presentv(){
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        DispatchQueue(label: "directory_write", attributes: []).async(execute: {
            self.selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage
            
            self.selectedImage = self.selectedImage?.resizeWithV(120)
            self.selectedImage = self.rotateImage(self.selectedImage!)
            let webData = UIImagePNGRepresentation(self.selectedImage!);
            let  timeStamp = Date().timeIntervalSince1970 * 1000.0
            let time = "\(timeStamp)".replacingOccurrences(of: ".", with: "")
            var fileName = ""
            fileName = fileName + "PIC_\(time).png"
            let localFilePath = self.dataPath! + "/\(fileName)"
            try? webData?.write(to: URL(fileURLWithPath: localFilePath), options: [.atomic])
            DispatchQueue.main.async(execute: {
                self.fileSliderView.addAssetURL(localFilePath)
            });
        });
        picker.dismiss(animated: true, completion: nil)
    }
    func rotateImage(_ image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.up ) {
            return image
        }
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return copy!
    }
    
    //MARK: POST TASK
    
    func validate()->Bool
    {
        if(txtLastName.text == "" && txtFirstName.text == "" && txtPhoneNo.text == "" && self.signatureImage == nil)
        {
            utility.createAlert("", alertMessage: "Please enter details", alertCancelTitle:"OK", view: self)
            return false
            
        }
        if(txtFirstName.text == "")
        {
            utility.createAlert("", alertMessage: "Please enter fist name", alertCancelTitle:"OK", view: self)
            return false
            
        }
        if(txtLastName.text == "")
        {
            utility.createAlert("", alertMessage: "Please enter last name", alertCancelTitle:"OK", view: self)
            return false
            
        }
        
        if txtPhoneNo.text == "" {
            
            
            
            createAlert(TextMessage.fillPhone.rawValue, alertMessage: "", alertCancelTitle: "OK")
            return false
        }
        else{
            let aStr = String(format: "+%@%@",self.dialCode!,txtPhoneNo.text!)
            let istrue: Bool =  parseNumber(aStr)
            if istrue == false {
                return false
            }
        }
        
        
        return true
    }
    
    
    
    func changeStateOne(){
        var ar = [Dictionary<String,AnyObject>]()
        ar.append(["caseNo":(self.shipmentData!["caseNo"] as? String)! as AnyObject,"shipmentNo":(self.shipmentData!["id"] as? String)! as AnyObject])
        changeState(ar)
    }
    func changeState(_ array:[Dictionary<String,AnyObject>]){
        var loadingNotification = MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        let someDict  = ["shipments":array]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strPickShipment, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    
                    self.dataFeeding()
                    self.detailScreenLog(false)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let _ = data["ReaderPickShipmentResponse"] as? [String:AnyObject] else{
                    MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    self.detailScreenLog(false)
                    
                    return
                }
                MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                self.detailScreenLog(true)
                
                self.dataFeeding()
            }
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                self.detailScreenLog(false)
                NSLog(" %@", err)
            }
        }
        
    }
    /*func markDelivered(){
     var loadingNotification = MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
     
     var params = Dictionary<String,AnyObject>()
     if self.signatureImage != nil
     {
     let signatureData = UIImagePNGRepresentation(self.signatureImage) as Data?
     params = ["caseNo":self.caseNo! as AnyObject,"shipmentNo":self.shipmentNo! as AnyObject,"recipientMobile":txtPhoneNo.text! as AnyObject,"recipientFirstName":txtFirstName.text! as AnyObject,"recipientLastName":txtLastName.text! as AnyObject, "signaturedata": signatureData! as AnyObject]
     
     }
     else{
     params = ["caseNo":self.caseNo! as AnyObject,"shipmentNo":self.shipmentNo! as AnyObject,"recipientMobile":txtPhoneNo.text! as AnyObject,"recipientFirstName":txtFirstName.text! as AnyObject,"recipientLastName":txtLastName.text! as AnyObject]
     }
     
     loadingNotification?.mode = MBProgressHUDMode.indeterminate
     loadingNotification?.labelText = "Loading"
     
     let uploadObj = CSUploadMultipleFileApi()
     uploadObj.hitFileUploadAPI(withDictionaryPath: dataPath, actionName: STRUploadRequestThree, idValue: params, successBlock: { (response) in
     
     MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
     loadingNotification = nil
     
     do {
     let responsed:[String:AnyObject] = try JSONSerialization.jsonObject(with: (response as? Data)!, options:.mutableLeaves) as! Dictionary<String,AnyObject>
     
     
     
     if(responsed["status"]?.intValue != 1)
     {
     MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
     loadingNotification = nil
     utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(responsed["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
     self.markAsDeliveredLog(false)
     return
     }
     else{
     self.markAsDeliveredLog(true)
     MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
     self.dataFeeding()
     }
     }
     catch {
     self.markAsDeliveredLog(false)
     print("Error: \(error)")
     }
     
     }) { (error) in
     MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
     loadingNotification = nil
     self.markAsDeliveredLog(false)
     print(error )
     }
     }*/
    
    
    
    func markSoftDelivered(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.navigationController?.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        var dict: Dictionary<String,AnyObject>?
        if(self.signatureImage !=  nil)
        {
            let signatureData = UIImagePNGRepresentation(self.signatureImage) as Data?
            dict = ["caseNo":self.caseNo! as AnyObject,"shipmentNo":self.shipmentNo! as AnyObject,"recipientMobile":txtPhoneNo.text! as AnyObject,"recipientFirstName":txtFirstName.text! as AnyObject,"recipientLastName":txtLastName.text! as AnyObject,"signaturedata": signatureData! as AnyObject]
        }
        else
        {
            dict = ["caseNo":self.caseNo! as AnyObject,"shipmentNo":self.shipmentNo! as AnyObject,"recipientMobile":txtPhoneNo.text! as AnyObject,"recipientFirstName":txtFirstName.text! as AnyObject,"recipientLastName":txtLastName.text! as AnyObject]
            
        }
        let uploadObj = CSUploadMultipleFileApi()
        uploadObj.hitFileUploadAPI(withDictionaryPath: dataPath, actionName: STRUploadRequestFour, idValue:dict, successBlock: { (response) in
            
            MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
            loadingNotification = nil
            
            do {
                //  let responsed = try JSONSerialization.jsonObject(with: (response as? Data)!, options:[])
                let responsed:[String:AnyObject] = try! JSONSerialization.jsonObject(with: (response as? Data)!, options: .mutableLeaves) as! [String : AnyObject];
                if(responsed["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(responsed["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    self.markAsDeliveredLog(false)
                    return
                }
                else{
                    self.markAsDeliveredLog(true)
                    MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
                    self.deleteDirectory()
                    self.dataFeeding()
                }
            }
            catch {
                self.markAsDeliveredLog(false)
                print("Error: \(error)")
            }
            
        }) { (error) in
            MBProgressHUD.hideAllHUDs(for: self.navigationController?.view, animated: true)
            loadingNotification = nil
            self.markAsDeliveredLog(false)
            print(error )
        }
    }
    
    func getCountries()  {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        
        
        generalApiobj.hitApiwith([:], serviceType: .strApiGetCountries, success: { (response) in
            DispatchQueue.main.async {
                
                
                let dataDictionary = response["data"] as! [Dictionary<String,AnyObject>]?

                
                self.dataArrayObj = dataDictionary //!["readerGetCountriesResponse"]  as! [Dictionary<String,AnyObject>]?
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
    
    func presentWithImageURL(_ url:String?){
        let vw = STRImageViewController(nibName: "STRImageViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: vw)
        vw.imageURL = url
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    /*Fabric Log*/
    func detailScreenLog(_ success:Bool){
        var didSuceed:String?
        if success{
            didSuceed = "YES"
        }
        else{
            didSuceed = "NO"
        }
        Answers.logCustomEvent(withName: "MARK INTRANSIT|SHIPMENT DETAIL", customAttributes: ["success":didSuceed!,"caseNo":(self.shipmentData!["caseNo"] as? String)!,"shipmentNo":(self.shipmentData!["shipmentNo"] as? String)!])
    }
    func markAsDeliveredLog(_ success:Bool){
        var didSuceed:String?
        if success{
            didSuceed = "YES"
        }
        else{
            didSuceed = "NO"
        }
        Answers.logCustomEvent(withName: "MARK DELIVERED|SHIPMENT DETAIL", customAttributes:["caseNo":self.caseNo!,"shipmentNo":self.shipmentNo!,"recipientMobile":txtPhoneNo.text!,"recipientFirstName":txtFirstName.text!,"recipientLastName":txtLastName.text!,"image count": "\(self.fileSliderView.getImageCount())","success":didSuceed!])
    }
    func itemView(_ success:Bool){
        var didSuceed:String?
        if success{
            didSuceed = "OPENED"
        }
        else{
            didSuceed = "CLOSED"
        }
        Answers.logCustomEvent(withName: "ITEM LIST" , customAttributes:["Event":didSuceed!])
    }
    
    func markDelivered(){
        if self.signatureImage != nil{
               signatureUploadToCloudinary(successBlock: {
                self.markedDeliveredCloudinary()
            }, errorBlock: {
                              utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Error uploading signature", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
               })
        }
        else{
             markedDeliveredCloudinary()
        }
    }
    
    func markedDeliveredCloudinary(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        imageUploadToCloudinary(dataPath: dataPath!, successBlock:{
           let params = ["deliveryDetails":["recipientMobileNumber":self.txtPhoneNo.text! as AnyObject,"recipientFirstName":self.txtFirstName.text! as AnyObject,"recipientLastName":self.txtLastName.text! as AnyObject,"recipientMobileCode":self.txtLastName.text! as AnyObject, "recipientSignature": self.objectSignatureimage,"images": self.arrayOfUplodedimageURL],"shipmentid":self.shipmentid! as AnyObject,] as [String : Any]
            let generalApiobj = GeneralAPI()
            generalApiobj.hitApiwith(params as Dictionary<String, AnyObject>, serviceType: .strMarkedDelivered, success: { (response) in
                DispatchQueue.main.async {
                    print(response)
                    if(response["status"]?.intValue != 1)
                    {
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        loadingNotification = nil
                        utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                        return
                    }
                    else {
                        self.deleteDirectory()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }) { (err) in
                DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                }
            }
        }) {
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil
            utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Image upload error", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
        }
    }
    
    
    
    
    func sync(lock: [Dictionary<String,Any>], closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func imageUploadToCloudinary(dataPath:String,successBlock:@escaping (()->()),errorBlock:@escaping (()->())){
        let arrayOfFiles = try! FileManager.default.contentsOfDirectory(atPath: dataPath);
        let uploader = cloudinary.createUploader()
        
        for filename in arrayOfFiles
        {
            let path =  NSURL(fileURLWithPath: dataPath).appendingPathComponent(filename)
            uploader.upload(url: path!, uploadPreset: "nlnltoua"){ result , error in
                if((result) != nil && error == nil)
                {
                    self.sync (lock: self.arrayOfUplodedimageURL) {
                        let obj = ["url":(result?.resultJson["url"])! as! String] as [String : Any];
                        self.arrayOfUplodedimageURL.append(obj);
                        if(self.arrayOfUplodedimageURL.count == arrayOfFiles.count)
                        {
                            successBlock();
                        }
                    }
                }
                else
                {
                    errorBlock()
                }
            }
        }
        if(arrayOfFiles.count == 0)
        {
            successBlock()
        }
    }
    
    func signatureUploadToCloudinary(successBlock:@escaping (()->()),errorBlock:@escaping (()->())){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"


        let uploader = cloudinary.createUploader()
        let signatureData = UIImagePNGRepresentation(self.signatureImage) as Data?
        uploader.upload(data: signatureData!, uploadPreset: "nlnltoua"){ result , error in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil

            if((result) != nil && error == nil)
            {
                self.objectSignatureimage = ["url":(result?.resultJson["url"])! as! String];
                successBlock()
            }
            else
            {
                errorBlock()
            }
        }
    }
    
    func getCountryDisplayCode(code:String){
        print(code)
        if code == "" {
            return
        }
        let dict = self.dataArrayObj?.filter{ $0["shortCode"] as? String == code }
        if (dict != nil && dict?.count != 0){
            let aStr = String(format: "%@(+%@)", (dict![0]["shortCode"] as? String)!, (dict![0]["dialCode"] as? String)! )
            self.txtCountryCode.text = aStr
        }
    }

    
}
