import UIKit
import CoreData
import RealmSwift
import CoreLocation
import AirshipKit
import CoreBluetooth
import Fabric
import Crashlytics
import AKLog
import AKSync
import AKProximity
import AKTrack
import AWSCore
import AWSLex
import AWSIoT
import AWSCognitoIdentityProvider
import SwiftyJSON
import KontaktSDK

let realm = try! Realm()
let role = "courier"
let roleLog = "CR"

let CognitoIdentityId = "us-east-1:9c5e5bca-cfef-40c6-8f18-575692dcab41"
let CognitoRegion = AWSRegionType.USEast1
let BotName = "SalesRep"
let BotAlias = "salesrep"

let statusThingName="TemperatureStatus"

var controlThingName = ""


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,CLLocationManagerDelegate,CBPeripheralManagerDelegate,UARegistrationDelegate, AKLocationUpdaterDelegate{
    let simulatorWarningDisabledKey = "ua-simulator-warning-disabled"
    var window: UIWindow?
    var viewController: HomeViewController?
    var navController: UINavigationController?
    var rearViewController : RearViewController?
    var pushHandler:PushHandler?
    let nointernet = NoInternetConnection()
    var beaconHandler: BeaconHandler?
    var locationTracker: LocationTracker?
    var locationUpdateTimer: Timer?
    let log:AKApplicationState = AKApplicationState.sharedHandler
   // let logSync:AKSyncState = AKSyncState.sharedHandler
    let locationHandlerObj : AKLocationUpdateHandler = AKLocationUpdateHandler.sharedHandler
    var managerState: ((CBPeripheralManager)->())?
    var orientationLock = UIInterfaceOrientationMask.all
    var bluetoothPeripheralManager: CBPeripheralManager?
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = 0
   
    var onHeadingUpdate: ((_ heading: String) -> Void)?
    let PolicyName = "StrykerTrackitRep"
    let AwsRegion = AWSRegionType.USEast1 // e.g. AWSRegionType.USEast1
    
    var iotDataManager: AWSIoTDataManager!;
    var iotData: AWSIoTData!
    var connected = false;
    var iotManager: AWSIoTManager!;
    var iot: AWSIoT!
    var userPool: AWSCognitoIdentityUserPool?
    var  newUdid :String?
    var  latitude : String?
    var  longtitude : String?
    var dummyMajor : String! = "1"
    var dummyMinor : String! = "600"
    var dummyUuid : String! = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
    
    var rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>?
    var signInViewController: STRLoginViewController?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //  getIntervals()
            
        getCurrentDeviceId()
        postDeviceData(deviceToken: "")
        utility.setDevice("")//added to remove nil while optimizing log
        utility.setAPIStage(APIStage)
        utility.setBaseUrl(KBaseUrl_Amazon)


        log.setRole = roleLog
        return true
    }
    
    
    var generalApi : AKGeneralAPI!
    
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return self.orientationLock
//    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(window?.rootViewController) {
            if (rootViewController.responds(to: Selector("canRotate"))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        
      
        return .portrait;
    }
    
    fileprivate func topViewControllerWithRootViewController(_ rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController((rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController((rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        beaconHandler = BeaconHandler.sharedHandler
        self.pushHandler = PushHandler()
        application.statusBarStyle = UIStatusBarStyle.lightContent
      //  LocalNotification.registerForLocalNotification(on: UIApplication.shared)
       
        registerForPushNotifications(application)
        locationHandlerObj.delegate = self
        AKApplicationState.sharedHandler.setRole = roleLog
        locationHandlerObj.setBaseUrl(KBaseUrl_Amazon)
        // locationHandlerObj.setAPIStage(APIStage)
        locationHandlerObj.setRole(role)
        application.applicationIconBadgeNumber = 0
       
        utility.setCountryCode("")
        
        utility.setClientId(clientIdConst)
        utility.setProjectId(projectIdConst)
        beaconHandler = BeaconHandler.sharedHandler
        beaconHandler?.isEnabledKontaktSDK = true
        beaconHandler?.initiateRegion(beaconHandler!)
        Kontakt.setAPIKey(kontaktApiKey)
        initiateMQTT()
        initiateCognito()
        //loggingSwift()
        nointernet.checkReachablity()
        GMSServices.provideAPIKey(googleApiKey)
        
        SetUpFabric()
        NavigationSetup()
        registerUrbanAirShipPushNotification()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        viewController = HomeViewController.init(nibName:"HomeViewController", bundle: nil)
        navController = UINavigationController.init(rootViewController: viewController!)
        rearViewController = RearViewController(nibName : "RearViewController" , bundle : nil);
        let nav=UINavigationController.init(rootViewController: rearViewController!);
        let reveler=SWRevealViewController.init(rearViewController: nav, frontViewController: navController)
        window?.rootViewController=reveler
        window?.makeKeyAndVisible()
        
        generalApi = AKGeneralAPI()
        generalApi!.role = role
        
        /*new code for location tracking*/
        let locValue:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0);
        beaconHandler = BeaconHandler.sharedHandler
        beaconHandler?.isEnabledKontaktSDK = true
        self.beaconHandler?.dummy(locValue)
        beaconHandler?.initiateRegion(beaconHandler!)
        
        
        beaconHandler?.initiateResponseBlocks({
            //stop
            AKApplicationState.sharedHandler.setRecordTime("\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))")
            AKApplicationState.sharedHandler.logEvent()
            // AKApplicationState.sharedHandler.setRecordTime("")
            AKApplicationState.sharedHandler.setDeivceid(utility.getDevice()!)
            
        }, authenticationChanged: {
            //auth change
            AKLocationUpdateHandler.sharedHandler.AKScannerstate()
        }, updateBeaconInformation: { (beacon, PKSyncObj, coordinate) in
            //realm update
            DispatchQueue(label: "background_update", attributes: []).async(execute: {
                self.updateSyncBeaconData(beacon,primaryKey: PKSyncObj,coordinate: coordinate)
            })
        })
        
        self.locationTracker = LocationTracker()
        getGeoFence()
        self.locationTracker?.startLocationTracking(speedAndAltitude: { (speed, altitude) in
            AKApplicationState.sharedHandler.setSpeed(speed)
            AKApplicationState.sharedHandler.setAltitude(altitude)
            
            }, location: { (location, accuracy) in
                AKApplicationState.sharedHandler.setAccuracy(accuracy)
                BeaconHandler.sharedHandler.stopBeconOperation()
                BeaconHandler.sharedHandler.dummy(location)
                // print(accuracy)
                
            }, andHeading: { (heading) in
                AKApplicationState.sharedHandler.setDirection(heading)
                // print(heading)
                self.onHeadingUpdate?(heading)
                
        })

        
        //Send the best location to server every 60 seconds
        // May adjust the time interval depends on the need of your app.
        let time:TimeInterval = 60.0;
        
        locationUpdateTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector:#selector(AppDelegate.updateLocation), userInfo: nil, repeats: true)

        
        
        let options = [CBCentralManagerOptionShowPowerAlertKey:0] //<-this is the magic bit!
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: options)

        inititateLex()
        
        return true
    }
    
    func initiateCognito() {
        
        if (CognitoIdentityUserPoolId == "YOUR_USER_POOL_ID") {
            let alertController = UIAlertController(title: "Invalid Configuration",
                                                    message: "Please configure user pool constants in Constants.swift file.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.window?.rootViewController!.present(alertController, animated: true, completion:  nil)
        }
        
        // setup logging
        AWSLogger.default().logLevel = .verbose
        
        // setup service configuration
        let serviceConfiguration = AWSServiceConfiguration(region: CognitoIdentityUserPoolRegion, credentialsProvider: nil)
        
        // create pool configuration
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: CognitoIdentityUserPoolAppClientId,
                                                                        clientSecret: CognitoIdentityUserPoolAppClientSecret,
                                                                        poolId: CognitoIdentityUserPoolId)
        
        // initialize user pool client
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        // fetch the user pool client we initialized in above step
        self.userPool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        self.userPool?.delegate = self
        
        
        
        
    }
    
    
    func inititateLex() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: CognitoRegion, identityPoolId: CognitoIdentityId)
        // Lex currently only in us-east-1
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let chatConfig = AWSLexInteractionKitConfig.defaultInteractionKitConfig(withBotName: BotName, botAlias: BotAlias)
        AWSLexInteractionKit.register(with: configuration!, interactionKitConfiguration: chatConfig, forKey: "AWSLexVoiceButton")
        chatConfig.autoPlayback = false
        AWSLexInteractionKit.register(with: configuration!, interactionKitConfiguration: chatConfig, forKey: "chatConfig")
    }
    // Initiate MQTT
    func initiateMQTT()
    {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AwsRegion, identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: AwsRegion, credentialsProvider: credentialsProvider)
        
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        iotManager = AWSIoTManager.default()
        iot = AWSIoT.default()
        
        iotDataManager = AWSIoTDataManager.default()
        iotData = AWSIoTData.default()
        
        connectButtonPressed()
        
    }
    
    
    func connectButtonPressed() {
        
        
        //        2017-05-17 17:00:12.627391 Stryker[1137:617221] [Client] Discarding message for event 0 because of too many unprocessed messages
        
        
        func mqttEventCallback( _ status: AWSIoTMQTTStatus )
        {
            DispatchQueue.main.async {
                print("connection status = \(status.rawValue)")
                switch(status)
                {
                case .connecting:
                    
                    print("Connecting...")
                    
                case .connected:
                    
                    
                    
                    self.connected = true
                    
                    let uuid = UUID().uuidString;
                    let defaults = UserDefaults.standard
                    let certificateId = defaults.string( forKey: "certificateId")
                    
                    
                    print("Using certificate:\n\(certificateId!)\n\n\nClient ID:\n\(uuid)")
                    
                    
                    controlThingName = "ios_\(String(describing: certificateId!))"
                    
                    print(controlThingName)
                    
                    let options  =  AWSIoTAttributePayload()
                    options?.attributes =  ["clientName" : "nitin",
                                            "branchName" : "iphone",
                                            "appName": "gateway",
                    ]
                    let createThingRequest  = AWSIoTCreateThingRequest()
                    createThingRequest?.thingName = controlThingName
                    
                    createThingRequest?.attributePayload = options
                    
                    
                    self.iot.createThing(createThingRequest!).continueWith (block: { (task) -> AnyObject? in
                        if let error = task.error {
                            print("failed: [\(error)]")
                        }
                        print("result: [\(task.result)]")
                        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                            
                            
                            
                            
                            //                            self.iotDataManager.register(withShadow: controlThingName, options:nil, eventCallback: self.sharedDevice.deviceShadowCallback )
                            //                            self.publishDeviceData()
                            //                            let time:TimeInterval = 10.0;
                            //                            _ = Timer.scheduledTimer(timeInterval: time, target: self, selector:#selector(self.publishDeviceData), userInfo: nil, repeats: true)
                            
                        })
                        
                        
                        
                        return nil
                        
                    })
                    
                    
                case .disconnected:
                    
                    print("Disconnected...")
                    
                    
                case .connectionRefused:
                    
                    print("Connection Refused")
                    
                case .connectionError:
                    
                    print("Connection Error")
                    
                case .protocolError:
                    
                    print("protocol Error")
                    
                default:
                    print("Unknown State")
                    
                }
                NotificationCenter.default.post( name: Notification.Name(rawValue: "connectionStatusChanged"), object: self )
            }
            
        }
        
        if (connected == false)
        {
            
            
            let defaults = UserDefaults.standard
            var certificateId = defaults.string( forKey: "certificateId")
            
            if (certificateId == nil)
            {
                DispatchQueue.main.async {
                    print("No identity available, searching bundle...")
                    
                }
                //
                // No certificate ID has been stored in the user defaults; check to see if any .p12 files
                // exist in the bundle.
                //
                let myBundle = Bundle.main
                let myImages = myBundle.paths(forResourcesOfType: "p12" as String, inDirectory:nil)
                let uuid = UUID().uuidString;
                
                if (myImages.count > 0) {
                    //
                    // At least one PKCS12 file exists in the bundle.  Attempt to load the first one
                    // into the keychain (the others are ignored), and set the certificate ID in the
                    // user defaults as the filename.  If the PKCS12 file requires a passphrase,
                    // you'll need to provide that here; this code is written to expect that the
                    // PKCS12 file will not have a passphrase.
                    //
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: myImages[0])) {
                        DispatchQueue.main.async {
                            //   self.logTextView.text = "found identity \(myImages[0]), importing..."
                        }
                        if AWSIoTManager.importIdentity( fromPKCS12Data: data, passPhrase:"", certificateId:myImages[0]) {
                            //
                            // Set the certificate ID and ARN values to indicate that we have imported
                            // our identity from the PKCS12 file in the bundle.
                            //
                            defaults.set(myImages[0], forKey:"certificateId")
                            defaults.set("from-bundle", forKey:"certificateArn")
                            DispatchQueue.main.async {
                                //     self.logTextView.text = "Using certificate: \(myImages[0]))"
                                self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:myImages[0], statusCallback: mqttEventCallback)
                            }
                        }
                    }
                }
                certificateId = defaults.string( forKey: "certificateId")
                if (certificateId == nil) {
                    DispatchQueue.main.async {
                        //    self.logTextView.text = "No identity found in bundle, creating one..."
                    }
                    //
                    // Now create and store the certificate ID in NSUserDefaults
                    //
                    let csrDictionary = [ "commonName":CertificateSigningRequestCommonName, "countryName":CertificateSigningRequestCountryName, "organizationName":CertificateSigningRequestOrganizationName, "organizationalUnitName":CertificateSigningRequestOrganizationalUnitName ]
                    
                    
                    
                    
                    
                    self.iotManager.createKeysAndCertificate(fromCsr: csrDictionary, callback: {  (response ) -> Void in
                        if (response != nil)
                        {
                            defaults.set(response?.certificateId, forKey:"certificateId")
                            defaults.set(response?.certificateArn, forKey:"certificateArn")
                            certificateId = response?.certificateId
                            print("response: [\(response)]")
                            
                            let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest()
                            attachPrincipalPolicyRequest?.policyName = self.PolicyName
                            attachPrincipalPolicyRequest?.principal = response?.certificateArn
                            //
                            // Attach the policy to the certificate
                            //
                            self.iot.attachPrincipalPolicy(attachPrincipalPolicyRequest!).continueWith (block: { (task) -> AnyObject? in
                                if let error = task.error {
                                    print("failed: [\(error)]")
                                }
                                print("result: [\(task.result)]")
                                //
                                // Connect to the AWS IoT platform
                                //
                                if (task.error == nil)
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                                        //        self.logTextView.text = "Using certificate: \(certificateId!)"
                                        self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
                                        
                                    })
                                }
                                return nil
                            })
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                
                                
                            }
                        }
                    } )
                }
            }
            else
            {
                let uuid = UUID().uuidString;
                
                //
                // Connect to the AWS IoT service
                //
                iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: mqttEventCallback)
            }
        }
        else
        {
            
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                self.iotDataManager.disconnect();
                DispatchQueue.main.async {
                    
                    self.connected = false
                    
                    
                    
                }
            }
        }
        
    }
    
    
    
    func updateLocation() {
        if (utility.getBlueToothState() == 0) {
            dummySyncBeaconData( beaconHandler?.PKSyncObj, coordinate:  beaconHandler?.coordinate)
        }
        locationHandlerObj.AKSyncXtimeNew()
    }
    func SetUpFabric()
    {
         Fabric.with([Crashlytics.self])
    }
    
    
    func NavigationSetup() {
        UINavigationBar.appearance().barTintColor = UIColor.darkGray
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
     
    }
    
    func getCurrentDeviceId() {
        let device = UIDevice.current;
        let currentDeviceId = device.identifierForVendor!.uuidString;
        utility.setDevice(currentDeviceId)
    }
    
    
    func registerUrbanAirShipPushNotification()
    {
        if(UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types:[.alert , .badge ,.sound], categories: nil))
        }
        let config = UAConfig.default()
        config.messageCenterStyleConfig = "UAMessageCenterDefaultStyle"
        UAirship.takeOff(config)
        print("Config:\n \(config)")
        UAirship.push()?.resetBadge()
        UAirship.push().pushNotificationDelegate = pushHandler
        UAirship.push().registrationDelegate = self
        UAirship.push().userPushNotificationsEnabled = true
        

    }

    func registrationSucceeded(forChannelID channelID: String, deviceToken: String) {
        NotificationCenter.default.post(
            name: Notification.Name(rawValue: "channelIDUpdated"),
            object: self,
            userInfo:nil)
        let channelID = UAirship.push().channelID!
        print("My Application Channel ID: \(channelID)")
       
        utility.setChannelId(channelID)
        postDeviceData(deviceToken: deviceToken)
    }
    
    func failIfSimulator() {
        // If it's not a simulator return early
        if (TARGET_OS_SIMULATOR == 0 && TARGET_IPHONE_SIMULATOR == 0) {
            return
        }
        
        if (UserDefaults.standard.bool(forKey: self.simulatorWarningDisabledKey)) {
            return
        }
        
        let alertController = UIAlertController(title: "Notice", message: TextMessage.uaSimulatorMessage.rawValue, preferredStyle: .alert)
        let disableAction = UIAlertAction(title: "Disable Warning", style: UIAlertActionStyle.default){ (UIAlertAction) -> Void in
            UserDefaults.standard.set(true, forKey:self.simulatorWarningDisabledKey)
        }
        alertController.addAction(disableAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Let the UI finish launching first so it doesn't complain about the lack of a root view controller
        // Delay execution of the block for 1/2 second.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    func registerForPushNotifications(_ application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        
        application.registerUserNotificationSettings(notificationSettings)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    func initSideBarMenu(){
        if (rearViewController == nil) {
            rearViewController = RearViewController.init(nibName: "RearViewController", bundle: nil)
        }
        
        let centerViewController = HomeViewController.init(nibName: "HomeViewController", bundle: nil)
        let leftSideNav = UINavigationController(rootViewController: rearViewController!)
        let centerNav = UINavigationController(rootViewController: centerViewController)
        
        let sideMenu = SWRevealViewController.init(rearViewController: leftSideNav, frontViewController: centerNav)
        
        window?.rootViewController = sideMenu
    }
    func initSideBarMenuFromLogin(){
        rearViewController = RearViewController.init(nibName: "RearViewController", bundle: nil)
        
        let centerViewController = HomeViewController.init(nibName: "HomeViewController", bundle: nil)
        let leftSideNav = UINavigationController(rootViewController: rearViewController!)
        let centerNav = UINavigationController(rootViewController: centerViewController)
        
        
        let sideMenu = SWRevealViewController.init(rearViewController: leftSideNav, frontViewController: centerNav)
        
        window?.rootViewController = sideMenu
        logUser()
    }
    
    func logUser() {
       
        Crashlytics.sharedInstance().setUserEmail(utility.getUserEmail())
        Crashlytics.sharedInstance().setUserIdentifier(utility.getUserFirstName())
        Crashlytics.sharedInstance().setUserName(utility.getUserFirstName())
    }

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        getUSerProfile()
        // self.getIntervals()
        locationHandlerObj.AKSyncXtimeNew()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.osscube.STRCourier" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "STRCourier", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject

            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let state = AKApplicationState.sharedHandler
        AKApplicationState.sharedHandler.setRole = roleLog
        
        if(self.managerState != nil)
        {
            self.managerState!(peripheral)
        }

        var statusMessage = ""
        
        if #available(iOS 10.0, *) {
            switch peripheral.state {
            case CBManagerState.poweredOn:
                statusMessage = "Bluetooth Status: Turned On"
                utility.setBlueToothState(1)
                AKApplicationState.sharedHandler.setRole = roleLog
                state.setBLEAvailable("1")
                break
            case CBManagerState.poweredOff,CBManagerState.resetting,CBManagerState.unauthorized,CBManagerState.unsupported:
                
                statusMessage = "Bluetooth Status: Turned Off"
                // createAlert("Bluetooth", alertMessage: "Turned Off.Turn On Bluetooth", alertCancelTitle: "OK")
                AKApplicationState.sharedHandler.setRole = roleLog
                state.setBLEAvailable("0")
                
                utility.setBlueToothState(0)
                break;
            default:
                statusMessage = "Bluetooth Status: Unknown"
                // createAlert("Bluetooth", alertMessage: "Unknown.Turn On Bluetooth", alertCancelTitle: "OK")
                state.setBLEAvailable("0")
                AKApplicationState.sharedHandler.setRole = roleLog
                
                utility.setBlueToothState(0)
            }
        } else {
            // Fallback on earlier versions
            
            switch peripheral.state.rawValue {
            case 5:
                statusMessage = "Bluetooth Status: Turned On"
                utility.setBlueToothState(1)
                AKApplicationState.sharedHandler.setRole = roleLog
                state.setBLEAvailable("1")
                
                
                break
            case 4,3,2,1:
                statusMessage = "Bluetooth Status: Turned Off"
                // createAlert("Bluetooth", alertMessage: "Turned Off.Turn On Bluetooth", alertCancelTitle: "OK")
                utility.setBlueToothState(0)
                AKApplicationState.sharedHandler.setRole = roleLog
                
                state.setBLEAvailable("0")
                
                
            default:
                statusMessage = "Bluetooth Status: Unknown"
                // createAlert("Bluetooth", alertMessage: "Unknown.Turn On Bluetooth", alertCancelTitle: "OK")
                utility.setBlueToothState(0)
                AKApplicationState.sharedHandler.setRole = roleLog
                state.setBLEAvailable("0")
                
            }
            

        }
        
        print(statusMessage)
        
        if #available(iOS 10.0, *) {
            if peripheral.state == CBManagerState.poweredOff {
                //TODO: Update this property in an App Manager class
            }
        } else {
            // Fallback on earlier versions
        }
        
        locationHandlerObj.AKScannerstate()
        
    }

    func createAlert(_ alertTitle: String, alertMessage: String, alertCancelTitle: String)
    {
        let alert = UIAlertView(title: alertTitle, message: alertMessage, delegate: self, cancelButtonTitle: alertCancelTitle)
        alert.show()
    }
    
    // Data Feeding
    func postDeviceData(deviceToken:String?) {
        
        let generalApiobj = GeneralAPI()
        let systemVersion = UIDevice.current.name
        print("iOS\(systemVersion)")
        
        let model = UIDevice.current.model
        print("device type=\(model)")
        
        let Version = UIDevice.current.systemVersion
        print("device type=\(Version)")
        
        let systemName = UIDevice.current.systemName
        print("systemName =\(systemName)")
        
        let identifierForVendor = UIDevice.current.identifierForVendor
        print("device type=\(identifierForVendor)")
        let uuid = identifierForVendor!.uuidString
        print(uuid)
        let str :String = "Apple" + " " + Version
        let locationStatus = NSInteger(AKApplicationState.sharedHandler.getGPSAvailable())
        var pushIdentifier = ""
        if deviceToken! != ""
        {
            pushIdentifier = deviceToken!
        }
        
        let clientDic : [String :String] = ["clientId" : "012179919676", "projectId" : "us-east-1_zI0af0OBy"]
        let paramDict:[String:Any] = ["deviceId":uuid, "name": systemVersion,"status" : 1,  "manufacturer":str, "model": model, "os":"ios", "version":Version,"appName" : "carrier", "appVersion" : utility.getAppVersion(),"channelId" : utility.getChannelId()!, "locationStatus": locationStatus!,"bluetoothStatus": utility.getBlueToothState(), "client" : clientDic,"pushIdentifier":pushIdentifier]//
        
        generalApiobj.hitApiwith(paramDict as Dictionary<String, AnyObject>, serviceType: .strDeviceInformation, success: { (response) in
            DispatchQueue.main.async {
                
                print(response)
                
                let dataDictionary = response["data"] as? [String : AnyObject]
                
                self.newUdid  =  dataDictionary?["code"] as? String
                self.dummyMajor = String(describing: dataDictionary?["major"] as! NSInteger)
                self.dummyMinor = String(describing: dataDictionary?["minor"] as! NSInteger)
                self.dummyUuid = (dataDictionary?["uuid"])?.uppercased as! String

                print(self.dummyUuid)
                utility.setDevice(self.newUdid!)
                AKApplicationState.sharedHandler.setDeivceid(utility.getDevice()!)

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CODE_UPDATE"), object: nil)
                
                
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                
                NSLog(" %@", err)
            }
        }
    }

    func AKSetLogData(_ datacount: String)
    {
        print(datacount)
        
        if datacount == "1"  || datacount ==  "4"{
            AKApplicationState.sharedHandler.setRole = roleLog
            AKApplicationState.sharedHandler.setApiHitTime("\(Int64(floor(Date().timeIntervalSince1970 * 1000.0)))")
            AKApplicationState.sharedHandler.logEvent()
            AKApplicationState.sharedHandler.clearSensorData()
            AKApplicationState.sharedHandler.setApiHitTime("")
        }else if datacount == "5"
        {
            AKApplicationState.sharedHandler.setRole = roleLog
            AKApplicationState.sharedHandler.logEvent()
        }
        
        
    }
    
    func AKSenserData(_ senserDate: AKSyncStateModel) {
//      print(senserDate)
//        
//        let state = AKSensorStateModel()
//        state.major = senserDate.major
//        state.minor = senserDate.minor
//        state.proximity = senserDate.proximity
//        state.longitude = senserDate.longitude
//        state.lattitude = senserDate.lattitude
//        state.UDIDBeacon = senserDate.UDIDBeacon
//        
//        
//        AKApplicationState.sharedHandler.setRole = roleLog
//        AKApplicationState.sharedHandler.setSensorData(state)
      //  AKApplicationState.sharedHandler.logEvent()
    }
    
    func AKGPSState(_ gpsState: String) {
        print(gpsState)
        AKApplicationState.sharedHandler.setRecordTime("\(Int64(floor(Date().timeIntervalSince1970 * 1000.0)))")
        AKApplicationState.sharedHandler.setGPSAvailable(gpsState)
        //  AKApplicationState.sharedHandler.logEvent()
    }
    
    func AKSendJsonToMQTT(_ jsonMQTT: Dictionary<String, AnyObject>) {
        
        
        
        let jsonMQTTObj  = jsonMQTT["beacons"]
        
      //  LocalNotification.dispatchlocalNotification(with: "Carrier", body: "Data sent to mqtt", at: Date().addedBy(minutes: 2))
        
        // print(jsonMqtt)
        
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: jsonMQTTObj,
            options: .prettyPrinted) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            
            //  theJSONText = theJSONText?.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range:nil)
            let minifyJson = theJSONText?.JSONminify
            
            print("JSON string = \(minifyJson!)")
            
         let result =  iotDataManager.publishString("\(minifyJson!)", onTopic:"ak-trackPoints", qoS:.messageDeliveryAttemptedAtLeastOnce)
            
           print(result)
            AKApplicationState.sharedHandler.setACK(result.description ?? "none")
            if (result) {
                let realm = try! Realm()
                let dataLIst = realm.objects(AKSyncObject.self).filter("synced = false")
                try! realm.write({
                    
                    // let beacon = realm.objects(AKSyncObject.self).filter("synced = false")
                    for obj  in dataLIst{
                        
                        
                        obj.synced = true
                        //                    for becn in obj.event{
                        //                        if !(becn.value(forKey: "minor") as! String == "605"){
                        //
                        //                        }else{
                        //                            print("605 Beacon")
                        //                        }
                        //                    }
                        
                    }
                    
                    
                })
            }
            
           
            
        }
        
        
    }
    
    
    
    func getIntervals(){
        
    }
    func getGeoFence()->(){
        let generalApiobj = GeneralAPI()
        let someDict:[String:String] = ["":""]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strApiGetGeofences, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                guard let data = response["data"] as? [Dictionary<String,AnyObject>]else{
                    return
                }
                self.setupData(data: data)
            }
        }) { (err) in
            DispatchQueue.main.async {
            }
        }
        
    }
    func setupData(data:[Dictionary<String,AnyObject>]){
        var arr = [GeoFence]()
        for dict in data{
            let coord = dict["coordinates"] as! [String:AnyObject]
            let obj = GeoFence.init(latitude:Double(coord["latitude"] as! NSNumber) , longitude: Double(coord["longitude"] as! NSNumber), identifier: dict["id"] as! String)
            arr.append(obj)
        }
        locationTracker?.setGeoFence(geofences: arr);
    }
    func getUSerProfile()->(){
        if(utility.getUserToken() == nil || utility.getUserToken() == " ")
        {
            return
        }

        let generalApiobj = GeneralAPI()
        let someDict:[String:String] = ["":""]
        generalApiobj.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strApiGetUSerProfile, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                guard let data = response["data"] as? [String:AnyObject],let readerGetProfileResponse = data["readerGetProfileResponse"] as? [String:AnyObject] else{
                    return
                }
                utility.setCountryDialCode((readerGetProfileResponse["countryDialCode"] as? String)!)
                utility.setCountryCode((readerGetProfileResponse["countryCode"] as? String)!)
                utility.setUserFirstName((readerGetProfileResponse["firstName"] as? String)!)
                utility.setUserLastName((readerGetProfileResponse["lastName"] as? String)!)
            }
        }) { (err) in
            DispatchQueue.main.async {
            }
        }
        
    }
    func updateSyncBeaconData(_ beacons: [CLBeacon],primaryKey:String!,coordinate:CLLocationCoordinate2D!){
        
        let realm = try! Realm()
        var syncObj: AKSyncObject?
        syncObj = realm.object(ofType: AKSyncObject.self, forPrimaryKey: primaryKey! as AnyObject)
        if(syncObj == nil)
        {
            AKApplicationState.sharedHandler.setRole = roleLog
            syncObj = AKSyncObject()
            try! realm.write {
                syncObj!.id = primaryKey!
                syncObj!.synced=false
                
                syncObj!.lat = String(format:"%.6f",coordinate!.latitude )// "\(coordinate!.latitude)"
                syncObj!.lng = String(format:"%.6f",coordinate!.longitude )// "\(coordinate!.longitude)"
                syncObj!.alt = AKApplicationState.sharedHandler.getAltitude()
                syncObj!.speed = AKApplicationState.sharedHandler.getSpeed()
                syncObj!.accuracy = AKApplicationState.sharedHandler.getAccuracy()
                syncObj!.direction =  AKApplicationState.sharedHandler.getDirection()
                syncObj!.pkid =  utility.getDevice()! + "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                var count = 0
                for becn in beacons {
                    let state = AKSensorStateModel()
                    state.major = "\(becn.major)"
                    state.minor = "\(becn.minor)"
                    state.proximity = "\(becn.proximity.rawValue)"
                    state.longitude = String(format:"%.6f",coordinate!.longitude )
                    state.lattitude = String(format:"%.6f",coordinate!.latitude )
                    state.UDIDBeacon = becn.proximityUUID.uuidString
                    AKApplicationState.sharedHandler.setRole = roleLog
                    AKApplicationState.sharedHandler.setSensorData(state)
                    
                    
                    let beaconInfo = AKBeaconInfo()
                    beaconInfo.cid = ""
                    beaconInfo.data = ""
                    beaconInfo.lat = String(format:"%.6f",coordinate!.latitude )
                    beaconInfo.long = String(format:"%.6f",coordinate!.longitude )
                    beaconInfo.timestamp = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                    beaconInfo.uuid =  becn.proximityUUID.uuidString
                    beaconInfo.major = "\(becn.major)"
                    beaconInfo.minor = "\(becn.minor)"
                    beaconInfo.distance = "\(becn.accuracy)"
                    beaconInfo.rssi = "\(becn.rssi)"
                    beaconInfo.synced = false
                    beaconInfo.proximity = "\(becn.proximity.rawValue)"
                    beaconInfo.id = "\(becn.major)\(becn.minor)\(syncObj!.id)"
                    
                    
//                    if (count == 0){
//                        count = count + 1
//                        beaconInfo.cid = ""
//                        beaconInfo.data = ""
//                        beaconInfo.lat = String(format:"%.6f",coordinate!.latitude )
//                        beaconInfo.long = String(format:"%.6f",coordinate!.longitude )
//                        beaconInfo.timestamp = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
//                        beaconInfo.uuid =  self.dummyUuid
//                        beaconInfo.major =  self.dummyMajor
//                        beaconInfo.minor = self.dummyMinor
//                        beaconInfo.distance = "0.0"
//                        beaconInfo.rssi = "11"
//                        beaconInfo.synced = false
//                        beaconInfo.proximity = "0.0"
//                        beaconInfo.id = "\("1")\(self.dummyMinor)\(syncObj!.id)"
//                    }
                    
                  //  AKApplicationState.sharedHandler.logEvent()
                    let sampleBeacon = realm.create(AKBeaconInfo.self, value: beaconInfo, update: true)
                    syncObj!.event.append(sampleBeacon)
                    realm.add(syncObj!, update: true)
                }
            }
           AKApplicationState.sharedHandler.logEvent()
        }
        else{
            AKApplicationState.sharedHandler.setRole = roleLog
            try! realm.write {
                syncObj!.lat = String(format:"%.6f",coordinate!.latitude )//"\(coordinate!.latitude)"
                syncObj!.lng = String(format:"%.6f",coordinate!.longitude )// "\(coordinate!.longitude)"
                syncObj!.alt = AKApplicationState.sharedHandler.getAltitude()
                syncObj!.speed = AKApplicationState.sharedHandler.getSpeed()
                syncObj!.accuracy = AKApplicationState.sharedHandler.getAccuracy()
                syncObj!.direction =  AKApplicationState.sharedHandler.getDirection()
                syncObj!.pkid =  utility.getDevice()! + "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                
                var count = 0
                for becn in beacons {
                    let state = AKSensorStateModel()
                    state.major = "\(becn.major)"
                    state.minor = "\(becn.minor)"
                    state.proximity = "\(becn.proximity.rawValue)"
                    state.longitude = String(format:"%.6f",coordinate!.longitude )
                    state.lattitude = String(format:"%.6f",coordinate!.latitude )
                    state.UDIDBeacon = becn.proximityUUID.uuidString
                    AKApplicationState.sharedHandler.setSensorData(state)
                    
                    let beaconInfo = AKBeaconInfo()
                    beaconInfo.cid = ""
                    beaconInfo.data = ""
                    beaconInfo.lat = String(format:"%.6f",coordinate!.latitude )// "\(coordinate!.latitude)"
                    beaconInfo.long = String(format:"%.6f",coordinate!.longitude )// "\(coordinate!.longitude)"
                    beaconInfo.timestamp = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                    beaconInfo.uuid =  becn.proximityUUID.uuidString
                    beaconInfo.major = "\(becn.major)"
                    beaconInfo.minor = "\(becn.minor)"
                    beaconInfo.synced = false
                    beaconInfo.distance = "\(becn.accuracy)"
                    beaconInfo.rssi = "\(becn.rssi)"
                    beaconInfo.proximity = "\(becn.proximity.rawValue)"
                    beaconInfo.id = "\(becn.major)\(becn.minor)\(syncObj!.id)"
                    
//                    if (count == 0){
//                        count = count + 1
//                        beaconInfo.cid = ""
//                        beaconInfo.data = ""
//                        beaconInfo.lat = String(format:"%.6f",coordinate!.latitude )
//                        beaconInfo.long = String(format:"%.6f",coordinate!.longitude )
//                        beaconInfo.timestamp = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
//                        beaconInfo.uuid =  self.dummyUuid
//                        beaconInfo.major =  self.dummyMajor
//                        beaconInfo.minor = self.dummyMinor
//                        beaconInfo.distance = "0.0"
//                        beaconInfo.rssi = "11"
//                        beaconInfo.synced = false
//                        beaconInfo.proximity = "0.0"
//                        beaconInfo.id = "\("1")\(self.dummyMinor)\(syncObj!.id)"
//                    }
                    
                    
                    if let sampleBeacon = syncObj!.event.filter("id = '\(becn.major)\(becn.minor)\(syncObj!.id)'").first{//realm.create(OSSBeaconInfo.self, value: beaconInfo, update: true)
                        sampleBeacon.lat = String(format:"%.6f",coordinate!.latitude )//"\(coordinate!.latitude)"
                        sampleBeacon.long = String(format:"%.6f",coordinate!.longitude )//"\(coordinate!.longitude)"
                        sampleBeacon.timestamp = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                        //syncObj!.event.append(sampleBeacon)
                    }
                    else{
                        let sampleBeacon=realm.create(AKBeaconInfo.self, value: beaconInfo, update: true)
                        syncObj!.event.append(sampleBeacon)
                    }
                  //  AKApplicationState.sharedHandler.logEvent()
                    realm.add(syncObj!, update: true)
                }
            }
            
            AKApplicationState.sharedHandler.logEvent()
        }
        
        
    }

    func dummySyncBeaconData(_ primaryKey:String!,coordinate:CLLocationCoordinate2D!){
        
        let realm = try! Realm()
        var syncObj: AKSyncObject?
        syncObj = realm.object(ofType: AKSyncObject.self, forPrimaryKey: primaryKey! as AnyObject)
        if(syncObj == nil)
        {
            AKApplicationState.sharedHandler.setRole = roleLog
            syncObj = AKSyncObject()
            try! realm.write {
                syncObj!.id = primaryKey!
                syncObj!.synced=false
                syncObj!.lat = String(format:"%.6f",coordinate!.latitude )// "\(coordinate!.latitude)"
                syncObj!.lng = String(format:"%.6f",coordinate!.longitude )// "\(coordinate!.longitude)"
                syncObj!.alt = AKApplicationState.sharedHandler.getAltitude()
                syncObj!.speed = AKApplicationState.sharedHandler.getSpeed()
                syncObj!.accuracy = AKApplicationState.sharedHandler.getAccuracy()
                syncObj!.direction =  AKApplicationState.sharedHandler.getDirection()
                syncObj!.pkid =  utility.getDevice()! + "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                
                let state = AKSensorStateModel()
                
                
                
                state.major = "1"
                state.minor = "605"
                state.proximity = "\(0.0)"
                state.longitude = String(format:"%.6f",coordinate!.longitude )
                state.lattitude = String(format:"%.6f",coordinate!.latitude )
                state.UDIDBeacon = self.dummyUuid
                AKApplicationState.sharedHandler.setRole = roleLog
                AKApplicationState.sharedHandler.setSensorData(state)
                
                
                let beaconInfo = AKBeaconInfo()
                beaconInfo.cid = ""
                beaconInfo.data = ""
                beaconInfo.lat = String(format:"%.6f",coordinate!.latitude )
                beaconInfo.long = String(format:"%.6f",coordinate!.longitude )
                beaconInfo.timestamp = "\(Int64(floor(NSDate().timeIntervalSince1970 * 1000.0)))"
                beaconInfo.uuid =  self.dummyUuid
                beaconInfo.major =  self.dummyMajor
                beaconInfo.minor = self.dummyMinor
                beaconInfo.distance = "0.0"
                beaconInfo.rssi = "11"
                beaconInfo.synced = false
                beaconInfo.proximity = "0.0"
                beaconInfo.id = "\("1")\(self.dummyMinor)\(syncObj!.id)"
                let sampleBeacon = realm.create(AKBeaconInfo.self, value: beaconInfo, update: true)
                syncObj!.event.append(sampleBeacon)
                realm.add(syncObj!, update: true)
            }
            
        }
    }
    
}

