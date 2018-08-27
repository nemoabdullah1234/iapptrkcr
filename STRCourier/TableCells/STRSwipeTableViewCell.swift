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



class STRSwipeTableViewCell: MGSwipeTableCell, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var intransitButton: UIButton!
    @IBOutlet weak var label2: UILabel!
     @IBOutlet var lbl1: UILabel!
    @IBOutlet var bottomView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet var topView: TopView!
    @IBOutlet var layoutTrailing: NSLayoutConstraint!
     @IBOutlet var layoutHeading: NSLayoutConstraint!
    @IBOutlet var pickerView : UIPickerView?
    var currentView : UITextField?
    var dataArrayObj : [Dictionary<String,AnyObject>]?
    
    @IBOutlet weak var showMap: UIButton!
     @IBOutlet var bottonHeight: NSLayoutConstraint!
    
    @IBOutlet var rightConstraint: NSLayoutConstraint!
    
    @IBOutlet var markAsView: UIView!
    @IBOutlet weak var markasLabel: UILabel!
    @IBOutlet var showMapLabel: UILabel!
    @IBOutlet weak var markasImage: UIImageView!
    @IBOutlet var showMapImage: UIImageView!
    @IBOutlet weak var markasImage2: UIImageView!
    
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var countryCodeText: UITextField!
    @IBOutlet var checkBoxView: UIView!
    
    @IBOutlet weak var lblPHoneCode: UILabel!
    
     @IBOutlet var imgReport: UIImageView!
    var index: IndexPath?
    var blockSlected:((IndexPath)->())?
    var blockSTart:((IndexPath)->())?
    
    var blockIncreaseHeight:((IndexPath)->())?
     var blockDecreaseHeight:((IndexPath)->())?
    
    var blockStartShipMent:((IndexPath)->())?
    
     var showMapClicked:((IndexPath)->())?
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var arrayData: [Dictionary<String,AnyObject>]?
    let phoneNumberKit = PhoneNumberKit()
    
    var selectedImageBooL:Bool = false
    
    var noOfButtons = [CGFloat]()
    
    @IBOutlet var imgSelected: UIImageView!
    @IBAction func btnSelected(_ sender: UIButton) {
        
        if selectedImageBooL == true {
            // set selected
            sender.isSelected = false
            selectedImageBooL = false
            self.imgSelected.image = UIImage.init(named: "unselected")
        } else {
            // set deselected
            sender.isSelected = true
            
            selectedImageBooL = true
             self.imgSelected.image = UIImage.init(named: "selected")
        }
        
        if(self.blockSTart != nil)
        {
            self.blockSTart!(self.index!)
        }
    }
    
    
    @IBAction func markButtonClicked(_ sender: UIButton) {
        self.bottonHeight.constant = 128
        self.bottomView.isHidden  = false
        
        layoutTrailing.constant = 0
        layoutHeading.constant = -8
        let status = arrayData![self.index!.row]["shipStatus"] as! Int
        var markAsCancelLabel = String()
        if(status == 60)
        {
            markAsCancelLabel = "Update Details"
        }
        else if(status == 40 || status == 50)
        {
            markAsCancelLabel = "Mark as Delivered"
        }
        if markasLabel.text  == "Cancel" {
             self.bottonHeight.constant = 0
            self.bottomView.isHidden  = true
           self.markAsView.backgroundColor = UIColor(colorLiteralRed: 105/225.0, green: 186/225.0, blue: 110/225.0, alpha: 1)
            markasLabel.text = markAsCancelLabel
             self.markasImage2!.image = UIImage.init(named: "icondelivered")
            if(self.blockDecreaseHeight != nil)
            {
                self.blockDecreaseHeight!(self.index!)
            }
        }else if markasLabel.text  == "Start Shipment"{
            
            self.bottonHeight.constant = 0
            self.bottomView.isHidden  = true
            
            if(self.blockStartShipMent != nil)
            {
                self.blockStartShipMent!(self.index!)
            }
           
        }else if (markasLabel.text  == "Mark as Delivered" ||  markasLabel.text  == "Update Details"){
            
            self.markAsView.backgroundColor = UIColor.red
            markasLabel.text = "Cancel"
            layoutTrailing.constant = layoutTrailing.constant - 185
            layoutHeading.constant = layoutHeading.constant + 185
         
           self.markasImage2!.image = UIImage.init(named: "iconcancel")
            
            if(self.blockIncreaseHeight != nil)
            {
                self.blockIncreaseHeight!(self.index!)
            }
            
        }
        
        
        
        
       
        
    }
    @IBAction func showMapClicked(_ sender: AnyObject) {
        if(self.showMapClicked != nil)
        {
            self.showMapClicked!(self.index!)
        }
    }
    
    var recognizer: UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.bottonHeight.constant = 0
        let aStr = String(format: "IN(+%@)", utility.getCountryDialCode()!)
        countryCodeText.text = aStr
         self.topView.markAsView = markAsView
        recognizer = UIPanGestureRecognizer(target: self.topView, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
        self.topView.addGestureRecognizer(recognizer)
        
        setUpFont()
        intransitButton!.layer.masksToBounds = false
        intransitButton!.layer.cornerRadius = 10
        intransitButton!.clipsToBounds = true
    
        getCountries()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func setUpFont(){
        
        lbl1.font = UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        label2.font = UIFont(name: "SourceSansPro-Regular", size: 17.0);
        dateLabel.font = UIFont(name: "SourceSansPro-Regular", size:13)
        self.intransitButton.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 13);
        self.submitButton.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 15);
        showMapLabel.font = UIFont(name: "SourceSansPro-Regular", size:16)
        markasLabel.font = UIFont(name: "SourceSansPro-Regular", size:16)
    }

    
    //MARK: - horizontal pan gesture methods
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .changed {
            let translation = recognizer.translation(in: self)
            center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            
            let originalFrame = CGRect(x: -markAsView.frame.width * 2, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            
        }
        // 3
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                // if the item is not being deleted, snap back to the original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
            }
        }
    }
    
    
    
    
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.topView.dict = arrayData![index!.row]
        return true
    }
    
    
    func setupCellData(_ dict:Dictionary<String,AnyObject>,index:IndexPath,expand:Bool,selected:Bool){
        self.index = index
        markasImage2!.tag = index.row
         checkBoxView.isHidden = true
        self.bottonHeight.constant = 0
        self.bottomView.isHidden  = true
        layoutTrailing.constant = 0
        layoutHeading.constant = -8
        if(expand == true)
        {
            
            self.bottonHeight.constant = 0
            self.bottomView.isHidden  = true
            recognizer.isEnabled = false
            self.layoutTrailing.constant = 45
        }
        else{
            recognizer.isEnabled = true
            self.layoutTrailing.constant = 0
        }
        self.lbl1.text = dict["l1"] as? String
        
        self.label2.text = dict["h1"] as? String
       
        let status = dict["shipStatus"] as? Int
       
        switch  status!{
        case  10:
            let aStr = String(format: "%@", (dict["l3"] as? String)!)
             self.dateLabel.text = aStr
            self.intransitButton .setTitle("New", for: UIControlState())
            self.intransitButton .setBackgroundImage(UIImage(named: "newbackground"), for: UIControlState())
            self.markAsView.isHidden = false
           self.markAsView.backgroundColor = UIColor(colorLiteralRed: 77/225.0, green: 72/225.0, blue: 133/225.0, alpha: 1)
            markasLabel.text = "Start Shipment"
            self.markasImage2!.image = UIImage(named: "iconintransit")
           
            if (expand == true) {
                checkBoxView.isHidden = false
            }
            
            break
            
        case  20:
            
            
            let aStr = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr
            self.intransitButton .setTitle("Scheduled", for: UIControlState())
            self.intransitButton .setBackgroundImage(UIImage(named: "tapdeliverd"), for: UIControlState())
            self.markAsView.isHidden = false
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 77/225.0, green: 72/225.0, blue: 133/225.0, alpha: 1)
            markasLabel.text = "Start Shipment"
            self.markasImage2!.image = UIImage(named: "iconintransit")
            
            if (expand == true) {
                checkBoxView.isHidden = false
            }
            
            
            break
        case  25:
            
            
            let aStr1 = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr1
            self.intransitButton .setTitle("Partial Shipped", for: UIControlState())
            self.markAsView.isHidden = false
            self.intransitButton .setBackgroundImage(UIImage(named: "iconpartial"), for: UIControlState())
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 105/225.0, green: 186/225.0, blue: 110/225.0, alpha: 1)
            markasLabel.text = "Mark as Delivered"
            
            self.markasImage2!.image = UIImage(named: "icondelivered")
            
            break
        case  30:
            
            
            let aStr = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr
            self.intransitButton .setTitle("Soft Shipped", for: UIControlState())
            self.intransitButton .setBackgroundImage(UIImage(named: "intrnsibackground"), for: UIControlState())
            self.markAsView.isHidden = false
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 77/225.0, green: 72/225.0, blue: 133/225.0, alpha: 1)
            markasLabel.text = "Start Shipment"
            self.markasImage2!.image = UIImage(named: "iconintransit")
            
            if (expand == true) {
                checkBoxView.isHidden = false
            }
            
            break
            
        case  40:
            
            let aStr1 = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr1
            self.intransitButton .setTitle("In Transit", for: UIControlState())
              self.markAsView.isHidden = false
            self.intransitButton .setBackgroundImage(UIImage(named: "intrnsibackground"), for: UIControlState())
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 105/225.0, green: 186/225.0, blue: 110/225.0, alpha: 1)
            markasLabel.text = "Mark as Delivered"
         
            self.markasImage2!.image = UIImage(named: "icondelivered")
            
            break
            
        case  50:
            let aStr1 = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr1
            self.intransitButton .setTitle("Soft Delivered", for: UIControlState())
            self.markAsView.isHidden = false
            self.intransitButton .setBackgroundImage(UIImage(named: "deliveredbackground"), for: UIControlState())
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 105/225.0, green: 186/225.0, blue: 110/225.0, alpha: 1)
            markasLabel.text = "Mark as Delivered"
            
            self.markasImage2!.image = UIImage(named: "icondelivered")
            
            break
        case  45:
            let aStr1 = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr1
            self.intransitButton .setTitle("Partial Delivered", for: UIControlState())
            self.markAsView.isHidden = false
            self.intransitButton .setBackgroundImage(UIImage(named: "iconbnddelivered"), for: UIControlState())
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 105/225.0, green: 186/225.0, blue: 110/225.0, alpha: 1)
            markasLabel.text = "Mark as Delivered"
            
            self.markasImage2!.image = UIImage(named: "icondelivered")
            
            break
            
        case 60:
            
            let aStr2 = String(format: "%@", (dict["l3"] as? String)!)
            self.dateLabel.text = aStr2
            self.intransitButton .setTitle("Delivered", for: UIControlState())
            
            self.intransitButton .setBackgroundImage(UIImage(named: "deliveredbackground"), for: UIControlState())
            self.markAsView.isHidden = false
            self.markAsView.backgroundColor = UIColor(colorLiteralRed: 105/225.0, green: 186/225.0, blue: 110/225.0, alpha: 1)
            markasLabel.text = "Update Details"
            self.markasImage2!.image = UIImage(named: "icondelivered")
            
            break
            
        default:
            break
        }
        
        let isreported = dict["isReported"] as? NSInteger
        if(isreported == 0)
        {
            self.imgReport.isHidden = true
        }
        else{
            self.imgReport.isHidden = false
        }

        if(selected ==  false) {
            selectedImageBooL = false
           self.imgSelected.image = UIImage(named: "unselected")
        }
        
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField .resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func intransitBtnClicked(_ sender: AnyObject) {
        
        if validate() {
            self.bottonHeight.constant = 0
            self.bottomView.isHidden  = true
            if(self.blockSlected != nil)
            {
                self.blockSlected!(self.index!)
            }
        }
        
    }
    
    func validate()-> Bool{
         let rootViewController: UIViewController = UIApplication.shared.windows[0].rootViewController!
        if(phoneNumberText.text == "" && firstNameText.text == "")
        {
            utility.createAlert(TextMessage.enterValues.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
            return false
        }
        if(firstNameText.text == "")
        {
            utility.createAlert(TextMessage.fillLastName.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
            return false
            
        }
        if(phoneNumberText.text == "")
        {
            utility.createAlert(TextMessage.fillPhone.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
            return false
            
        }else{
            let aStr = String(format: "%@", phoneNumberText.text!)
            let istrue: Bool =  parseNumber(aStr)
            if istrue == false {
                utility.createAlert(TextMessage.phonenumber.rawValue, alertMessage: "", alertCancelTitle: "OK" ,view: rootViewController)
                return false
            }
            
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
    
        currentView = textField
        textField.inputAccessoryView = self.toolBar()
        return true
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
        firstNameText.resignFirstResponder()
        
        lastNameText.resignFirstResponder()
        
        phoneNumberText.resignFirstResponder()
        
    }
    
    func toolBar()-> UIToolbar {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 50))
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
            let vw = self.viewWithTag((currentView?.tag)!+1) as? UITextField
            vw?.becomeFirstResponder()
        }
    }
    func previousMove(){
        if(currentView?.tag>101)
        {
            let vw = self.viewWithTag((currentView?.tag)!-1) as? UITextField
            vw?.becomeFirstResponder()
        }
        
    }
    func done(){
        
        currentView?.resignFirstResponder()
    }
    
    
    
    func createPicker() {
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 250, width: self.frame.width, height: 250))
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
                
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                NSLog(" %@", err)
            }
        }
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
        countryCodeText.text = aStr
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
            MBProgressHUD.hideAllHUDs(for: self, animated: true)
            istrue = false
            print("Something went wrong")
        }
        return istrue!
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class TopView: UIView {
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var noOfButtons : CGFloat!
    var markAsView: UIView?
    fileprivate var beginPoint : CGPoint = CGPoint.zero
    var dict:Dictionary<String,AnyObject>?
    
    
    var previousNo : CGFloat!
    
    
   
    
    
    //MARK: - horizontal pan gesture methods
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        // 1
        
        let status = dict!["shipStatus"] as? Int
        switch  status!{
        case  10:
            noOfButtons = 2
            previousNo = 100
        
        break
        case 20:
            noOfButtons = 2
            previousNo = 100
            break
        case 30:
            noOfButtons = 2
            previousNo = 100
            break
        case  40:
            noOfButtons = 2
           previousNo = 100
        break
        case  45:
            noOfButtons = 2
            previousNo = 100
            break
        case  50:
            noOfButtons = 2
            previousNo = 100
            break
        case  25:
            noOfButtons = 2
            previousNo = 100
            break
        case 60:
             noOfButtons = 2
             previousNo = 100
        break
        
        default:
             noOfButtons = 0
             previousNo = 100
        break
       }
        
        
        if recognizer.state == .began {
            self.beginPoint = recognizer.location(in: self)
            self.beginPoint.x -= self.frame.origin.x
            originalCenter = center
        }
        // 2
        if recognizer.state == .changed {
            
            let now = recognizer.location(in: self)
            let distX = now.x - self.beginPoint.x
            
             print("Frame \(self.markAsView!.frame.width * noOfButtons) frame \(beginPoint.x)")
            if distX <= -20 {
                let d = max(distX,-(self.frame.size.width-self.markAsView!.frame.width))
                if d < beginPoint.x {
                    
                    if d < -previousNo {
                        let originalFrame = CGRect(x: 10 , y: frame.origin.y,
                                                   width: bounds.size.width, height: bounds.size.height)
                        UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
                        recognizer.isEnabled = false
                        recognizer.isEnabled = true
                        
                    }else{
                    self.frame.origin.x = d
                    
                    let originalFrame = CGRect(x: -markAsView!.frame.width * noOfButtons , y: frame.origin.y,
                                               width: bounds.size.width, height: bounds.size.height)
                    UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
                    
                    recognizer.isEnabled = false
                    recognizer.isEnabled = true
                    }
               }
                else {
                   deleteOnDragRelease = false
                    recognizer.isEnabled = false
                    recognizer.isEnabled = true
                }
            }

        }
        // 3
        if recognizer.state == .ended {
            // the frame this cell had before user dragged it
           
            
            
            let originalFrame = CGRect(x: 10, y: frame.origin.y,
                                       width: bounds.size.width, height: bounds.size.height)
            if !deleteOnDragRelease {
                // if the item is not being deleted, snap back to the original location
                UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
                recognizer.isEnabled = false
                recognizer.isEnabled = true
            }
        }
       
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
    
    
    
}


