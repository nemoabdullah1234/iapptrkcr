import UIKit
import Cloudinary
class STRComposeIssueViewController: UIViewController ,UITextViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate {
    
    @IBOutlet var vwSave: UIView!
    
    
    
    @IBOutlet var lbl1: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var tblItems: UITableView!
    @IBOutlet var fileSlider: CSFileSlideView!
    @IBOutlet var tvComment: UITextView!
    @IBOutlet var botmLayout: NSLayoutConstraint!
    @IBOutlet var lblPlaceHolder: UILabel!
    
    var reportType:STRTypeOfReport?
    var trackingID: String!
    var itemsArray: [Dictionary<String,AnyObject>]?
    var dataPath: String?
    var imagePicker = UIImagePickerController()
    var selectedImage : UIImage?
    var selectedSku : [String]?
    var caseNo:String?
    var shippingNo:String?
    var shipmentId:String?
    var config:CLDConfiguration!
   

    var cloudinary: CLDCloudinary!
    var arrayOfUplodedimageURL:[Dictionary<String,String>]!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = TitleName.ReportIssue.rawValue
        selectedSku = [String]()
        config = CLDConfiguration(cloudName:cloudinaryCloud)
        cloudinary = CLDCloudinary(configuration: config)
        arrayOfUplodedimageURL = [Dictionary<String,String>]();

