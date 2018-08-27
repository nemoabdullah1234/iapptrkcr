import UIKit
import CoreLocation
import AKProximity
import KontaktSDK
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

//enum STRFromScreen: Int{
//    case strFromSearchScreen = 0
//    case strFromItemDetail
//    case strFromSearchLocation
//    case strFromFirstLoad
//}

class STRInventorViewController_copy: UIViewController,UITabBarDelegate,UITableViewDataSource,CLLocationManagerDelegate,UIAlertViewDelegate, LocationSelectorDelegate {
    var appearInformation: STRFromScreen! = .strFromFirstLoad
    var locationManager : CLLocationManager!
    var currentID :NSInteger?
    @IBOutlet var btnScan: UIButton!
    @IBOutlet var lblMissing: UILabel!
    @IBOutlet var lblFound: UILabel!
    @IBOutlet var lblAll: UILabel!
    var tempdic : Dictionary<String,AnyObject>? = [:]
    var beacon : KTKBeaconRegion!
    var startTime: String?
    var endTime: String?
    var showFloors : Bool?
    var floorId : String?
    var beaconManager: KTKBeaconManager!
    
    var dictFloorJT:[String:Any]!
    var LocationName:String? 
    
    @IBAction func btnSearchLocation(_ sender: AnyObject) {
        appearInformation = .strFromSearchLocation
        utility.setflagSession(false)
        resetState()
        let vw  = STRChangeLocationViewController(nibName: "STRChangeLocationViewController", bundle: nil)
        let arrnr = self.tempdic?["near"] as? [Dictionary<String,AnyObject>]
        let arrOtr = self.tempdic?["other"] as? [Dictionary<String,AnyObject>]
        if(arrOtr == nil && arrnr == nil)
        {
            return
        }
        vw.arrNear = arrnr
        vw.arrayOther = arrOtr
       // vw.idCurrent = currentID
        let nav = UINavigationController(rootViewController: vw)
        self.present(nav, animated: true, completion: {
            
        })
    }
    @IBOutlet var vwScan: STRScanViewNew!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var tblInventory: UITableView!
    var location = [String:AnyObject]()
    var zone_obj = [[String:AnyObject]]()
    var flagScanDisabled: Bool = false
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewScanCall()
        //self.title = TitleName.LocationInventory.rawValue
        
