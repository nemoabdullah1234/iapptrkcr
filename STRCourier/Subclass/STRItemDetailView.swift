import UIKit
import Crashlytics
class STRItemDetailView: UIView,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate {
    var tableData: [Dictionary<String,AnyObject>]?
    
    func setTableData(){
        /*set up items*/
        for index in 0..<tableData!.count{
            var sensor = tableData![index]["sensor"] as? Dictionary<String,AnyObject>
            
            if( sensor != nil && (sensor!["type"] as! String).uppercased() == "BEACON")
            {
                
                var dict = tableData![index]
                if(dict["isMissing"] as? Int == 0 )
                {
                    dict["status"] = STRInventoryStatus.strInventoryStatusInitial.rawValue as AnyObject
                }
                else{
                    dict["status"] = STRInventoryStatus.strInventoryStatusNotFound.rawValue as AnyObject
                }
                tableData![index] = dict
                print(dict["status"])
            }
            else{
                //                var dict = tableData![index]
                //                dict["status"] = STRInventoryStatus.strInventoryStatusNotBeacon.rawValue as AnyObject
                //                tableData![index] = dict
                //                print(dict["status"])
                
                var dict = tableData![index]
                if(dict["isMissing"] as? Int == 0 )
                {
                    dict["status"] = STRInventoryStatus.strInventoryStatusInitial.rawValue as AnyObject
                }
                else{
                    dict["status"] = STRInventoryStatus.strInventoryStatusNotFound.rawValue as AnyObject
                }
                tableData![index] = dict
                print(dict["status"])
                
                
            }
        }
        startCall()
    }
    func startCall(){
        self.vwScan.scanBlock = {(tag) in
            
            if(self.flagScanDisabled == true)
            {
                let rootViewController: UIViewController = UIApplication.shared.windows[0].rootViewController!
                utility.createAlert("", alertMessage: "You are not present at this location", alertCancelTitle: "OK", view: rootViewController)
                return
            }
            
            if(tag == 1)
            {
                self.locationManager.stopRangingBeacons(in: self.beacon)
                self.markeRemainingUndetected()
                self.itemViewScan(false)
            }
            else{
                self.itemViewScan(true)
                self.locationManager = CLLocationManager()
                let uuid:UUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
                self.beacon = CLBeaconRegion(proximityUUID: uuid, identifier:"")
                self.locationManager.requestAlwaysAuthorization()
                self.beacon.notifyOnEntry=true
                self.beacon.notifyOnExit=true
                self.beacon.notifyEntryStateOnDisplay=true
                CLLocationManager.locationServicesEnabled()
                self.locationManager.startMonitoring(for: self.beacon)
                self.locationManager.startRangingBeacons(in: self.beacon)
                self.locationManager.delegate = self
            }
            
        }
    }
    func stopLocation(){
        if(self.vwScan.btnScan?.tag == 0)
        {
            return
        }
        if (self.beacon != nil){
            self.locationManager.stopRangingBeacons(in: self.beacon)
        }
        self.markeRemainingUndetected()
        self.vwScan.resetState()
        
    }
    
    var locationManager : CLLocationManager!
    var beacon : CLBeaconRegion!
    
    @IBOutlet var vwScan: STRScanViewNew!
    
    var flagScanDisabled: Bool = false
    
    
    @IBOutlet internal var tblItemDetail: UITableView!
    
    var blockForItemClicked: ((Dictionary<String,AnyObject>)->())?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.tableData != nil)
        {
            return (self.tableData?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: STRCaseDetailNewTableViewCell = self.tblItemDetail.dequeueReusableCell(withIdentifier: "STRCaseDetailNewTableViewCell") as! STRCaseDetailNewTableViewCell
        cell.setUpData(self.tableData![indexPath.row],IndexPath: indexPath.row)
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.blockForItemClicked != nil)
        {
            self.blockForItemClicked!(self.tableData![indexPath.row])
        }
        
    }
    override func awakeFromNib() {
        let nib = UINib(nibName: "STRCaseDetailNewTableViewCell", bundle: nil)
        tblItemDetail.register(nib, forCellReuseIdentifier: "STRCaseDetailNewTableViewCell")
        tblItemDetail.rowHeight = UITableViewAutomaticDimension
        tblItemDetail.estimatedRowHeight = 60
    }
    
    /*scaning methods*/
    func updateStatus(_ beacons:[CLBeacon]?)
    {
        for (_,data) in beacons!.enumerated(){
            for (idx, dic) in self.tableData!.enumerated() {
                let sensor = dic["things"]! as? [Dictionary<String,AnyObject>]
                
                if ((sensor![0]["major"] as? NSNumber)! == data.major && (sensor![0]["minor"] as? NSNumber) == data.minor && dic["status"] as! NSInteger != STRInventoryStatus.strInventoryStatusFound.rawValue) {
                    self.tableData![idx]["status"] = STRInventoryStatus.strInventoryStatusFound.rawValue as AnyObject
                    let data = self.tableData![idx]
                    self.tableData!.remove(at: idx)
                    self.tableData!.insert(data, at: idx)
                }
            }
        }
        self.tblItemDetail.reloadData()
    }
    func markeRemainingUndetected(){
        for (idx, dic) in self.tableData!.enumerated() {
            let status = dic["status"]!
            if ((status as! NSInteger) == STRInventoryStatus.strInventoryStatusInitial.rawValue ) {
                self.tableData![idx]["status"] = STRInventoryStatus.strInventoryStatusNotFound.rawValue as AnyObject
            }
        }
        self.tblItemDetail.reloadData()
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
        if( (floor(Date().timeIntervalSince1970).truncatingRemainder(dividingBy: 10)) == 0)
        {
            updateStatus(beacons)
        }
    }
    
    func itemViewScan(_ success:Bool){
        var didSuceed:String?
        if success{
            didSuceed = "START"
        }
        else{
            didSuceed = "STOP"
        }
        Answers.logCustomEvent(withName: "ITEM LIST SCAN" , customAttributes:["event":didSuceed!])
    }
}

