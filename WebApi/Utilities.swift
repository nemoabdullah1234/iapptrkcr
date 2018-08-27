import Foundation


var selectedIndex = 1


enum applicationType {
    case salesRep, warehouseOwner
}


struct applicationEnvironment {
    static var ApplicationCurrentType = applicationType.salesRep
}




class MyCustomLabel : UILabel {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textColor = UIColor.blue
    }
}


class Point
{
    fileprivate var _x : Double = 0             // _x -> backingX
    var x : Double {
        set { _x = 2 * newValue }
        get { return _x / 2 }
    }
}

enum STRItemDetail: Int{
    case  strItemDetailFromSearch = 0
    case  strItemDetailFromItemScan
    case  strItemDetailFromCaseDetail
}
func customizeNavigation(_ ref : UIViewController) {
    
    ref.navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 22.0/255.0, green: 25.0/255.0, blue: 31.0/255.0, alpha: 1)

    ref.navigationController?.navigationBar.isTranslucent = false
    let button: UIButton = UIButton.init()
    
    button.setImage(UIImage(named: "sidemenu"), for: UIControlState())
    button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    
    let barButton = UIBarButtonItem(customView: button)
    ref.navigationItem.leftBarButtonItem = barButton
    
    
    let buttonSearch: UIButton = UIButton.init()
    
    buttonSearch.setImage(UIImage(named: "dot"), for: UIControlState())
    //add function for button
    //set frame
    buttonSearch.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    
    let buttonSort: UIButton = UIButton.init()
    
    buttonSort.setImage(UIImage(named: "search"), for: UIControlState())
    //add function for button
    buttonSort.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    
    
    
    let barButtonSearch = UIBarButtonItem(customView: buttonSearch)
     let barButtonSort = UIBarButtonItem(customView: buttonSort)
    //assign button to navigationbar
    ref.navigationItem.rightBarButtonItems = [barButtonSearch , barButtonSort]

}

