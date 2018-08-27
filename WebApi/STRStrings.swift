import AWSCognitoIdentityProvider


let Kbase_url =  "https://api.akwa.ioasd"//"http://strykerapi.nicbitqc.ossclients.com" //"https://strykerapi.nicbitqc.com" //"http://strykerapi.nicbit.ossclients.com"  //
let Kbase_url_front = "https://traker.akwa.io"//https://stryker-traquer.akwa.io"


var mapUrl = "https://stryker-traquer.akwa.io/cases/locationmap?caseNo="
let typeofOS = "ios"

let KBaseUrl_Amazon = "https://slsapi.akwa.io"
let APIStage = "qc"

let cloudinaryPreset = "nlnltoua"
let cloudinaryCloud = "drvjylp2e"


let CognitoIdentityPoolID = "us-east-1:9c5e5bca-cfef-40c6-8f18-575692dcab41"
let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1_zI0af0OBy"
let CognitoIdentityUserPoolAppClientId = "17ne3lbcoigmtk4paiocu643m3"
let CognitoIdentityUserPoolAppClientSecret = "1rbrptpgmibuo4emq8jq1mcn5gq3tfngd94f98g7fn5hebn1k9u2"

let AWSCognitoUserPoolsSignInProviderKey = "UserPool"



let buildIdentifer = "Prod" //  "QC" //
enum TextMessage:String {
    case alert = ""
    case tryAgain = "Try again"
    case Ok = "OK"
    case enterValues = "Please enter values"
    case enterUserName = "Please enter username"
    case enterPassword = "Please enter password"
    case emailValid = "Please enter valid email"
    case phonenumber = "Please enter valid phone number."
    case entertoken = "Please enter code"
    case validtoken = "Please enter valid code"
    case newpassword = "Please enter new password"
    case confirmpassword = "Password and confirm password did not match"
    case emailsend = "Code has been sent to registered email."
    case noDataFound = "No Data Found"
    case used = "Used"
    case unused = "Unused"
    case notValidNumber = "Invalid Phone Number"
    case fillCity =  "Please fill City"
     case countryCode =  "Please fill Country Code"
    case fillCountry = "Please Select Country"
    case fillPhone = "Please enter valid phone number"
    case fillFirstName = "Please fill First Name"
    case fillLastName = "Please fill Last Name"
    case casenotAssigned = "This Case does not belong to you"
    case noshipment = "No Shipments Selected"
    case noNewShipment = "You do not have any scheduled shipments"
    case uaSimulatorMessage = "You will not be able to receive push notifications in the simulator."
     case LoginFailed = "Please login from Carrier credentials"
}


enum SettingSectionMessage : String {
    case DashboardDefaultView = "Dashboard Default View"
    case DashboardSortedBy = "Dashboard Sort By"
    case DashboardSortedOrder = "Dashboard Sorted Order"
    case Notification = "Notification"
    
}


enum TitleName : String {
    case LocationInventory = "Inventory"
    case LocationInventoryDetails = "Inventory Details"
    case ChooseLocation = "Change Location"
    case ItemLocator = "Item Locator"
    case Notifications = "Notifications"
    case CaseHistory = "Case Report"
    case Settings = "Settings"
    case Help = "FAQ"
    case About = "About"
    case Dashboard = "Dashboard"
    case ReportIssue = "Notes"
    case CaseHistoryDetail = "Due Back Details"
   
}
var sortDataPopUp = ["ETD","Case No","Hospital","Doctor","Surgery Type","Surgery Date"]
var sortDataFromApi = ["ETD","CaseNo","Hospital","Doctor","SurgeryType","SurgeryDate"]

enum DashboardTitle : String {
    case All = "All"
    case alert = "Alerts"
    case Favorites = "Favorites"
}

enum  CaseDetailStringValue : String{
    case list = "List"
    case map = "Map"
}
enum  favoriteValue : String{
    case list = "Favorite"
    case map = "Favorited"
}

enum  ApplicationName : String{
    case appName = "Stryker Courier"
}
enum RearSlider: String{
    case inventory = "Inventory"
    case My_deleveries = "My Deliveries"
    case notification =  "Notifications"
    case settings =  "Settings"
    case help = "FAQ"
    case about =  "About"
    case My_Issues = "My Issues"
    case completeCase = "Completed Cases"
    case logout = "Logout"
    case sendDiagnostic = "Send Diagnostic"
    case Map = "Map"
    case enableLoging = "Enable Logs"
    case disableLoging = "Disable Logs"
}


