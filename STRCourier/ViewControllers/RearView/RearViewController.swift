import UIKit
import AWSCognitoIdentityProvider
import AWSS3
import AKLog
import AirshipKit

class RearViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIDocumentInteractionControllerDelegate{

    @IBOutlet var tableView: UITableView!


    var tableData: [String] = [ RearSlider.inventory.rawValue,RearSlider.notification.rawValue,   RearSlider.help.rawValue,RearSlider.Map.rawValue, RearSlider.about.rawValue,RearSlider.sendDiagnostic.rawValue,((AKApplicationState.sharedHandler.getLoggingStatus()) ?RearSlider.enableLoging.rawValue:RearSlider.disableLoging.rawValue),RearSlider.logout.rawValue]
    @IBOutlet var profileImageBtn : UIButton?
    @IBOutlet var profileImage: UIImageView?
    @IBOutlet var profileName: UILabel?
    var selectedRow = 0          
    
    @IBAction func btnEditProfile(_ sender: AnyObject) {
          let vw = EditViewController(nibName: "EditViewController", bundle: nil)
         self.revealViewController().revealToggle(animated: true)
          let leftSideNav = UINavigationController(rootViewController: vw)
         self.revealViewController().setFront(leftSideNav, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationController?.isNavigationBarHidden = true
       
        profileImageBtn!.layer.borderWidth = 2
        profileImageBtn!.layer.masksToBounds = false
        profileImageBtn!.layer.borderColor = UIColor.white.cgColor
        profileImageBtn!.layer.cornerRadius = profileImageBtn!.frame.height/2
        profileImageBtn!.clipsToBounds = true
        
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "SideBarTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "sideBarCell")
        tableView.tableFooterView = UIView()
        if(utility.getUserToken() != nil && utility.getUserToken() != " ")
        {
            self.getUSerProfile()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfile), name: NSNotification.Name(rawValue: "UPDATEPROFILENOTIFICATION"), object: nil)
        setUpFont()
    }
    
    func updateProfile(){
       setUserDetail()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if(utility.getUserFirstName() != nil && utility.getUserFirstName() != " ")
        {
            setUserDetail()

        }

    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SideBarTableCell = self.tableView.dequeueReusableCell(withIdentifier: "sideBarCell") as! SideBarTableCell
        cell.setupCell(indexPath, selectedvalue: false, titleString:tableData[indexPath.row])
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableData[indexPath.row] as! String {
        case RearSlider.My_deleveries.rawValue:
            
            break
        case RearSlider.My_Issues.rawValue:
            let strIssues = STRMyIssuesViewController.init(nibName: "STRMyIssuesViewController", bundle: nil)
            let leftSideNav = UINavigationController(rootViewController: strIssues)
            self.revealViewController().setFront(leftSideNav, animated: true)
            break
        case RearSlider.notification.rawValue:
            
            let strNotification = STRNotificationVC.init(nibName: "STRNotificationVC", bundle: nil)
            let leftSideNav = UINavigationController(rootViewController: strNotification)
            self.revealViewController().setFront(leftSideNav, animated: true)
            break
        case RearSlider.Map.rawValue:
            
            let strNotification = AKMapViewController.init(nibName: "AKMapViewController", bundle: nil)
            let leftSideNav = UINavigationController(rootViewController: strNotification)
            self.revealViewController().setFront(leftSideNav, animated: true)
            break
        case  RearSlider.settings.rawValue:
            
            break
        case RearSlider.inventory.rawValue:
            let viewController = STRInventorViewController.init(nibName:"STRInventorViewController", bundle: nil)
            let  navController = UINavigationController.init(rootViewController: viewController)
            let dictLocation = utility.getselectedLocation() as? Dictionary<String,Any>
            if(dictLocation?.count != 0)
            {
                (viewController as? STRInventorViewController)?.appearInformation = .strFromFirstLoadPersisted
            }
            let dict = utility.getselectedFloor() as? Dictionary<String,Any>
            if(dict?.count != 0)
            {
                let viewController = STRInventorViewController_copy.init(nibName:"STRInventorViewController_copy", bundle: nil)
                viewController.dictFloorJT = dict!
                viewController.LocationName = dictLocation?["address"]  as! String;
                navController.pushViewController(viewController, animated: false);
            }
            
            self.revealViewController().setFront(navController, animated: true)
            
            

            break

        case  RearSlider.help.rawValue:
            let strNotification = STRHelpViewController.init(nibName: "STRHelpViewController", bundle: nil)
            let leftSideNav = UINavigationController(rootViewController: strNotification)
            self.revealViewController().setFront(leftSideNav, animated: true)
            
            break
            
        case RearSlider.about.rawValue:
            let strNotification = STRAboutViewController.init(nibName: "STRAboutViewController", bundle: nil)
            let leftSideNav = UINavigationController(rootViewController: strNotification)
            self.revealViewController().setFront(leftSideNav, animated: true)
            
            break
        case RearSlider.logout.rawValue:
            UAirship.namedUser().identifier = "___"
            UAirship.push().updateRegistration()
            logOut();
            break
            
        case RearSlider.sendDiagnostic.rawValue:
            sendMail()
            uploadToAWS()
            break
        case RearSlider.enableLoging.rawValue:
            if(!AKApplicationState.sharedHandler.enableLogs())
            {
                let index = self.tableData.index(of:RearSlider.enableLoging.rawValue)
                self.tableData.remove(at: index!)
                self.tableData.insert(RearSlider.disableLoging.rawValue, at: index!)
            }
            utility.createAlert("", alertMessage:"Logging Enabled" , alertCancelTitle: "OK", view: self);
            break
        case RearSlider.disableLoging.rawValue:
            if(AKApplicationState.sharedHandler.enableLogs())
            {
                let index = self.tableData.index(of:RearSlider.disableLoging.rawValue)
                self.tableData.remove(at: index!)
                self.tableData.insert(RearSlider.enableLoging.rawValue, at: index!)
            }
            utility.createAlert("", alertMessage:"Logging Disabled" , alertCancelTitle: "OK", view: self);
            break

        default:
            break
        }
        self.tableView.reloadData()
        self.revealViewController().revealToggle(animated: true)
        
    }
    @IBAction func editButtonClicked(_ sender: AnyObject) {
        
        
    }
    

