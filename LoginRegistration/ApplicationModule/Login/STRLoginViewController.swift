import UIKit
import AirshipKit
import Crashlytics
import AWSCognitoIdentityProvider
import JWTDecode
import AirshipKit
import AWSS3
import AKLog
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

class STRLoginViewController: UIViewController ,UITextFieldDelegate,UIDocumentInteractionControllerDelegate{
    @IBAction func btnSendDiagnostic(_ sender: AnyObject) {
        sendMail()
    }
    @IBOutlet var btnSendDiagnostic: UIButton!

    @IBOutlet var botmLayout: NSLayoutConstraint!
    @IBOutlet var btnShow: UIButton!
    var activityVC: UIActivityViewController?
    @IBAction func btnShow(_ sender: UIButton) {
        if(sender.titleLabel?.text == "SHOW")
        {
            self.txtPassword.isSecureTextEntry = false
            sender.setTitle("HIDE", for: UIControlState())
        }
        else{
            self.txtPassword.isSecureTextEntry = true
            sender.setTitle("SHOW", for: UIControlState())
        }
        
    }
    
    @IBOutlet var txtUserName: B68UIFloatLabelTextField!
    @IBOutlet var txtPassword: B68UIFloatLabelTextField!
    
    @IBOutlet var vwBtnLogin: UIView!
    
    @IBOutlet var lblForgetSomething: UILabel!
    
    @IBOutlet var lblResetYourPassword: UILabel!
    
    @IBOutlet var lblBuild: UILabel!
    
    @IBOutlet var btnLogin: UIButton!
    
    @IBOutlet var scrlView: UIScrollView!
    var version : String!
    var buildType = "P"
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var usernameText: String?
    var myToken : String?
    
    
    var localTimeZoneAbbreviation: String { return TimeZone.autoupdatingCurrent.identifier ?? "UTC" }
    var dataArrayObj : NSDictionary?
    var defaultView : String?
    var defaultSortedby : String?
    var defaultSortedorder : String?
    var currentTextFeild: UITextField?
    var timerCodeUpdate:Timer?
   
    override func viewDidLoad() {
        super.viewDidLoad()
         self.addKeyboardNotifications()
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId:CognitoIdentityPoolID)
        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
      //   timerCodeUpdate = Timer.init(timeInterval: 5, target:self , selector:#selector(updateCode) , userInfo: nil, repeats: true);
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCode), name: NSNotification.Name(rawValue: "CODE_UPDATE"), object: nil)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        //  self.btnShow.hidden = true
        // Do any additional setup after loading the view.
