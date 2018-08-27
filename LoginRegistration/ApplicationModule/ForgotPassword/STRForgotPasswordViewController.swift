import UIKit
import Crashlytics
import AWSCognitoIdentityProvider


enum FRgetStages:Int {
    case stageRequest = 0
    case stageValidate
    case stageReset
}
class STRForgotPasswordViewController: UIViewController {
    var token: String!
    var email: String!
    
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    //MARK: already Have Code SetUp
    var alreadyHaveCode: Bool?
    @IBOutlet var txtAHCheight: NSLayoutConstraint!
    @IBOutlet var vwAlreadyHaveCode: UIView!
    @IBOutlet var vwConfirmation: UIView!
    @IBOutlet var btnResendCode: UIButton!
    
    @IBOutlet var btnBackToLogin: UIButton!
    
    @IBOutlet var imgBottoMAlreadyCode: UIImageView!
    @IBAction func btnResend(_ sender: AnyObject) {
        self.forgetPasswordStage = .stageRequest
        if validate()
        {
            requestFrgtPassword()

        }

    }
    
    
    @IBAction func btnAlreadyHaveCode(_ sender: AnyObject) {
        if(btnResendCode.tag == 0)
        {
            alreadyHaveCode = true
            showResendCodeTxt()
            btnResendCode.tag = 1
            self.forgetPasswordStage = .stageValidate
            btnSend.setTitle("SUBMIT", for: UIControlState())
        }
        else{
            alreadyHaveCode = false
            hideResendCodeTxt()
            btnResendCode.tag = 0
            txtAlreadyHaveCode.text = ""
            self.forgetPasswordStage = .stageRequest
          btnSend.setTitle("SEND", for: UIControlState())
        }
    }
    
    
    
    
    @IBOutlet var imgCheck: UIImageView!
    @IBOutlet var imgUserInfo: UIImageView!
    @IBOutlet var lblAlreadyHaveCode: UILabel!
    @IBOutlet var txtAlreadyHaveCode: UITextField!
    //MARK:--------
    @IBOutlet var resendHeightLayout: NSLayoutConstraint!
    @IBOutlet var bottomLayout: NSLayoutConstraint!
    @IBOutlet var scrlView: UIScrollView!
    @IBOutlet var btnSend: UIButton!
    @IBAction func btnSend(_ sender: AnyObject) {
        switch forgetPasswordStage! {
            
        case .stageRequest :
            if validate()
            {
                requestFrgtPassword()//requestForgetPassword()
                
            }
            break
        case .stageValidate :
            if validate()
            {
                requestValidatePassword()
            }
            break
        case .stageReset :
            if(txtUserInfo.isFirstResponder)
            {
                self.txtConfirmPass.becomeFirstResponder()
                self.txtConfirmPass.returnKeyType=UIReturnKeyType.go
                self.scrlView.setContentOffset(CGPoint(x: 0, y: 120), animated: true)
            }
            else
            {
                if validate()
                {
                      validateResetPawwsord()// requestResetPassword()
                }
            }
            
            
            break
        }
        self.view.endEditing(true)

    }
    
