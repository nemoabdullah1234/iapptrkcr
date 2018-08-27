import UIKit

class STRNotificationVC: UIViewController {
    @IBOutlet var tableView: UITableView!
    var dataArrayObj = [AnyObject]()
    var isFirstLoad: Bool?
    var isDeleteAll: Bool = false
    var caseDetailObj : STRDetailSliderViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = TitleName.Notifications.rawValue
        customizeNavigationWithDeleteAll(self)
        // Do any additional setup after loading the view.
        self.revealViewController().panGestureRecognizer().isEnabled = false
        isFirstLoad = false
        let nib = UINib(nibName: "NotificationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "notificationCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 140
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self ,action: #selector(HomeViewController.refresh(_:)), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)

        getData()
    }
    func refresh(_ refreshControl:UIRefreshControl){
        refreshControl.endRefreshing()
        self.getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func toggleSideMenu(_ sender: AnyObject) {
        
        self.revealViewController().revealToggle(animated: true)
        
    }
    
    func deleteButtonClicked(_ sender : AnyObject){
        
        isDeleteAll = true
        deleteNotification([], deleteValue: isDeleteAll)
        
    }
    
    
    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
    
    // Data Feeding
    func getData() {
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        
        
        generalApiobj.hitApiwith([:], serviceType: .strApiNotificationApi, success: { (response) in
             print(response)
            DispatchQueue.main.async {
                print(response)
                if(response["code"]?.intValue != 200)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let readerGetNotificationsResponse = response["data"] as? [Dictionary< String,AnyObject>] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.isFirstLoad = true
                
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.dataArrayObj.removeAll()
                self.dataArrayObj = readerGetNotificationsResponse as [AnyObject]
                self.tableView.reloadData()
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                NSLog(" %@", err)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFirstLoad == false {
            return 0
        }
        
        if self.dataArrayObj.count == 0 {
            addNodata()
            return 0
        }
        for view in self.view.subviews{
            if(view.tag == 10002)
            {
                view.removeFromSuperview()
            }
            self.view.viewWithTag(10002)?.removeFromSuperview()
        }
        return self.dataArrayObj.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "notificationCell") as! NotificationCell
        
        let infoDictionary = self.dataArrayObj[indexPath.row] as? [String : AnyObject]
        cell.setUpData(infoDictionary!)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        
    }
    
    internal func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        
        let watch = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let infoDictionary = self.dataArrayObj[indexPath.row] as? [String : AnyObject]
          //  print("watch button tapped \(infoDictionary)")
          //  infoDictionary!["type"]
            self.deleteNotificationParameter((infoDictionary!["id"])! as! String , deleteValue: 0)
            
        }
        watch.backgroundColor = UIColor.red
        
        
        
        return [watch]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        
        if self.dataArrayObj.count == 0 {
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if self.dataArrayObj.count == 0 {
            
            
        }else {
            
            let infoDictionary = self.dataArrayObj[indexPath.row] as? [String : AnyObject]
            let dict = infoDictionary!["params"] as? [String:Any]
            if(dict == nil || dict?.count == 0)
            {
                return
            }
            
            let notificationType:NSInteger = returnTypeOfNotification(type:infoDictionary!["type"] as! String)
            
            if notificationType == 1  || notificationType == 2 || notificationType == 3 || notificationType == 9 || notificationType == 10 || notificationType == 17 || notificationType == 18{
                let vc =  STRDetailSliderViewController(nibName: "STRDetailSliderViewController", bundle: nil)
                vc.caseNo = "" //String(infoDictionary!["params"]!["orderId"]! as! String);
                vc.shipmentNo = ""// String(infoDictionary!["params"]!["shipmentId"]! as! String);
                vc.shipmentid = String(infoDictionary!["params"]!["shipmentId"]! as! String);
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if notificationType == 4  || notificationType == 5 || notificationType == 6 || notificationType == 7{
               /* let strReportIssue = STRReportIssueNewViewController.init(nibName: "STRReportIssueNewViewController", bundle: nil)
                strReportIssue.caseNo =  String(infoDictionary!["params"]!["orderId"] as! String);
                strReportIssue.issueID = String(infoDictionary!["params"]!["issueId"]  as! String);
                strReportIssue.reportType = .strReportCase
                strReportIssue.shippingNo = String(infoDictionary!["params"]!["shipmentId"]!  as! String);
                self.navigationController?.pushViewController(strReportIssue, animated: true)*/
                let strReportIssue = STRReportIssueNewViewController.init(nibName: "STRReportIssueNewViewController", bundle: nil)
                strReportIssue.caseNo = ""
                let params = infoDictionary!["params"] as! Dictionary<String , AnyObject>
                if params.keys .contains("orderId")
                {
                     strReportIssue.caseID  =  String(infoDictionary!["params"]!["orderId"] as! String);
                }
               
                strReportIssue.issueID = String(infoDictionary!["params"]!["issueId"]  as! String);
                strReportIssue.reportType = .strReportCase
                strReportIssue.shipmentId = String(infoDictionary!["params"]!["shipmentId"]!  as! String);
                self.navigationController?.pushViewController(strReportIssue, animated: true)
            }else if notificationType == 8   {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
            }
        }
    }
    func returnTypeOfNotification(type: String)-> NSInteger{
        switch type {
        case "GPSBluetoothDown" :
            return 8
        case "CaseCreation":
            return 1
        case "ShipmentSoftDeliveredCR",
             "ShipmentHardDeliveredCR",
             "ShipmentPartialDeliveredCR",
             "ShipmentHardShippedCR",
             "ShipmentSoftShippedCR",
             "ShipmentPartialShippedCR",
             "ShipmentScheduledCR",
             "ShipmentSoftDeliveredSR",
             "ShipmentHardDeliveredSR",
             "ShipmentPartialDeliveredSR",
             "ShipmentHardShippedSR",
             "ShipmentSoftShippedSR",
             "ShipmentPartialShippedSR",
             "ShipmentScheduledSR",
             "CourierAssignment",
             "SurgeryDateChange",
             "CaseAssignedFromSalesRep",
             "ShipmentDelayedSR",
             "ShipmentDelayedCR",
             "CaseAssignedToSalesRep":
            
            return 1
            
        case "IssueRespondedSR",
             "IssueRespondedCR","IssueCreatedSR","IssueCreatedCR":
            return 6
        default:
            break;
        }
        return 0
    }

    func addNodata(){
        let noData = Bundle.main.loadNibNamed("STRNoDataFound", owner: nil, options: nil)!.last as! STRNoDataFound
        noData.tag = 10002
        self.view.addSubview(noData)
        noData.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
        
    }
    
    func deleteNotificationParameter(_ notificationID : String , deleteValue : Int) {
        var ar = [String]()
        ar.append(notificationID)
       deleteNotification(ar as NSArray, deleteValue: false)
    }
    
    
    
    // Data Feeding
    func deleteNotification(_ param : NSArray, deleteValue : Bool) {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        
        
        generalApiobj.hitApiwith(["notificationIdList":param, "archiveAll" : deleteValue as AnyObject], serviceType: .strDeleteNotification, success: { (response) in
            DispatchQueue.main.async {
                
                print(response)
                
                let dataDictionary = response["code"] as! Int
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                
                if dataDictionary == 200{
                    
                    self.getData()
                }
                
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.addNodata()
                NSLog(" %@", err)
            }
        }
    }
    
}