//        var buildType:String!
//        
//        
//        if(Kbase_url.containsString("ossclients"))
//        {
//            buildType = "0.1Q"
//        }
//        else{
//            buildType = "0.1P"
//        }
//        let aStr = String(format: "%@",buildType)
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        //Then just cast the object as a String, but be careful, you may want to double check for nil
         version = nsObject as! String
        // Do any additional setup after loading the view.
        
        if(APIStage.contains("qc"))
        {
            buildType = "Q"
        }
        
          lblBuild.text = "V" + version + buildType + " Code : " + (((utility.getDevice()) != nil) ? utility.getDevice()!:"")

        //lblBuild.text = aStr
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.isNavigationBarHidden = true
    
          setUpFont()
        
        
        //  UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
    }
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    override func viewDidDisappear(_ animated: Bool) {
         // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
    }
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(STRLoginViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(STRLoginViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == " ")
        {
        return false
        }
//        if(textField == self.txtUserName)
//        {
//            textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
//            return false
//
//        }
        
        return true
    }
    func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String)
    {
        
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancelTitle)
        alert.show()
        
        
        

    }

    //MARK: textField delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func validate()->(Bool){
        if((txtPassword.text?.characters.count == 0) && (txtUserName.text?.characters.count == 0))
        {
            createAlert("", alertMessage: TextMessage.enterValues.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
            return false
        }
        if(txtUserName.text?.characters.count == 0)
        {
               createAlert("", alertMessage: TextMessage.enterUserName.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
            return false
        }
        if(txtPassword.text?.characters.count == 0)
        {
             createAlert("", alertMessage: TextMessage.enterPassword.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
            return false
        }
        if(!utility.isEmail(txtUserName.text!))
        {
             createAlert("", alertMessage: TextMessage.emailValid.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
            return false
        }
        
        return true
    }
    
    @IBAction func btnLogin(_ sender: AnyObject) {
        
        if validate(){
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.labelText = "Loading"
            let user = (UIApplication.shared.delegate as! AppDelegate).userPool!.getUser(txtUserName.text!)
            // user = self.pool!.getUser(txtUserName.text!)
            
            user.getSession(txtUserName.text!, password: txtPassword.text!, validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: {
                (task:AWSTask!) -> AnyObject! in
                
                if task.error == nil {
                    // user is logged in - show logged in UI
                    let ret = task.result! as AWSCognitoIdentityUserSession
                    self.myToken = ret.idToken?.tokenString;
                    let accessToken = ret.accessToken?.tokenString
                    
                    print("accessToken: ", accessToken);
                    utility.setIdToken(self.myToken!)
                    utility.setAccessToken(accessToken!)
                   
                    
                    utility .setUserRole("carrier")
                    
                    self.loginLinkApi()
                    
                    
                    self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
                    if (self.user == nil) {
                        self.user = self.pool?.currentUser()
                    }
                    
                    self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                        DispatchQueue.main.async(execute: {
                            self.response = task.result
                            self.title = self.user?.username
                            
                            
                            
//                            print(self.response?.userAttributes![0] , self.response?.userAttributes![1])
//                            print(self.response?.userAttributes![2] , self.response?.userAttributes![3])
//                            print(self.response?.userAttributes![4] , self.response?.userAttributes![5])
//                            print(self.response?.userAttributes![6] , self.response?.userAttributes![7])
//                            print(self.response?.userAttributes![8] , self.response?.userAttributes![9])
//                            print(self.response?.userAttributes![10] , self.response?.userAttributes![11])
//                            print(self.response?.userAttributes![12] )
//                            utility.setUserEmail((self.user?.username)!)
//                            utility.setUserFirstName((self.response?.userAttributes![6].value)!)
//                            utility.setUserLastName((self.response?.userAttributes![11].value)!)
                            
                        })
                        return nil
                    }
                    
                    
                    
                    
                   // MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    
                    
                } else {
                    // error
                    print(task.error)
                    self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                     MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                }
                
                return nil
            })
        }
        
        
        
        
       /* if validate(){
            //"sujoy@osscube.com"
            //"sujoy@123"
            print(txtUserName.text!)
            print(txtPassword.text!)
            utility.setUserEmail(txtUserName.text!)
            let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
            loadingNotification?.mode = MBProgressHUDMode.indeterminate
            loadingNotification?.labelText = "Loading"
            let generalApiobj = GeneralAPI()
            
            let someDict:[String:String] = ["email":txtUserName.text!, "password":txtPassword.text!,"channelId":utility.getChannelId()! , "os" : typeofOS ] //utility.getChannelId()!
            generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strApiLogin, success: { (response) in
                
                
                print(response)
                  DispatchQueue.main.async {
                guard let data = response["data"] as? [String:AnyObject],let readerSignInResponse = data["readerSignInResponse"] as? [String:AnyObject] else{
                      MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                      self.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue)
                    self.loginSuccess(false)

                    return
                }
                    let msg  = "\(response["message"] as! String)"
                    if(msg.characters.count > 0)
                    {
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    }
                print(readerSignInResponse["token"] as? String)
                utility.setPermToken((readerSignInResponse["token"] as? String)!)
                utility.setCountryDialCode((readerSignInResponse["readerGetProfileResponse"]!["countryDialCode"] as? String)!)
                utility.setCountryCode((readerSignInResponse["readerGetProfileResponse"]!["countryCode"] as? String)!)
              //  utility .setUserRole("salesrep")
               
                
                    
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.getSession()
                }
            }) { (err) in
                  DispatchQueue.main.async {
                  MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                //self.dismissSelf()
                    self.loginSuccess(false)
                NSLog(" %@", err)
                }
            }

        } */
    }
    
    
    func loginLinkApi() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        let someDict:[String:String] = ["appCode":utility.getDevice()!]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strAPiLoginLink, success: { (response) in
            DispatchQueue.main.async {
                
                print(response)
                
                let dataDictionary = response["message"] as? String
                
                if dataDictionary == "Ok" {
                
                do {
                    let jwt = try decode(jwt: self.myToken!)
                    
                    let dict:[String:AnyObject] = jwt.body as [String : AnyObject]
                    print (dict)
                    let KeyArray = Array(dict.keys)
                    let preferedRole = dict["cognito:preferred_role"] as! String
                    let lastName = dict["family_name"] as! String
                    let firstName = dict["given_name"] as! String
                    let email  = dict["email"] as! String
                    if KeyArray.contains("custom:MobileNumber") {
                        let mobileNumber = dict ["custom:MobileNumber"] as! String
                       // utility.setCountryDialCode(mobileNumber)
                    }
                    if KeyArray.contains("custom:MobileCode") {
                        let country = dict ["custom:MobileCode"] as! String
                        utility.setCountryCode(country)
                        
                    }
                    if KeyArray.contains("picture") {
                        let profileUrl = dict ["picture"] as! String
                        utility.setUserProfileURL(profileUrl)
                    }else{
                         utility.setUserProfileURL(" ")
                    }
                    if KeyArray.contains("custom:MobileCode") {
                        let code = dict ["custom:MobileCode"] as! String
                        utility.setCountryCode(code)
                        
                    }
                    utility.setUserEmail(email)
                    utility.setUserFirstName(firstName)
                    utility.setUserLastName(lastName)
                    
                    
                    var roleArray = preferedRole.components(separatedBy: "/") //split(preferedRole) {$0 == "/"}
                    let roleName: String = roleArray[1]
                    
                    print(roleName)
                    if roleName != "role-core-akcarrier" {
                        utility.setIdToken(" ")
                        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                        utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.LoginFailed.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                        return
                    }
                    UAirship.namedUser().identifier = utility.getUserEmail()
                    UAirship.push().updateRegistration()

                    self.dismissSelf()
                    
                    
                    // if the call fails, the catch block is executed
                } catch {
                    print(error.localizedDescription)
                }
                }
                
                
              MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }
    }
    
    
    func getSession()->(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(Dictionary<String,String>() as Dictionary<String, AnyObject>, serviceType: .strApiSession, success: { (response) in
              DispatchQueue.main.async {
            print(response)
            guard let data = response["data"] as? [String:AnyObject],let readerGenerateSessionResponse = data["readerGenerateSessionResponse"] as? [String:AnyObject] else{
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                self.loginSuccess(false)
                return
            }
            utility.setUserToken((readerGenerateSessionResponse["token"] as? String)!)
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.dataFeeding()
                self.updateTimeZone()
 
            }
        }) { (err) in
                  DispatchQueue.main.async {
          self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
           MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    self.loginSuccess(false)
            }
        }
        
    }
    
    func dataFeeding()  {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        
        generalApiobj.hitApiwith([:], serviceType: .strApiGetSettingDetails, success: { (response) in
            DispatchQueue.main.async {
                
                print(response["data"])
                
                let dataDictionary = response["data"] as? [String : AnyObject]
                if dataDictionary?.count <= 0 {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    return
                }
                let dictResult = dataDictionary as! NSDictionary
                self.dataArrayObj = dictResult["readerGetSettingsResponse"]  as? NSDictionary
                self.setValueInDefaults(self.dataArrayObj!)
                
               self.dismissSelf()
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                NSLog(" %@", err)
                 self.loginSuccess(false)
            }
        }
    }
    
    func setValueInDefaults(_ infoDictionary : NSDictionary) {
        loginSuccess(true)
        self.defaultView = self.dataArrayObj!["dashboardDefaultView"] as? String
        
        if self.defaultView == "All" {
            utility.setselectedIndexDashBoard("0")
        }else if self.defaultView == "Watched" {
            utility.setselectedIndexDashBoard("1")
        }else if self.defaultView == "Exceptions" {
            utility.setselectedIndexDashBoard("2")
        }
        
        
        self.defaultSortedby = self.dataArrayObj!["dashboardSortBy"] as? String
        self.defaultSortedorder = self.dataArrayObj!["dashboardSortOrder"] as? String
        
        
        utility.setselectedSortBy(self.defaultSortedby!)
        utility.setselectedSortOrder(self.defaultSortedorder!)
        utility.setNotification((self.dataArrayObj!["notifications"] as? String)!)
        utility.setSilentFrom((self.dataArrayObj!["silentHrsFrom"] as? String)!)
        utility.setSilentTo((self.dataArrayObj!["silentHrsTo"] as? String)!)
        utility.setNotificationAlert((self.dataArrayObj!["sound"] as? String)!)
        utility.setNotificationVibration((self.dataArrayObj!["vibration"] as? String)!)
        utility.setNotificationBadge((self.dataArrayObj!["led"] as? String)!)
        utility.setBeaconServices((self.dataArrayObj!["beaconServiceStatus"] as? String)!)
    }
    // MARK:- Notification
    func keyboardWillShow(_ notification: Notification) {
        // self.scrlView.setContentOffset(CGPointMake(0, 120), animated: true)
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.botmLayout.constant = keyboardFrame.size.height - 100
        }, completion: { (completed: Bool) -> Void in
            
        }) 

        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
      self.scrlView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }

    
    @IBAction func btnForgotPassword(_ sender: AnyObject) {
        let forgot=STRForgotPasswordViewController(nibName: "STRForgotPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(forgot, animated: true)
        
    }
    
    func backToDashbaord() {
        //  let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //  appDelegate.initSideBarMenuFromLogin()
        
        self.dismissSelf()
    }
    
    func dismissSelf() -> () {
        
        
        if (utility.getUserRole() ==  "warehouse") {
            applicationEnvironment.ApplicationCurrentType = applicationType.warehouseOwner
        }else{
             applicationEnvironment.ApplicationCurrentType = applicationType.salesRep
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenuFromLogin()
        
        
        //backToDashbaord()
        self.dismiss(animated: true) { 
            
        }
    }

    
    func setUpFont(){
        btnLogin.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);
        vwBtnLogin.layer.cornerRadius=5;
        lblForgetSomething.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblResetYourPassword.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);
        btnSendDiagnostic.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0)
        txtUserName.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        txtPassword.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Regular", size: 14.0)! // Note the !
        ]
        
        txtPassword.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes:attributes)
        txtPassword.placeHolderTextSize = "14"
        txtUserName.placeHolderTextSize = "14"
        txtPassword.inactiveTextColorfloatingLabel = colorWithHexString("8c8c8c")
        txtUserName.attributedPlaceholder = NSAttributedString(string: "EMAIL", attributes:attributes)
        btnShow.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 12.0)
    }
    
    /*Fabric event loging*/
    func loginSuccess(_ success:Bool){
        var didSuceed:String?
        var userName: String? = txtUserName.text
        if userName == nil{
            userName = ""
        }
        if success{
         didSuceed = "YES"
        }
        else{
              didSuceed = "NO"
        }
        Answers.logCustomEvent(withName: "Login", customAttributes: [
            "user name " : userName!,
            "success"    : didSuceed!
            ])
    }
    func contentsOfDirectoryAtPath(path: String) -> [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil}
        return paths.map { aContent in (path as NSString).appendingPathComponent(aContent)}
    }
    
    func sendMail()->(){
        //let deviceId  =  utility.getDevice()
        // let dateForFileName = self.formatDateForFileName()
        //  let fileName = "/" + roleLog + "_"  + dateForFileName + "_" + deviceId! + ".csv"
        //        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + (fileName)
        let dict  =  contentsOfDirectoryAtPath(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var arrayOfFiles = Array<URL>()
        
        for file in dict!{
            if(file.contains(".csv"))
            {
                arrayOfFiles.append(URL(fileURLWithPath: file))
            }
        }
        
        //let fileData = URL(fileURLWithPath: documentsPath)
        let objectsToShare = arrayOfFiles//[fileData]
        self.activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        let model = UIDevice.current.model
        print("device type=\(model)")
        if model == "iPad" {
            print("device type inside ipad =\(model)")
            if let wPPC = activityVC!.popoverPresentationController {
                wPPC.sourceView = activityVC!.view
            }
            present( activityVC!, animated: true, completion: nil)
        }else{
            self.present(activityVC!, animated: true, completion: nil)
        }
    }
    func setUpCredential(){
        
    }
    
    func uploadToAWS(){
        let dict  =  contentsOfDirectoryAtPath(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        var arrayOfFiles = [AWSTask<AnyObject>]()
        
        
        let transferManager = AWSS3TransferManager.default()
        
        for file in dict!{
            if(file.contains(".csv"))
            {
                //arrayOfFiles.append(URL(fileURLWithPath: file))
                let uploadingFileURL = URL(fileURLWithPath: file)
                
                let uploadRequest = AWSS3TransferManagerUploadRequest()
                
                uploadRequest?.bucket = "akwa-tracking-logs"
                uploadRequest?.key = uploadingFileURL.lastPathComponent
                uploadRequest?.body = uploadingFileURL
                let task = transferManager.upload(uploadRequest!)
                arrayOfFiles.append(task)
            }
        }
        
        AWSTask<AnyObject>.init(forCompletionOfAllTasks: arrayOfFiles).continueWith { (task) -> Any? in
            if let error = task.error as? NSError {
                
                
                
            }
            else
            {
                
            }
            return nil;
            
        }
    }

    func updateTimeZone(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["timezone":localTimeZoneAbbreviation as AnyObject], serviceType: .strUpdateTimeZone, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                guard let data = response["data"] as? [String:AnyObject],let _ = data["readerGenerateSessionResponse"] as? [String:AnyObject] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    return
                }
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }) { (err) in
            DispatchQueue.main.async {
                self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }

    }
    

}