extension String
{
    
    public var JSONminify: String {
        
        let minifyRegex = "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+"
        
        if let regexMinify = try? NSRegularExpression(pattern: minifyRegex, options: .caseInsensitive) {
            
            let modString = regexMinify.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.characters.count), withTemplate: "$1")
            
            return modString
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\t", with: "")
                .replacingOccurrences(of: "\r", with: "")
        } else {
            return self
        }
    }
}


// MARK:- AWSCognitoIdentityInteractiveAuthenticationDelegate protocol delegate

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        
        self.signInViewController = STRLoginViewController.init(nibName:"STRLoginViewController", bundle: nil)
        
        return self.signInViewController!
    }
    
    func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        let alertController = UIAlertController(title: "Remember Device",
                                                message: "Do you want to remember this device?.",
                                                preferredStyle: .actionSheet)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.rememberDeviceCompletionSource?.set(result: true)
        })
        let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
            self.rememberDeviceCompletionSource?.set(result: false)
        })
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        return alertController as! AWSCognitoIdentityMultiFactorAuthentication
        
        
    }
    
    func startRememberDevice() -> AWSCognitoIdentityRememberDevice {
        return self
    }
}



// MARK:- AWSCognitoIdentityRememberDevice protocol delegate

extension AppDelegate: AWSCognitoIdentityRememberDevice {
    
    func getRememberDevice(_ rememberDeviceCompletionSource: AWSTaskCompletionSource<NSNumber>) {
        self.rememberDeviceCompletionSource = rememberDeviceCompletionSource
        DispatchQueue.main.async {
            // dismiss the view controller being present before asking to remember device
            //self.window?.rootViewController!.presentedViewController?.dismiss(animated: true, completion: nil)
            let alertController = UIAlertController(title: "Remember Device",
                                                    message: "Do you want to remember this device?.",
                                                    preferredStyle: .actionSheet)
            
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: true)
            })
            let noAction = UIAlertAction(title: "No", style: .default, handler: { (action) in
                self.rememberDeviceCompletionSource?.set(result: false)
            })
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            //    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as? NSError {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                DispatchQueue.main.async {
                    //  self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension Date {
    func addedBy(minutes:Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}