        customizeNavigationforAll(self)
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.createDirectory()
        self.addKeyboardNotifications()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "STRItemsTableViewCell", bundle: nil)
        tblItems.register(nib, forCellReuseIdentifier: "STRItemsTableViewCell_")
        if(reportType == .strReportCase)
        {
            let vw = STRNavigationTitle.setTitle("Notes", subheading: "\(self.trackingID!)")
            vw.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: (self.navigationController?.navigationBar.frame.size.height)!)
            self.navigationItem.titleView = vw
        }
        else{
            let vw = STRNavigationTitle.setTitle("Notes", subheading: "\(self.trackingID!)")
            vw.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: (self.navigationController?.navigationBar.frame.size.height)!)
            self.navigationItem.titleView = vw

            self.lbl2.isHidden = true
            self.tblItems.isHidden = true
            self.tblItems.dataSource = nil
            self.tblItems.delegate =  nil
        }

       
        // Do any additional setup after loading the view.
        setUpFont()
    
    }
        func backToDashbaord(_ back:UIButton){
            self.deleteDirectory()
        self.navigationController?.popViewController(animated: true)
    }
    func setUpFont(){
        self.vwSave.layer.cornerRadius = 5.0
        self.tvComment.font = UIFont(name: "SourceSansPro-Regular", size: 14.0)
        self.lbl2.font =  UIFont(name: "SourceSansPro-Regular", size: 14.0);
        self.lblPlaceHolder.font = UIFont(name: "SourceSansPro-Regular", size: 14.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.fileSlider.shocut = true
    }
    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    @IBAction func btnCam(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.perform(#selector(STRComposeIssueViewController.openCam), with: nil, afterDelay: 0.1);
    }
    func openCam(){
        let actionSheetTitle = "Images";
        let imageClicked = "Take Picture";
        let ImageGallery = "Choose Photo";
        let  cancelTitle = "Cancel";
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles:imageClicked , ImageGallery)
        actionSheet.show(in: self.view)

    }
    @IBAction func btnSend(_ sender: AnyObject) {
        if(self.validate())
        {
            if(reportType == .strReportCase)
            {
               self.uploadIssueCloudinary() // self.uploadIssue()
            }
            else{
                 self.uploadIssue2()
            }
           
        }
    }
    func toolBar()-> UIToolbar {
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(STRComposeIssueViewController.done))]
        numberToolbar.sizeToFit()
        return numberToolbar
    }
    func done(){
        self.tvComment?.resignFirstResponder()
    }
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(STRComposeIssueViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(STRComposeIssueViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = self.toolBar()
        lblPlaceHolder.isHidden = true
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            if(self.reportType == .strReportCase)
            {
                  self.botmLayout.constant = keyboardFrame.size.height - 100
            }
            else{
                
                  self.botmLayout.constant = keyboardFrame.size.height - 50
            }

          
            
        }, completion: { (completed: Bool) -> Void in
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.botmLayout.constant = 0.0
        }, completion: { (completed: Bool) -> Void in

        }) 
        if(tvComment.text == "")
        {
            self.lblPlaceHolder.isHidden = false
        }

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
        try! FileManager.default.removeItem(atPath: dataPath!)
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
            self.selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            self.selectedImage = self.selectedImage?.resizeWithV(120)
            self.selectedImage = self.rotateImage(self.selectedImage!)
            let webData = UIImagePNGRepresentation(self.selectedImage!);
            let  timeStamp = Date().timeIntervalSince1970 * 1000.0
            let time = "\(timeStamp)".replacingOccurrences(of: ".", with: "")
            var fileName = ""
            fileName = fileName + "PIC_\(time).png"
            let localFilePath = (self.dataPath)! + "/\(fileName)"
            try? webData?.write(to: URL(fileURLWithPath: localFilePath), options: [.atomic])
            DispatchQueue.main.async(execute: {
                 self.fileSlider.addAssetURL(localFilePath)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                if(reportType == .strReportCase)
                {
        return self.itemsArray!.count
                }
                else{
               return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: STRItemsTableViewCell = self.tblItems.dequeueReusableCell(withIdentifier: "STRItemsTableViewCell_") as! STRItemsTableViewCell
        cell.lbl1.text = self.itemsArray![indexPath.row]["l1"] as? String
        cell.lbl2.text = self.itemsArray![indexPath.row]["l2"] as? String
          if(self.itemsArray![indexPath.row]["sel"] as? NSInteger == 0 || self.itemsArray![indexPath.row]["sel"] == nil)
          {
            cell.btnCheck.setImage(UIImage.init(named: "rbunselected") , for: UIControlState())
         }
                else
         {
         cell.btnCheck.setImage(UIImage.init(named: "rbselected"), for: UIControlState())
         }
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 71
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if(self.itemsArray![indexPath.row]["sel"] as? NSInteger == 0 || self.itemsArray![indexPath.row]["sel"] == nil)
        {
            self.itemsArray![indexPath.row]["sel"] = 1 as AnyObject
            
         self.selectedSku?.append((self.itemsArray![indexPath.row]["skuId"] as? String)!)
        }
        else{
           self.itemsArray![indexPath.row]["sel"] = 0 as AnyObject
            
            self.selectedSku?.remove(at: (self.selectedSku?.index(of: (self.itemsArray![indexPath.row]["skuId"] as? String)!))! )
        }
        
        self.tblItems.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
    }
    //MARK: validation
    func validate()->Bool{
        if(tvComment.text == "")
        {
            utility.createAlert("", alertMessage: "Please enter comments", alertCancelTitle:"OK", view: self)
            return false
        }
        if(self.selectedSku?.count == 0 && reportType == .strReportCase)
        {
            utility.createAlert("", alertMessage: "Please select a item", alertCancelTitle:"Ok", view: self)
            return false
            
        }

        return true
    }
    func uploadIssue(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let uploadObj = CSUploadMultipleFileApi()
        uploadObj.hitFileUploadAPI(withDictionaryPath: dataPath, actionName: STRUploadRequestOne, idValue: ["caseNo":self.caseNo!,"shippingNo":self.shippingNo!,"comment":self.tvComment.text,"skuIds":self.selectedSku!.joined(separator: ",")], successBlock: { (response) in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil

            do {
               // let responsed = try JSONSerialization.jsonObject(with: (response as? Data)!, options:[])
                
                 let responsed:[String:AnyObject] = try! JSONSerialization.jsonObject(with: (response as? Data)!, options: .mutableLeaves) as! [String : AnyObject];
                
                if(responsed["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(responsed["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                else{
                    self.deleteDirectory()
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch {
                print("Error: \(error)")
            }
            
        }) { (error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil
            print(error)
        }
    }
    
    func uploadIssue2(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let uploadObj = CSUploadMultipleFileApi()
        uploadObj.hitFileUploadAPI(withDictionaryPath: dataPath, actionName: STRUploadRequestTwo, idValue: ["caseNo":self.caseNo!,"skuId":self.shippingNo!,"comment":self.tvComment.text], successBlock: { (response) in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil
            do {
              //  let responsed = try JSONSerialization.jsonObject(with: (response as? Data)!, options:[])
                 let responsed:[String:AnyObject] = try! JSONSerialization.jsonObject(with: (response as? Data)!, options: .mutableLeaves) as! [String : AnyObject];
                if(responsed["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(responsed["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                else{
                     self.deleteDirectory()
                    self.navigationController?.popViewController(animated: true)
                }

            }
            catch {
                print("Error: \(error)")
            }
        }) { (error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            loadingNotification = nil
            print(error)
        }
    }

    func uploadIssueCloudinary(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        imageUploadToCloudinary(dataPath: dataPath!, successBlock:{
            let params = ["shippingNo":self.shipmentId!,"comment":self.tvComment.text,"skuIds":self.selectedSku!.joined(separator: ","),"images": self.arrayOfUplodedimageURL] as [String : Any]
            let generalApiobj = GeneralAPI()
            generalApiobj.hitApiwith(params as Dictionary<String, AnyObject>, serviceType: .strPostComment, success: { (response) in
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
    
    func sync(lock: [Dictionary<String,String>], closure: () -> Void) {
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
            uploader.upload(url: path!, uploadPreset: cloudinaryPreset){ result , error in
                if((result) != nil && error == nil)
                {
                    self.sync (lock: self.arrayOfUplodedimageURL) {
                        let obj = ["url":(result?.resultJson["url"])! as! String,"meta":""];
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
            successBlock();
        }
    }
    
}