extension UIViewController {
    open override static func initialize() {
        
        // make sure this isn't a subclass
        if self != UIViewController.self {
            return
        }
        
        let _: () = {
            let originalSelector = #selector(UIViewController.viewWillAppear(_:))
            let swizzledSelector = #selector(UIViewController.newViewWillAppear(_:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }()
    }
    
    // MARK: - Method Swizzling
    
    func newViewWillAppear(_ animated: Bool) {
        self.newViewWillAppear(animated)
        var name = NSStringFromClass(self.classForCoder)
        if(self.isKind(of: UINavigationController.self))
        {
            return
        }
        if name.contains(".")
        {
            let arr = name.components(separatedBy: ".")
            name = arr[arr.count-1]
        }
        if  (name != "") {
            print("viewWillAppear: \(name)")
            Answers.logCustomEvent(withName: "VIEW APPEAR", customAttributes: ["VIEW NAME": name])
        } else {
            print("viewWillAppear: \(self)")
        }
    }
    
    
}
extension STRLoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as? NSError {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.txtUserName.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func updateCode()
    {
       // if(lblBuild.text == "")
       // {
            lblBuild.text = "V" + version + buildType + " Code : " + (((utility.getDevice()) != nil) ? utility.getDevice()!:"")
       // }
       // else{
       //     timerCodeUpdate?.invalidate();
       // }
        
    }



}