func customNavigationforBack(_ ref : UIViewController) {
    ref.navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 22.0/255.0, green: 25.0/255.0, blue: 31.0/255.0, alpha: 1)
    ref.navigationController?.navigationBar.isTranslucent = false
    
    
    let button: UIButton = UIButton.init()
    button.setImage(UIImage(named: "back"), for: UIControlState())
    button.addTarget(ref, action: #selector(STRDetailSliderViewController.poptoPreviousScreen), for: UIControlEvents.touchUpInside)
    button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let spacing : CGFloat = 50;
    button.titleEdgeInsets = UIEdgeInsetsMake(-spacing, 0.0, 0.0, 0.0)
    let barButton = UIBarButtonItem(customView: button)
    ref.navigationItem.leftBarButtonItem = barButton
    
    
    
    
    let buttonSort: UIButton = UIButton.init()
    buttonSort.setImage(UIImage(named: "search"), for: UIControlState())
    //add function for button
    buttonSort.addTarget(ref, action: #selector(HomeViewController.sortButtonClicked(_:)), for: UIControlEvents.touchUpInside)
    buttonSort.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let barButtonSort = UIBarButtonItem(customView: buttonSort)
    ref.navigationItem.rightBarButtonItems = [barButtonSort]
    
    ref.navigationController?.navigationBar.titleTextAttributes =
        [NSForegroundColorAttributeName: UIColor.white,
         NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!]
}

func customizeNavigationforAll(_ ref : UIViewController) {
    
    let button: UIButton = UIButton.init()
    ref.navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 22.0/255.0, green: 25.0/255.0, blue: 31.0/255.0, alpha: 1)
    ref.navigationController?.navigationBar.isTranslucent = false
    
    button.setImage(UIImage(named: "back"), for: UIControlState())
    //add function for button
    button.addTarget(ref, action: #selector(STRNotificationVC.backToDashbaord), for: UIControlEvents.touchUpInside)
    //set frame
    button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    
    let barButton = UIBarButtonItem(customView: button)
    //assign button to navigationbar
    ref.navigationItem.leftBarButtonItem = barButton
    
    
    let buttonSort: UIButton = UIButton.init()
    buttonSort.setImage(UIImage(named: "search"), for: UIControlState())
    //add function for button
    buttonSort.addTarget(ref, action: #selector(HomeViewController.sortButtonClicked(_:)), for: UIControlEvents.touchUpInside)
    buttonSort.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let barButtonSort = UIBarButtonItem(customView: buttonSort)
    ref.navigationItem.rightBarButtonItems = [barButtonSort]
    
    
    ref.navigationController?.navigationBar.titleTextAttributes =
        [NSForegroundColorAttributeName: UIColor.white,
         NSFontAttributeName: UIFont(name: "Roboto-Light", size: 20)!]
    
}

func customizeNavigationWithDeleteAll(_ ref : UIViewController) {
    
    let button: UIButton = UIButton.init()
    ref.navigationController!.navigationBar.barTintColor = UIColor(colorLiteralRed: 22.0/255.0, green: 25.0/255.0, blue: 31.0/255.0, alpha: 1)
    ref.navigationController?.navigationBar.isTranslucent = false
    
    button.setImage(UIImage(named: "back"), for: UIControlState())
    //add function for button
    button.addTarget(ref, action: #selector(STRNotificationVC.backToDashbaord), for: UIControlEvents.touchUpInside)
    //set frame
    button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    
    let barButton = UIBarButtonItem(customView: button)
    //assign button to navigationbar
    ref.navigationItem.leftBarButtonItem = barButton
    
    
    let buttonSort: UIButton = UIButton.init()
    buttonSort.setImage(UIImage(named: "search"), for: UIControlState())
    //add function for button
    buttonSort.addTarget(ref, action: #selector(HomeViewController.sortButtonClicked(_:)), for: UIControlEvents.touchUpInside)
    buttonSort.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let barButtonSort = UIBarButtonItem(customView: buttonSort)
    
    let buttonDeleteAll: UIButton = UIButton.init()
    buttonDeleteAll.setImage(UIImage(named: "delete"), for: UIControlState())
    //add function for button
    buttonDeleteAll.addTarget(ref, action: #selector(STRNotificationVC.deleteButtonClicked(_:)), for: UIControlEvents.touchUpInside)
    buttonDeleteAll.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    let barButtonDelete = UIBarButtonItem(customView: buttonDeleteAll)
    
    
    
    ref.navigationItem.rightBarButtonItems = [barButtonSort, barButtonDelete]
    
    
    ref.navigationController?.navigationBar.titleTextAttributes =
        [NSForegroundColorAttributeName: UIColor.white,
         NSFontAttributeName: UIFont(name: "Roboto-Light", size: 22)!]
    
}


class utility:NSObject{
    
    class func isEmail(_ email: String)->(Bool){
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
        
    }
    
    
    class func getselectedIndexDashBoard()->(String?){
        return UserDefaults.standard.value(forKey: "SelectedIndexDashboard") as? String
    }
    class func setselectedIndexDashBoard(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "SelectedIndexDashboard")
    }
    
    class func getselectedSortBy()->(String?){
        return UserDefaults.standard.value(forKey: "DashbordSortedBY") as? String
    }
    class func setselectedSortBy(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "DashbordSortedBY")
    }
    class func getChannelId()->(String?){
        let str = UserDefaults.standard.value(forKey: "ChannelId") as? String
        if( str == nil)
        {
            return " "
        }
        else
        {
            return str
        }

    }
    class func setChannelId(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "ChannelId")
    }
    
    class func getProjectId()->(String?){
        return UserDefaults.standard.value(forKey: "ProjectId") as? String
    }
    class func setProjectId(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "ProjectId")
    }
    
    class func getClientId()->(String?){
        return UserDefaults.standard.value(forKey: "ClientId") as? String
    }
    class func setClientId(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "ClientId")
    }
    
    class func setIdToken(_ token: String){
        UserDefaults.standard.set(token, forKey: "IDTOKEN")
    }
    class func getIdToken()->(String!){
        return UserDefaults.standard.value(forKey: "IDTOKEN") as? String
    }
    
    
    class func setAccessToken(_ token: String){
        UserDefaults.standard.set(token, forKey: "ACCESSTOKEN")
    }
    class func getAccessToken()->(String!){
        return UserDefaults.standard.value(forKey: "ACCESSTOKEN") as! String
    }
    
    
    
    class func getselectedSortOrder()->(String?){
        return UserDefaults.standard.value(forKey: "DashbordSortedOrder") as? String
    }
    class func setselectedSortOrder(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "DashbordSortedOrder")
    }
    class func getNotificationAlert()->(String?){
        return UserDefaults.standard.value(forKey: "NotificationAlert") as? String
    }
    class func setNotificationAlert(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "NotificationAlert")
    }
    class func getNotificationVibration()->(String?){
        return UserDefaults.standard.value(forKey: "NotificationVibration") as? String
    }
    class func setNotificationVibration(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "NotificationVibration")
    }
    class func getNotificationBadge()->(String?){
        return UserDefaults.standard.value(forKey: "NotificationBadge") as? String
    }
    class func setNotificationBadge(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "NotificationBadge")
    }
    class func getSilentFrom()->(String?){
        return UserDefaults.standard.value(forKey: "SilentFrom") as? String
    }
    class func setSilentFrom(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "SilentFrom")
    }
    class func getSilentTo()->(String?){
        return UserDefaults.standard.value(forKey: "SilentTo") as? String
    }
    class func setSilentTo(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "SilentTo")
    }
    class func getNotification()->(String?){
        return UserDefaults.standard.value(forKey: "Notification") as? String
    }
    class func setNotification(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "Notification")
    }
    
    
    class func getBeaconServices()->(String?){
        return UserDefaults.standard.value(forKey: "BeaconServices") as? String
    }
    class func setBeaconServices(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "BeaconServices")
    }
    class func setDevice(_ deviceID: String)->(){
        UserDefaults.standard.set(deviceID, forKey: "DEVICEID")
    }
    class func getDevice()->(String?){
        return UserDefaults.standard.value(forKey: "DEVICEID") as? String
    }
    
    class func setDeviceudid(_ deviceID: String)->(){
        UserDefaults.standard.set(deviceID, forKey: "DEVICEUDID")
    }
    class func getDeviceudid()->(String?){
        return UserDefaults.standard.value(forKey: "DEVICEUDID") as? String
    }
    
    
    class func getBlueToothState()->(Int){
        let state = UserDefaults.standard.value(forKey: "USERDEFAULTBLUETOOTH") as? Int
        if(state == nil)
        {
            return 0
        }
        return state!
    }
    class func setBlueToothState(_ state:Int)->(){
        UserDefaults.standard.set(state, forKey: "USERDEFAULTBLUETOOTH")
    }
    
    class func getflagSession()->(Bool){
        let flag =    UserDefaults.standard.bool(forKey: "flagSession")
        return flag
    }
    class func setflagSession(_ flag: Bool)->(){
        UserDefaults.standard.set(flag, forKey: "flagSession")
    }
   
   

    class func getAppVersion()->(String){
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        var buildType = "P"
        if(Kbase_url.contains("ossclients"))
        {
            buildType = "Q"
        }
        
        return ("V" + version + buildType)
    }
    class func showAlertSheet(_ title:String,message: String,viewController:UIViewController)
    {
        let alertController = UIAlertController()
        alertController.message = message
        alertController.title = NSLocalizedString(ApplicationName.appName.rawValue, tableName: "UAPushUI", comment: "System Push Settings Label")
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = viewController.view
        viewController.present(alertController, animated:true, completion:nil)
    }