    //MARK: get user profile from api
    
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
        
        
        if(utility.getUserFirstName() != nil && utility.getUserFirstName() != " ")
        {
            self.profileName!.text = "\(utility.getUserFirstName()!) \(utility.getUserLastName()!)"
            
        }
        
       if(utility.getUserProfileURL() != nil || utility.getUserProfileURL() != " "){
         let url = URL(string: "\(utility.getUserProfileURL()!)")
        
       //  self.profileImage?.sd_setImage(with: url, placeholderImage:UIImage(named: "editprofile_default" ))
        
          self.profileImage?.sd_setImage(with: url,
                              placeholderImage: UIImage(named: "editprofile_default" ),
                              options: [],
                              completed: { (image ) in
                                self.profileImageBtn!.setBackgroundImage(self.profileImage?.image, for: UIControlState())
          })
        }
        
//         self.profileImage?.sd_setImage(with: url, placeholderImage: UIImage(named: "editprofile_default" ), completed: { (image ) in
//            self.profileImageBtn!.setBackgroundImage(self.profileImage?.image, for: UIControlState())
//         })
     }
    
    
    
    
    func logOut() {
      
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        let someDict:[String:String] = ["appCode":utility.getDevice()!]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strAPiLogoutUNLink, success: { (response) in
            DispatchQueue.main.async {
                utility.setUserToken(" ")
                self.presentLogin()
                print(response["data"])
                
                let dataDictionary = response["message"] as? String
                
                if dataDictionary == "Ok" {
                    let credentialsProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegion, identityPoolId: CognitoIdentityId)
                    // create pool configuration
                    
                    credentialsProvider.clearCredentials()
                    credentialsProvider.clearKeychain()
                    utility.setChannelId(" ")
                    utility.setCountryDialCode(" ")
                    utility.setCountryCode(" ")
                    utility.setUserProfileURL(" ")
                    let pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
                    let user = pool.currentUser()
                    utility.setIdToken(" ")
                    user?.signOut()
                    self.presentLogin()
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
    
    func presentLogin() -> () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
    
    func setUpFont(){
        self.profileName?.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);

    }
    func formatDateForFileName()-> String{
        let epoch = "\(Int64(floor(Date().timeIntervalSince1970 * 1000.0)))"
        let str =  epoch.substring(with: epoch.characters.index(epoch.startIndex, offsetBy: 0)..<epoch.characters.index(epoch.startIndex, offsetBy: 10))
        let epc = NSString(string: str).doubleValue
        let date =  Date.init(timeIntervalSince1970:epc)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMMdd"
        let timeStamp = formatter.string(from: date)
        //var tempInt :Int  = Int(timeStamp)!
        return timeStamp
    }
    func contentsOfDirectoryAtPath(path: String) -> [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil}
        return paths.map { aContent in (path as NSString).appendingPathComponent(aContent)}
    }

    func sendMail()->(){
        //let deviceId  =  utility.getDevice()
        //let dateForFileName = self.formatDateForFileName()
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

        
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        
        
        let model = UIDevice.current.model
        print("device type=\(model)")
        if model == "iPad" {
            
            print("device type inside ipad =\(model)")
            
            if let wPPC = activityVC.popoverPresentationController {
                wPPC.sourceView = activityVC.view
            }
            present( activityVC, animated: true, completion: nil)
            
        }else{
            
            
            self.present(activityVC, animated: true, completion: nil)
        }
        
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

}