        let appType:applicationType = applicationEnvironment.ApplicationCurrentType
        
        
        switch appType {
        case .salesRep:
            customizeNavigationforAll(self)
            print("It's for Sales Rep")
        case .warehouseOwner:
            customNavigationforBack(self)
                        print("It's for wareHouse Owner")
        }
        
        
        setFont()
        let nib = UINib(nibName: "STRInventoryTableViewCell", bundle: nil)
        self.tblInventory.register(nib, forCellReuseIdentifier: "STRInventoryTableViewCell")
        tblInventory.rowHeight = UITableViewAutomaticDimension
        tblInventory.estimatedRowHeight = 70
        appearInformation = .strFromFirstLoad
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(STRInventorViewController_copy.refresh(_:)), for: UIControlEvents.valueChanged)
        tblInventory.addSubview(refreshControl)
        self.lblAddress.text = self.dictFloorJT["name"] as? String
        // Do any additional setup after loading the view.
    }
    func poptoPreviousScreen(){
        utility.setselectedFloor([:])
        self.navigationController?.popViewController(animated: true)
    }
    func viewScanCall(){
        self.vwScan.scanBlock = {(tag) in
            
            if(tag == 1)
            {
                self.endTime = "\(Int64(floor(Date().timeIntervalSince1970 * 1000.0)))"
                self.beaconManager.stopRangingBeacons(in: self.beacon)
                self.markeRemainingUndetected()
                self.makeUpdateData()
                DispatchQueue(label: "background_update", attributes: []).async(execute: {
                    self.setCount()
                })
            }
            else{
                utility.showAlertSheet("", message: "Scan for minimum five minutes", viewController: self)
                self.startTime = "\(Int64(floor(Date().timeIntervalSince1970 * 1000.0)))"
                self.locationManager = CLLocationManager()
                self.beaconManager = KTKBeaconManager(delegate: self)
                let uuid:UUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
                self.beacon = KTKBeaconRegion(proximityUUID: uuid, identifier:"")
                self.locationManager.requestAlwaysAuthorization()
                self.beaconManager.requestLocationAlwaysAuthorization()
                self.beacon.notifyOnEntry=true
                self.beacon.notifyOnExit=true
                self.beacon.notifyEntryStateOnDisplay=true
                
                CLLocationManager.locationServicesEnabled()
                self.beaconManager.startMonitoring(for: self.beacon)
                self.beaconManager.startRangingBeacons(in: self.beacon)
               
            }
        }
    }
    
    func refresh(_ sender:AnyObject) {
        // Code to refresh table view
        self.vwScan.btnScan!.tag = 0
        self.vwScan.stopAnimation()
        //let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
        //let locid = loc?["locationId"] as! String
        // getFloorData(locationId: locid)
        self.expandCollapse(0, dict: self.dictFloorJT! as Dictionary<String, AnyObject>)
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func toggleSideMenu(_ sender: AnyObject) {
        
        self.revealViewController().revealToggle(animated: true)
        
    }
    
    func sortButtonClicked(_ sender : AnyObject){
        appearInformation = .strFromSearchScreen
//        resetState()
//        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
//        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        let appType:applicationType = applicationEnvironment.ApplicationCurrentType
        
        
        switch appType {
        case .salesRep:
           
            print("It's for Sales Rep")
        case .warehouseOwner:
            
            
            print("It's for wareHouse Owner")
        }
        
//        if(utility.getUserToken() == nil || utility.getUserToken() == " ")
//        {
//            self.presentLogin()
//            utility.setflagSession(true)
//            return
//            
//        }else{
            switch self.appearInformation! {
            case .strFromSearchScreen:
                //    dataFeeding(locationId: "")
                break
                
            case .strFromItemDetail:
                
                break
            case .strFromSearchLocation:
                let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
                let locid = loc?["locationId"] as! String
                if(loc != nil)
                {
                    appearInformation = .strFromItemDetail
                    getFloorData(locationId: locid)
                    self.lblAddress.text = loc?["address"] as? String
                }
                else{
                    
                        self.lblAddress.text = "No location found"
                
                }
                break
            case .strFromFirstLoad:
                //    dataFeeding(locationId: "")
                 self.expandCollapse(0, dict: self.dictFloorJT! as Dictionary<String, AnyObject>)
                 let vw = STRNavigationTitle.setTitle(TitleName.LocationInventory.rawValue, subheading: LocationName!)
                 vw.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: (self.navigationController?.navigationBar.frame.size.height)!)
                 
                 self.navigationItem.titleView = vw
                break
            case .strFromFirstLoadPersisted:
//                let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
//                let locid = loc?["locationId"] as! String
//                if(loc != nil)
//                {
//                    appearInformation = .strFromItemDetail
//                    getFloorData(locationId: locid)
//                    self.lblAddress.text = loc?["address"] as? String
//                }
//                else{
//                    
//                    self.lblAddress.text = "No location found"
//                    
//                }

                break
            }
      //  }
        
        
        
        
    }
    
    func presentLogin() -> () {
        let login = STRLoginViewController(nibName: "STRLoginViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: login)
        self.navigationController?.present(nav, animated: false, completion: {
            
        })
        
    }
    
    func backToDashbaord(_ sender: AnyObject) {
//          let appDelegate = UIApplication.shared.delegate as! AppDelegate
//          appDelegate.initSideBarMenu()
        self.navigationController?.popViewController(animated: true)
    }

    func dataFeeding(locationId : String){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        var dict = Dictionary<String,String>()
        let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
        var lat: String
        var long: String
        if(BeaconHandler.sharedHandler.coordinate != nil)
        {
            long = "\(BeaconHandler.sharedHandler.coordinate!.longitude)"
            lat = "\(BeaconHandler.sharedHandler.coordinate!.latitude)"
        }
        else{
            long = " "
            lat = " "
 
        }
        
        if(loc != nil)
        {
            dict["latitude"] = lat
            dict["longitude"] = long
            dict["locationId"] = locationId
        }
        else{
            dict["latitude"] = lat
            dict["longitude"] = long
            dict["locationId"] = locationId
        }
        
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(dict as Dictionary<String, AnyObject>, serviceType: .strApiGetLocationData, success: { (response) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                print(response)
                
                
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    self.addNodata()
                    return
                }
                
                guard let data = response["data"] as? [String:AnyObject],let readerSearchNearLocationsResponse = data["readerSearchNearLocationsResponse"] as? Dictionary<String,AnyObject>,let location = readerSearchNearLocationsResponse["location"] as? [String:AnyObject]else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                
                
                self.location = location
                self.zone_obj.removeAll()
              //  self.zone_obj.append(contentsOf: zones)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                //   self.setUData()
               
                
                self.tempdic?["near"]  = self.location["near"] as? [Dictionary<String,AnyObject>] as AnyObject
                self.tempdic?["other"]  = self.location["other"] as? [Dictionary<String,AnyObject>] as AnyObject
             //   self.location = self.tempdic!
//                self.zone_obj.removeAll()
//                self.zone_obj.append(contentsOf: zones)
            //    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
//                let vw  = STRChangeLocationViewController(nibName: "STRChangeLocationViewController", bundle: nil)
//                vw.arrNear =  self.tempdic?["near"] as? [Dictionary<String,AnyObject>]
//                vw.arrayOther = self.tempdic?["other"] as? [Dictionary<String,AnyObject>]
//                vw.delegate = self
//                let nav = UINavigationController(rootViewController: vw)
//                self.present(nav, animated: true, completion: {
//                    
//                })
                
                
                /*
                
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                     self.addNodata()
                    return
                }
                
                guard let data = response["data"] as? [String:AnyObject],let readerSearchNearLocationsResponse = data["readerSearchNearLocationsResponse"] as? Dictionary<String,AnyObject>,let location = readerSearchNearLocationsResponse["location"] as? [String:AnyObject],let zones = readerSearchNearLocationsResponse["zones"] as? [Dictionary<String,AnyObject>]else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.location = location
                self.zone_obj.removeAll()
                self.zone_obj.append(contentsOf: zones)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.setUData()
                 */
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                 self.addNodata()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }
    }
    
    func getFloorZonesProducts(floorid : String){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["skuId": floorid as AnyObject], serviceType: .strApiGetInventory, success: { (response) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                print(response)
                if(response["code"]?.intValue != 200)
                {
                    

                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? AnyObject else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                print(data)
                guard let zones = data["zones"] as? [Dictionary<String,AnyObject>]  else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
               print(zones)
               self.zone_obj.removeAll()
               self.zone_obj.append(contentsOf: zones)
               self.setUpProductData()
               
               
                
//                self.productDetails.removeAll()
//                self.itemList.removeAll()
//                self.productDetails =  productDetails
//                self.itemList.append(contentsOf: items)
//                self.setUpData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
            
        }
    }

    func setUpProductData(){
        var count = 0
        for (indx,z) in self.zone_obj.enumerated(){
            var product = z["productList"] as? [Dictionary<String,AnyObject>]
            
                    for index in 0..<product!.count{
                        print(product![index]["things"])
                      var sensor = product![index]["things"] as? Dictionary<String,AnyObject>
                        if(sensor?.count == 0)
                        {
                            continue
                        }
                        var dict = product?[index]
                        dict?["status"] = STRInventoryStatus.strInventoryStatusInitial.rawValue as AnyObject
                        product![index] = dict!
                        print(dict?["status"])
            
            //        
             //           if((sensor!["type"] as? String)!.uppercased() == "BEACON")
            //            {
            //                var dict = product!
            //                dict["status"] = STRInventoryStatus.strInventoryStatusInitial.rawValue as AnyObject
            //                product![index] = dict
            //                print(dict["status"])
            //            }
            //            else{
            //                var dict = product!
            //                dict["status"] = STRInventoryStatus.strInventoryStatusNotBeacon.rawValue as AnyObject
            //                product![index] = dict
            //                print(dict["status"])
            //
            //            }
                        count = count + 1
                    }
            var dict = self.zone_obj[indx]
            dict["productList"] = product as AnyObject
            dict["is_expanded"] = false as AnyObject
            self.zone_obj[indx] = dict
        }
        self.setCount()

        self.tblInventory.reloadData()
        
        
    }
    
    func setSelectedLocationInfo( locationInfo : Dictionary<String,AnyObject>)
    {
        print("location Selected \(locationInfo)")
        appearInformation = .strFromItemDetail
        getFloorData(locationId: locationInfo["locationId"] as! String)
        self.lblAddress.text = locationInfo["address"] as! String
    }
    
    func getFloorData(locationId : String){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        var dict = Dictionary<String,String>()
        //let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
       
        dict["locId"] = locationId
        
        
        
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(dict as Dictionary<String, AnyObject>, serviceType: .strFloorListApi, success: { (response) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                print(response)
                
                
                guard let data = response["data"] as? [String:AnyObject],let zones = data["floors"] as? [Dictionary<String,AnyObject>]else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                print(data)
                
                self.location = data
                self.zone_obj.removeAll()
                self.zone_obj.append(contentsOf: zones)
                self.setUDataFloor()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                
                
                
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.addNodata()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }
    }
    func setUDataFloor(){
        
        for (indx,z) in self.zone_obj.enumerated(){
           
            var dict = self.zone_obj[indx]
            dict["productList"] = z["productList"]
            
            dict["is_expanded"] = false as AnyObject
            dict["floorValue"] = true as AnyObject
            dict["status"] = STRInventoryStatus.strInventoryStatusInitial.rawValue as AnyObject
            self.zone_obj[indx] = dict
            
        }
        self.tblInventory.reloadData()
        
    }
    
    
    func setCount(){
        var allCount = 0
        var found  = 0
        var notFound = 0
        for (_,z) in self.zone_obj.enumerated(){
       let product = z["productList"] as? [Dictionary<String,AnyObject>]

        for (_, dic) in product!.enumerated() {
            if (dic["status"] as! NSInteger == STRInventoryStatus.strInventoryStatusFound.rawValue) {
                found = found + 1
                
            }
             allCount = allCount + 1
        }
        for (_, dic) in product!.enumerated() {
            if (dic["status"] as! NSInteger == STRInventoryStatus.strInventoryStatusNotFound.rawValue) {
                notFound = notFound + 1
            }
        }
    }
       DispatchQueue.main.async(execute: {
        self.lblFound.text = "Nearby : \(found)"
        self.lblAll.text = "All : \(allCount)"
        
        })
    
    }
    func setFont(){
          lblAddress.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
          lblMissing.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
          lblFound.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
          lblAll.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
    }
    
    //MARK: TABLEVIEW DELEGATE METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.zone_obj.count == 0 {
            return 0
        }
        for view in self.view.subviews{
            if view.tag == 10002 {
                view.removeFromSuperview()
            }
        }

        return zone_obj.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let z = self.zone_obj[section]
        if(z["is_expanded"] as? Bool == false){
            return 0
        }
        let product = z["productList"] as? [Dictionary<String,AnyObject>]
        if product != nil && product!.count == 0 {
            return 0
        }
        for view in self.view.subviews{
            if view.tag == 10002 {
                view.removeFromSuperview()
            }
        }

        return product!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: STRInventoryTableViewCell = self.tblInventory.dequeueReusableCell(withIdentifier: "STRInventoryTableViewCell") as! STRInventoryTableViewCell
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        let z = self.zone_obj[indexPath.section]
        let product = z["productList"] as? [Dictionary<String,AnyObject>]
        let data = product![indexPath.row]
        cell.setCellData(data, indexPath: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        appearInformation = .strFromItemDetail
        
     /*   let vw = STRInventoryListViewController(nibName: "STRInventoryListViewController", bundle: nil)
        vw.skuId =  "\(data["skuId"]!)"
        vw.locationName = self.shipmentData!["l4"] as! String
        vw.titleString = self.shipmentData!["caseNo"] as! String
        vw.idValue = "\(data["skuId"]!)"
        vw.flagToShowEdit = true
        self.navigationController?.pushViewController(vw, animated: true)*/
        
        resetState()
        let vw = STRInventoryListViewController(nibName: "STRInventoryListViewController", bundle: nil)
        let z = self.zone_obj[indexPath.section]
        let product = z["productList"] as? [Dictionary<String,AnyObject>]
         let data = product![indexPath.row]
        vw.skuId =  "\(data["id"] as! String)"
        vw.locationName = self.lblAddress.text
        vw.idValue = "\(data["id"] as! String)"
        vw.titleString =  TitleName.LocationInventoryDetails.rawValue
        vw.sourceScreen = .strItemDetailFromItemScan
        self.navigationController?.pushViewController(vw, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dict = self.zone_obj[section]
       
        
        
        let vw = STRInventorySectionHeaderView.sectionView(dict,section: section) 
        vw.frame =  CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60)
        
            vw.block_sectionClicked = { section in
                self.expandCollapse(section, dict: dict)
            }
        
        return vw
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func expandCollapse(_ section:Int, dict: Dictionary<String,AnyObject> )
    {
        if(dict["floorValue"] as? Bool == true){
            floorId =  dict["id"] as? String
            getFloorZonesProducts(floorid: dict["id"] as! String)
            return
        }
        let z = self.zone_obj[section]
        if( z["is_expanded"] as? Bool == false){
            self.expand(section)
        }
        else{
            self.collapse(section)
        }
    }
    func expand(_ section: Int){
        var z = self.zone_obj[section]
        z["is_expanded"] =  true as AnyObject
        let product = z["productList"] as? [Dictionary<String,AnyObject>]
        var row = [IndexPath]()
        for (idx,_) in product!.enumerated(){
            row.append(IndexPath(row: idx, section: section))
        }
        self.zone_obj[section] = z
        self.tblInventory.beginUpdates()
        self.tblInventory.insertRows(at: row, with: UITableViewRowAnimation.bottom)
        self.tblInventory.endUpdates()

    }
    func collapse(_ section: Int){
        var z = self.zone_obj[section]
        z["is_expanded"] =  false as AnyObject
        let product = z["productList"] as? [Dictionary<String,AnyObject>]
        var row = [IndexPath]()
        for (idx,_) in product!.enumerated(){
            row.append(IndexPath(row: idx, section: section))
        }
        self.zone_obj[section] = z
        self.tblInventory.beginUpdates()
        self.tblInventory.deleteRows(at: row, with: UITableViewRowAnimation.top)
        self.tblInventory.endUpdates()
    }
    
    func addNodata(){
        let noData = Bundle.main.loadNibNamed("STRNoDataFound", owner: nil, options: nil)!.last as! STRNoDataFound
        noData.tag = 10002
        self.view.addSubview(noData)
        noData.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(48)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
    }
    func setUData(){
        var count = 0
      /*  for (indx,z) in self.zone_obj.enumerated(){
            var product = z["products"] as? [Dictionary<String,AnyObject>]
            
            for index in 0..<product!.count{
                var sensor = product![index]["sensor"] as? Dictionary<String,AnyObject>
                if((sensor!["type"] as? String)!.uppercased() == "BEACON")
                {
                    var dict = product![index]
                    dict["status"] = STRInventoryStatus.strInventoryStatusInitial.rawValue as AnyObject
                    product![index] = dict
                    print(dict["status"])
                }
                else{
                    var dict = product![index]
                    dict["status"] = STRInventoryStatus.strInventoryStatusNotBeacon.rawValue as AnyObject
                    product![index] = dict
                    print(dict["status"])
                    
                }
                count = count + 1
            }
            var dict = self.zone_obj[indx]
            dict["products"] = product as AnyObject
            dict["is_expanded"] = false as AnyObject
            self.zone_obj[indx] = dict
        } */
        self.lblAll.text = "All : \(count)"
        self.lblFound.text = "Nearby : 0"
        let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
        let arr = self.location["near"] as? [Dictionary<String,AnyObject>]
        if(arr == nil || arr?.count == 0)
        {
            self.flagScanDisabled = true
        }
        if(loc != nil)
        {
            
            for (_,dic) in arr!.enumerated(){
                let idLocation  = String(format:"%@", loc!["locationId"] as! String)
                
                if( idLocation == (dic["locationId"] as! String))
                {
                    self.flagScanDisabled = false
                }
                else{
                    self.flagScanDisabled = true
                }
            }
        }
        let flagSession = utility.getflagSession()
        if( arr?.count > 0 &&  self.flagScanDisabled == true && flagSession == true && appearInformation != .strFromSearchLocation)
        {
            utility.setflagSession(false)
            //show alert
            let str = "We have detected your location as \(arr!.first!["address"]). Do you want to switch?"
            let alert = UIAlertView(title: "", message: str, delegate:self, cancelButtonTitle: "No Thanks", otherButtonTitles: "Switch")
            alert.show()
        }
        let dict = self.location["current"] as! [Dictionary<String,AnyObject>]
        if(dict.count > 0)
        {
            self.lblAddress.text = dict.first!["address"] as! String
            self.currentID = dict.first!["locationId"] as! NSInteger
            self.tblInventory.reloadData()
            if(self.zone_obj.count == 0){
                self.addNodata()
            }
        }
        else{
            //show search :D
            appearInformation = .strFromSearchLocation
            let vw  = STRChangeLocationViewController(nibName: "STRChangeLocationViewController", bundle: nil)
            vw.arrNear =  self.location["near"] as? [Dictionary<String,AnyObject>]
            vw.arrayOther = self.location["other"] as? [Dictionary<String,AnyObject>]
            let nav = UINavigationController(rootViewController: vw)
            self.present(nav, animated: true, completion: {
                
            })
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if(buttonIndex == 1)
        {
         let near =   self.location["near"] as? [Dictionary<String,AnyObject>]
         utility.setselectedLocation((near?.first)!)
            let loc = utility.getselectedLocation() as? Dictionary<String,AnyObject>
            let locid = loc?["locationId"] as! String
         self.dataFeeding(locationId: locid)
        }
    }

    
    func resetState(){
        self.vwScan.resetState()
        if(self.locationManager != nil)
        {
        self.beaconManager.stopRangingBeacons(in: self.beacon)
        }

    }
    func updateStatus(_ beacons:[CLBeacon]?)
    {
        for (_,data) in beacons!.enumerated(){
        for (indx,z) in self.zone_obj.enumerated(){
        var product = z["productList"] as? [Dictionary<String,AnyObject>]
        for (idx, dic) in product!.enumerated() {
           
            let sensor  = dic["things"]! as? [Dictionary<String,AnyObject>]
            if(sensor?.count == 0)
            {
                continue
            }
            if ((sensor![0]["major"] as! NSNumber == data.major) && (sensor![0]["minor"] as! NSNumber == data.minor) && (dic["status"] as! NSInteger != STRInventoryStatus.strInventoryStatusFound.rawValue)) {
                var dict = product![idx]
                dict["status"] = STRInventoryStatus.strInventoryStatusFound.rawValue as AnyObject
                product![idx] = dict
            }
        }
            
            var dict = self.zone_obj[indx]
            dict["productList"] = product as AnyObject
            self.zone_obj[indx] = dict
      }
    }
        self.tblInventory.reloadData()
    }
    
    func markeRemainingUndetected(){
        for (indx,z) in self.zone_obj.enumerated(){
        var product = z["productList"] as? [Dictionary<String,AnyObject>]
        for (idx, dic) in product!.enumerated() {
            let status = dic["status"]!
            if ((status as! NSInteger) == STRInventoryStatus.strInventoryStatusInitial.rawValue ) {
                var dict = product![idx]
                dict["status"] = STRInventoryStatus.strInventoryStatusNotFound.rawValue as AnyObject
                product![idx] = dict
            }
        }
            var dict = self.zone_obj[indx]
            dict["productList"] = product as AnyObject
            self.zone_obj[indx] = dict
    }
        self.tblInventory.reloadData()
    }
    func makeUpdateData(){
        var items = [Dictionary<String,AnyObject>]()
        for (_,z) in self.zone_obj.enumerated(){
            var dictData = Dictionary<String,AnyObject>()
            dictData["id"] = z["id"]
            var product = z["productList"] as? [Dictionary<String,AnyObject>]
            for index in 0..<product!.count{
                var pro = product![index]
                dictData["id"] = pro["id"]
                dictData["id"] = pro["id"]
                var sensor = product![index]["things"] as? [Dictionary<String,AnyObject>]
                if(sensor?.count == 0)
                {
                    continue
                }
                dictData["id"] = sensor![0]["id"]
                var dict = product![index]
                if(dict["status"] as! NSInteger == STRInventoryStatus.strInventoryStatusFound.rawValue)
                {
                    dictData["found"] = "1" as AnyObject

                }
                else{
                    dictData["found"] = "0" as AnyObject
                }
                 items.append(dictData)
            }
        }
      //  postScanData(array: items)
    }
    
    func postScanData(array:[Dictionary<String,AnyObject>]){
        
        let locationId =  self.currentID
        var lat: String
        var long: String
        if(BeaconHandler.sharedHandler.coordinate != nil)
        {
            long = "\(BeaconHandler.sharedHandler.coordinate!.longitude)"
            lat = "\(BeaconHandler.sharedHandler.coordinate!.latitude)"
        }
        else{
            long = " "
            lat = " "
            
        }
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["items":array as AnyObject,"locationId":locationId! as AnyObject,"currentLatitude":lat as AnyObject,"currentLongitude":long as AnyObject,"isPresentOnLocation": self.flagScanDisabled as AnyObject,"scanStartTime": self.startTime! as AnyObject,"scanEndTime":self.endTime! as AnyObject], serviceType: .strUpdatScanInformation, success: { (response) in
            print(response)
            DispatchQueue.main.async {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                
                utility.showAlertSheet(TextMessage.alert.rawValue, message: "\(response["message"] as! String)", viewController: self)
                    return
            }
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }
    }
    
    
    //MARK: location manager methods for beacon scanning
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(!CLLocationManager.locationServicesEnabled())
        {
            
        }
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedAlways )
        {
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        if (state ==  CLRegionState.inside)
        {
           
        }
        else
        {
           
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if(region .isKind(of: CLCircularRegion.self))
        {
            
        }
        else if(region.isKind(of: CLBeaconRegion.self))
        {
            
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if(region .isKind(of: CLCircularRegion.self))
        {
            
        }
        else if(region.isKind(of: CLBeaconRegion.self))
        {
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if( (floor(NSDate().timeIntervalSince1970).truncatingRemainder(dividingBy: 10)) == 0)
        {
          updateStatus(beacons)
        }
    }
    
    
    
    

}
extension STRInventorViewController_copy : KTKBeaconManagerDelegate
{
    public func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus){
        
    }
    
    public func beaconManager(_ manager: KTKBeaconManager, didDetermineState state: CLRegionState, for region: KTKBeaconRegion){
       
    }
    public func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
       
    }
    
    public func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        print("Did exit region \(region)")
        
    }
    
    
    public func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        if( (floor(NSDate().timeIntervalSince1970).truncatingRemainder(dividingBy: 10)) == 0)
        {
            updateStatus(beacons)
        }
       
    }
    
    
    
}