class func showNotification(_ title: String ,message:String){

         }
    class func setCountryCode(_ countryCode: String){
        UserDefaults.standard.set(countryCode, forKey: "countryCode")
    }
    class func getCountryCode()->(String!){
        let pt = UserDefaults.standard.value(forKey: "countryCode") as? String
        if(pt != nil)
        {
            return pt
        }
        else{
            return ""
        }

       // return UserDefaults.standard.value(forKey: "countryCode") as! String
    }

    class func setCountryDialCode(_ countryCode: String){
        
        UserDefaults.standard.set(countryCode, forKey: "COUNTRYDIALCODE")
    }
    class func getCountryDialCode()->(String!){
        let pt = UserDefaults.standard.value(forKey: "COUNTRYDIALCODE") as? String
        if(pt != nil)
        {
            return pt
        }
        else{
            return ""
        }

        
    }
    class func setPermToken(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "USERID")
    }
    

 class func getPermToken()->(String?){
    let pt = UserDefaults.standard.value(forKey: "USERID") as? String
    if(pt != nil)
    {
        return pt
    }
    else{
        return ""
    }
}
class func setUserToken(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "USERToken")
}
    
class func getUserToken()->(String?){
        return UserDefaults.standard.value(forKey: "USERToken") as? String
}
    class func setUserProfile(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "USERProfile")
    }
    
    class func getUserProfile()->(String?){
        let pt = UserDefaults.standard.value(forKey: "USERProfile") as? String
        if(pt != nil)
        {
            return pt
        }
        else{
            return ""
        }
       // return UserDefaults.standard.value(forKey: "USERProfile") as? String
    }
    class func setUserFirstName(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "FUSERNAME_")
    }
    
    class func getUserFirstName()->(String?){
        return UserDefaults.standard.value(forKey: "FUSERNAME_") as? String
    }

    class func setUserLastName(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "LUSERNAME_")
    }
    
    class func getUserLastName()->(String?){
        return UserDefaults.standard.value(forKey: "LUSERNAME_") as? String
    }
    
    class func setUserProfileURL(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "PROFILEURL")
    }
    
    class func getUserProfileURL()->(String?){
        let pt = UserDefaults.standard.value(forKey: "PROFILEURL") as? String
        if(pt != nil)
        {
            return pt
        }
        else{
            return ""
        }
        return UserDefaults.standard.value(forKey: "PROFILEURL") as? String
    }
   
    class func setUserEmail(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "UserEmail")
    }
    
    class func getUserEmail()->(String?){
        return UserDefaults.standard.value(forKey: "UserEmail") as? String
    }
    
    class func setUserRole(_ UserID: String)->(){
        UserDefaults.standard.set(UserID, forKey: "UserRole")
    }
    
    class func getUserRole()->(String?){
        return UserDefaults.standard.value(forKey: "UserRole") as? String
    }

    class func setAPIStage(_ baseUrl: String)->(){
        UserDefaults.standard.set(baseUrl, forKey: "APIStage")
    }
    
    class func getAPIStage()->(String?){
        return UserDefaults.standard.value(forKey: "APIStage") as? String
    }
    
    class func setBaseUrl(_ baseUrl: String)->(){
        UserDefaults.standard.set(baseUrl, forKey: "BaseUrl")
    }
    
    class func getBaseUrl()->(String?){
        return UserDefaults.standard.value(forKey: "BaseUrl") as? String
    }
  
    class func getselectedLocation()->(AnyObject){
        let val = UserDefaults.standard.value(forKey: "selectedLocation")
        if(val == nil)
        {
            return [:] as (AnyObject)
        }
        else{
            return val! as (AnyObject)
        }
    }
    class func setselectedLocation(_ location: [String:AnyObject])->(){
        UserDefaults.standard.set(location, forKey: "selectedLocation")
    }
    class func getselectedFloor()->(AnyObject?){
        let val = UserDefaults.standard.value(forKey: "selectedFloor")
        if(val == nil)
        {
            return [:] as (AnyObject)
        }
        else{
            return val as (AnyObject)
        }
    }
    class func setselectedFloor(_ location: [String:AnyObject])->(){
        UserDefaults.standard.set(location, forKey: "selectedFloor")
    }
 
    