    func requestFrgtPassword()
    {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        
        self.user = self.pool?.getUser(txtUserInfo.text!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
                    
                    
                } else {
                     MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
                    self?.createAlert("", alertMessage: TextMessage.emailsend.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    self?.requestOTPLog(true)
                    if(self?.alreadyHaveCode == true)
                    {
                        self?.forgetPasswordStage = .stageValidate
                        self?.email = self?.txtUserInfo.text
                        self?.txtAlreadyHaveCode.text = ""
                        
                    }
                    else
                    {
                    
                        self?.alreadyHaveCode = true
                        self?.showResendCodeTxt()
                        self?.btnResendCode.tag = 1
                        self?.forgetPasswordStage = .stageValidate
                        self?.btnSend.setTitle("SUBMIT", for: UIControlState())
                    }
                }
            })
            return nil
        } 
    }
    
    func validateResetPawwsord() {
        //confirm forgot password with input from ui.
        var tokenObj : String
        if(self.alreadyHaveCode == true)
        {
            tokenObj = txtAlreadyHaveCode.text!
        }
        else
            
        {
            tokenObj =  self.token
        }
        self.user?.confirmForgotPassword(tokenObj, password: txtUserInfo.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as? NSError {
                    
                    self?.dismiss()
                } else {
                    
                }
            })
            return nil
        }
    }
    
    
    
    @IBOutlet var vwSndBtn: UIView!
    @IBAction func btnBackToLogin(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet var txtHeight: NSLayoutConstraint!
    @IBOutlet var vwHeight: NSLayoutConstraint!
    @IBOutlet var alreadyButton: NSLayoutConstraint!
    @IBOutlet var imgBottomLine: UIImageView!
    @IBOutlet var lblBackToLogin: UILabel!
    @IBOutlet var txtUserInfo: UITextField!
    @IBOutlet var lblMessage: UILabel!
    
    @IBOutlet var txtConfirmPass: UITextField!
    var forgetPasswordStage:FRgetStages?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        forgetPasswordStage = .stageRequest
        alreadyHaveCode = false
         self.navigationController?.isNavigationBarHidden = true
        addKeyboardNotifications()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFont()
         setUpForInitialDisplay()
        //  UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String)
    {
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancelTitle)
        alert.show()
    }
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(STRForgotPasswordViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(STRForgotPasswordViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
        
        
        if(forgetPasswordStage == .stageReset)
        {
                            if(textField ==  self.txtUserInfo)
                            {
                                self.txtConfirmPass.becomeFirstResponder()
                                self.txtConfirmPass.returnKeyType=UIReturnKeyType.default
                                self.scrlView.setContentOffset(CGPoint(x: 0, y: 120), animated: true)
                                return true
                            }
            
        }
        
        if(self.alreadyHaveCode == true)
        {
            if(textField == self.txtUserInfo)
            {
                self.txtAlreadyHaveCode.becomeFirstResponder()
                return true
            }
        }
        
        
        
//            switch forgetPasswordStage! {
//                
//            case .StageRequest :
//                if validate()
//                {
//                 requestForgetPassword()
//                 textField.resignFirstResponder()
//                }
//                break
//            case .StageValidate :
//                if validate()
//                {
//                    requestValidatePassword()
//                    textField.resignFirstResponder()
//                }
//                break
//            case .StageReset :
//                if(textField ==  self.txtUserInfo)
//                {
//                    self.txtConfirmPass.becomeFirstResponder()
//                    self.txtConfirmPass.returnKeyType=UIReturnKeyType.Go
//                    self.scrlView.setContentOffset(CGPointMake(0, 120), animated: true)
//                }
//                else
//                {
//                if validate()
//                {
//                    requestResetPassword()
//                    textField.resignFirstResponder()
//                }
//                }
//
//                
//                break
//            }
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(string == " ")
        {
            return false
        }
//        if(textField == self.txtUserInfo && forgetPasswordStage != .StageReset )
//        {
//            textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
//            return false
//        }

        return true
    }
    func validate()->(Bool){
        
        switch forgetPasswordStage! {
        case .stageRequest:
            if((txtUserInfo.text?.characters.count == 0) )
            {
                createAlert("", alertMessage: TextMessage.enterValues.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                return false
            }
            if(!utility.isEmail(txtUserInfo.text!))
            {
                createAlert("", alertMessage: TextMessage.emailValid.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                return false
            }
            break
        case .stageValidate:
            if(self.alreadyHaveCode == true)
            {
                if((txtUserInfo.text?.characters.count == 0) )
                {
                    createAlert("", alertMessage: TextMessage.enterValues.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    return false
                }
                if(!utility.isEmail(txtUserInfo.text!))
                {
                    createAlert("", alertMessage: TextMessage.emailValid.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    return false
                }
                if((txtAlreadyHaveCode.text?.characters.count == 0) )
                {
                    createAlert("", alertMessage: TextMessage.entertoken.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    return false
                }
            }
            else
            {
                if((txtUserInfo.text?.characters.count == 0) )
                {
                    createAlert("", alertMessage: TextMessage.entertoken.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    return false
                    }
                if(txtUserInfo.text != self.token)
                {
                    createAlert("", alertMessage: TextMessage.validtoken.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    return false
                }
            }
            break
        case .stageReset:
            if((txtUserInfo.text?.characters.count == 0) )
            {
                createAlert("", alertMessage: TextMessage.newpassword.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                return false
            }
            if(txtUserInfo.text != self.txtConfirmPass.text)
            {
                createAlert("", alertMessage: TextMessage.confirmpassword.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                return false
            }

            break
        }
        return true
    }
    //MARK:  API methods
    func requestForgetPassword()->(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["email":txtUserInfo.text! as AnyObject], serviceType: .strApiRequestForgetPassword, success: { (response) in
               DispatchQueue.main.async {
            if(response["status"]?.intValue != 1)
            {
                
              MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                                   loadingNotification = nil
                self.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue)
                self.requestOTPLog(false)
                return
            }
            guard let data = response["data"] as? [String:AnyObject],let readerGenerateSessionResponse = data["readerRequestForgotPasswordResponse"] as? [String:AnyObject] else{
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                self.requestOTPLog(false)

                               return
            }
            self.token = "\(readerGenerateSessionResponse["token"]!)"
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            self.createAlert("", alertMessage: TextMessage.emailsend.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                self.requestOTPLog(true)
                if(self.alreadyHaveCode == true)
                {
                    self.forgetPasswordStage = .stageValidate
                    self.email = self.txtUserInfo.text
                    self.txtAlreadyHaveCode.text = ""

                }
                else
                {
                    
                    
               self.setupForEnterToken()
                }
               
            }
           
        }) { (err) in
              DispatchQueue.main.async {
            self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.requestOTPLog(false)

            }
        }

    }
    func requestValidatePassword()->(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
//        var dict: Dictionary<String,String>?
//        if(self.alreadyHaveCode == true)
//        {
//            dict = ["email":self.txtUserInfo.text!,"token":txtAlreadyHaveCode.text!]
//        }
//        else
//
//        {
//          dict =  ["email":email!,"token":self.token]
//        }
        
        self.user?.confirmForgotPassword(txtAlreadyHaveCode.text!, password: self.txtConfirmPass.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
                if let error = task.error as? NSError {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    MBProgressHUD.hideAllHUDs(for: self?.view, animated: true)
//                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    self?.sendOTPlog(false)
                    self?.dismiss()
                }
            })
            return nil
        }
        
    
    }
    func requestResetPassword()->(){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["email":email! as AnyObject,"token":self.token as AnyObject,"password":txtUserInfo.text! as AnyObject], serviceType: .strApiResetForgetPassword, success: { (response) in
            DispatchQueue.main.async {
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    self.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue)
                    self.resetPassword(false)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let _ = data["readerResetPasswordResponse"] as? [String:AnyObject] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                    self.resetPassword(false)

                    return
                }
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.resetPassword(true)
                self.dismiss()
            }
        }) { (err) in
            DispatchQueue.main.async {
                self.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.resetPassword(false)
            }
        }
    }

    //MARK: UI settings and changes
    func setupForEnterToken()->(){
       // self.vwAlreadyHaveCode.hidden =  true
        lblMessage.text="Enter your code below."
        self.txtUserInfo.isHidden = true
        
        email=txtUserInfo.text
//        txtUserInfo.text=""
//        let attributes = [
//            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5),
//            NSFontAttributeName : UIFont(name: "SourceSansPro-Semibold", size: 15)! // Note the !
//        ]
//        txtUserInfo.attributedPlaceholder = NSAttributedString(string: "CODE", attributes:attributes)
//        txtUserInfo.placeholder = "CODE"
        txtUserInfo.returnKeyType=UIReturnKeyType.default
        txtAlreadyHaveCode.becomeFirstResponder()
        btnSend .setTitle("SUBMIT", for: UIControlState())
        lblBackToLogin.text = "CANCEL"
        
       // self.showResendCodeTxt()
        self.alreadyHaveCode = true
        forgetPasswordStage = .stageValidate
        
        txtConfirmPass.isHidden = false
        
        
        
    }
    func setupUIForReset()->(){
        
        if(alreadyHaveCode == true)
        {
            self.vwAlreadyHaveCode.isHidden = true
        }
        
        
        txtUserInfo.text=""
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Semibold", size: 15)! // Note the !
        ]
//        txtUserInfo.attributedPlaceholder = NSAttributedString(string: "ENTER PASSWORD", attributes:attributes)
//        txtUserInfo.placeholder = "ENTER PASSWORD"
//        txtHeight.constant = 50
//        vwHeight.constant =  vwHeight.constant - 20
//        imgBottomLine.isHidden =  false
        txtConfirmPass.isHidden = false
        txtConfirmPass.attributedPlaceholder = NSAttributedString(string: "CONFIRM PASSWORD", attributes:attributes)
        txtConfirmPass.placeholder = "CONFIRM PASSWORD"
        txtConfirmPass.isSecureTextEntry = true
        txtUserInfo.returnKeyType=UIReturnKeyType.next
        txtUserInfo.becomeFirstResponder()
        txtUserInfo.isSecureTextEntry = true
        forgetPasswordStage = .stageReset
    }
    func setUpForInitialDisplay(){
        lblMessage.text = "Enter your email below and we'll send you code to reset your password."
        txtUserInfo.text=""
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Semibold", size: 15)! // Note the !
        ]
     //   txtHeight.constant = 0
        vwHeight.constant =  vwHeight.constant - (40 + 14 + 1) + 83 //height of already have
     //   imgBottomLine.isHidden =  true
        txtUserInfo.attributedPlaceholder = NSAttributedString(string: "EMAIL", attributes:attributes)
        txtUserInfo.placeholder = "EMAIL"
 //       vwConfirmation.isHidden = true
        
        //MARK: A H C
        self.txtAlreadyHaveCode.attributedPlaceholder =  NSAttributedString(string: "CODE", attributes:attributes)
        self.txtAlreadyHaveCode.placeholder = "CODE"
        hideResendCodeTxt()
    }
    
    
    func showResendCodeTxt()
    {
       vwConfirmation.isHidden = false
       imgUserInfo.isHidden = false
        txtUserInfo.isHidden = false
        self.txtAHCheight.constant = 40
         vwHeight.constant =  vwHeight.constant + 52
        self.imgBottoMAlreadyCode.isHidden = false
        self.btnResendCode.isHidden = false
        txtAlreadyHaveCode.isHidden = false
        self.imgCheck.image = UIImage.init(named:"selected")
        self.txtUserInfo.returnKeyType=UIReturnKeyType.next
       showConfirmPassword()
    }
    
    func showConfirmPassword()  {
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Semibold", size: 15)! // Note the !
        ]
      
        txtConfirmPass.isHidden = false
        txtConfirmPass.attributedPlaceholder = NSAttributedString(string: "NEW PASSWORD", attributes:attributes)
        txtConfirmPass.placeholder = "NEW PASSWORD"
        txtConfirmPass.isSecureTextEntry = true
    }
    func hideResendCodeTxt()
    {
        imgUserInfo.isHidden = false
        txtUserInfo.isHidden = false
        vwConfirmation.isHidden = true

        self.txtAHCheight.constant = 0
        vwHeight.constant =  vwHeight.constant - 52
        self.btnResendCode.isHidden = true
        self.imgBottoMAlreadyCode.isHidden = true
        self.imgCheck.image = UIImage.init(named: "check")
         self.txtUserInfo.returnKeyType=UIReturnKeyType.default
    }
    
    
    func dismiss()->(){
    self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //self.navigationController?.navigationBarHidden=true
    }
    func setUpFont(){
        btnSend.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 14.0);
        vwSndBtn.layer.cornerRadius=5;
        lblMessage.font = UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        txtUserInfo.font =  UIFont(name: "SourceSansPro-Semibold", size: 15.0);
        txtConfirmPass.font =  UIFont(name: "SourceSansPro-Semibold", size: 15.0);
        let attributes = [
            NSForegroundColorAttributeName: UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5),
            NSFontAttributeName : UIFont(name: "SourceSansPro-Semibold", size: 15)! // Note the !
        ]
        
        txtUserInfo.attributedPlaceholder = NSAttributedString(string: "EMAIL", attributes:attributes)
        txtUserInfo.placeholder = "EMAIL"
        txtConfirmPass.attributedPlaceholder = NSAttributedString(string: "PASSWORD", attributes:attributes)
        txtConfirmPass.placeholder = "PASSWORD"
         lblBackToLogin.font = UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        txtAlreadyHaveCode.font =  UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        btnResendCode.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 14.0)
        lblAlreadyHaveCode.font = UIFont(name: "SourceSansPro-Semibold", size: 14)
        

    }
    
    
    
    /*Fabric event loging*/
    func requestOTPLog(_ success:Bool){
        var good: String?
        if success{
            good = "YES"
        }
        else{
            good = "NO"
        }
        Answers.logCustomEvent(withName: "OTP REQUEST", customAttributes: ["email": txtUserInfo.text!,
            "Success":good!])
    }
    func sendOTPlog(_ success:Bool){
        var OTP: String
        if(self.alreadyHaveCode == true)
        {
            OTP = txtAlreadyHaveCode.text!
        }
        else
            
        {
            OTP =  self.token
        }
        var good: String?
        if success{
            good = "YES"
        }
        else{
            good = "NO"
        }
        Answers.logCustomEvent(withName: "OTP SEND", customAttributes: ["OTP": OTP,
            "Success":good!])
    }

    func resetPassword(_ success:Bool){
        var good: String?
        if success{
            good = "YES"
        }
        else{
            good = "NO"
        }
        Answers.logCustomEvent(withName: "PASSWORD RESET", customAttributes: ["Success":good!])
    }

    
      

}