class func isPhoneNumber(_ phone: String)->(Bool){
    let charcter  = CharacterSet(charactersIn: "+0123456789").inverted
    var filtered:String!
    let inputString:[String] = phone.components(separatedBy: charcter)
    filtered = inputString.joined(separator: "")
    return  phone == filtered
    
}
    
    
class func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String, view:AnyObject)
    {
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: view, cancelButtonTitle: alertCancelTitle)
        alert.show()
    }
    class func postNotification(_ Title:String, body:String){
        var localNotif : UILocalNotification?
        localNotif = UILocalNotification()
        localNotif!.alertBody = Title
        if #available(iOS 8.2, *) {
            localNotif!.alertTitle = body
        } else {
            // Fallback on earlier versions
        }
        localNotif?.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.presentLocalNotificationNow(localNotif!)
    }

   
}

func colorWithHexString (_ hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substring(from: 1)
    }
    
    if (cString.characters.count != 6) {
        return UIColor.gray
    }
    
    let rString = (cString as NSString).substring(to: 2)
    let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
    let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
    
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)
    
    
    return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
}


struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE =  UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPAD =  UIDevice.current.userInterfaceIdiom == .pad
}
struct color {
    static let yellow = UIColor(colorLiteralRed: 254.0/255.0 , green:202.0/255.0 , blue: 48.0/255.0, alpha: 1.0)
   }

