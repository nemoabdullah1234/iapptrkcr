import UIKit
enum STRTypeOfReport:Int{
    case strReportCase = 0
    case strReportDueback
}

class STRReportIssueNewViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet var vwSave: UIView!
    
    @IBOutlet var vwAddButton: UIView!
    var readonly:Bool?
    var caseNo:String?
    var caseID:String?
    
    var issueID:String?
    var shippingNo:String?
    var shipmentId:String?
    var caseDetails: Dictionary<String,AnyObject>?
    var comments:[Dictionary<String,AnyObject>]?
    var items:[Dictionary<String,AnyObject>]?
    var reportType: STRTypeOfReport?
    var fromImageExpand:Bool?
    var trackingID:String?
    @IBOutlet var heightAddComment: NSLayoutConstraint!
    @IBOutlet var lblAddComment: UILabel!
    @IBOutlet var lblTrackingID: UILabel!
    @IBOutlet var tblReportIssue: UITableView!
    @IBAction func btnAddComment(_ sender: AnyObject) {
        if  trackingID != ""{
        let vw = STRComposeIssueViewController(nibName: "STRComposeIssueViewController", bundle: nil)
            vw.trackingID = trackingID
            vw.itemsArray = self.items
            vw.shippingNo = self.shippingNo
            vw.shipmentId = self.shipmentId
            vw.caseNo     = self.caseNo
            vw.reportType = reportType
           self.navigationController?.pushViewController(vw, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = TitleName.ReportIssue.rawValue
        customizeNavigationforAll(self)
        // Do any additional setup after loading the view.
        self.revealViewController().panGestureRecognizer().isEnabled = false
        let nib = UINib(nibName: "STRIssueDetailTableViewCell", bundle: nil)
        tblReportIssue.register(nib, forCellReuseIdentifier: "STRIssueDetailTableViewCell")
        tblReportIssue.rowHeight = UITableViewAutomaticDimension
        tblReportIssue.tableFooterView = UIView()
        self.tblReportIssue.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tblReportIssue.estimatedRowHeight = 140
        setUpFont()
        if(readonly == true)
        {
            self.heightAddComment.constant = 0
            self.vwAddButton.isHidden = true
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(self.fromImageExpand == true)
        {
            self.fromImageExpand = false
            return
        }
        
        if(reportType == .strReportCase)
        {
            dataFeeding()
        }
        else{
            dataFeedingGetComment()
        }
         self.navigationController?.navigationBar.isHidden = false
    }
    
    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    func setUpFont(){
        self.vwSave.layer.cornerRadius = 5.0
        self.lblAddComment.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func backToDashbaord(_ back:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.comments ==  nil || self.comments?.count == 0)
        {
            self.addNodata()
            return 0
        }
        for view in self.view.subviews{
            if(view.tag == 10002)
            {
                view.removeFromSuperview()
            }
            self.view.viewWithTag(10002)?.removeFromSuperview()
        }
        return self.comments!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.comments == nil)
        {
            return 0
        }
        let dict  =  self.comments![section] as? Dictionary<String,AnyObject>
        if(reportType == .strReportCase)
        {
        let arr = dict!["issueComments"] as? [Dictionary<String,AnyObject>]
        return arr!.count
        }
        else{
            let arr = dict!["itemComments"] as? [Dictionary<String,AnyObject>]
            return arr!.count

        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: STRIssueDetailTableViewCell = (self.tblReportIssue.dequeueReusableCell(withIdentifier: "STRIssueDetailTableViewCell") as? STRIssueDetailTableViewCell)!
        let dict  =  self.comments![indexPath.section]
        if(reportType == .strReportCase)
        {
            let arr = dict["issueComments"] as? [Dictionary<String,AnyObject>]
            cell.setUpData(arr![indexPath.row],index: indexPath.row)

        }
        else{
            let arr = dict["itemComments"] as? [Dictionary<String,AnyObject>]
            cell.setUpData2(arr![indexPath.row],index: indexPath.row)
        }
        cell.imageUrl = {(URL) in
            self.presentWithImageURL(URL)
        }
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        cell.layoutSubviews()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dict = self.comments![section]
        let vw = STRReportIssueSectionHeader.sectionView((dict["commentDate"] as? String)!)
        vw.frame =  CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        return vw
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    //MARK: get data from API
    func dataFeeding(){
       var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
         generalApiobj.hitApiwith(["shippingNo":self.shipmentId! as AnyObject,"issueId":self.issueID == nil ? "" as AnyObject : self.issueID! as AnyObject], serviceType: .strApiGetUserCommentsForIssue, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                   
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerGetIssueCommentsResponse = data["readerGetIssueCommentsResponse"] as? Dictionary< String,AnyObject>,let caseDetails = readerGetIssueCommentsResponse["caseDetails"] as? Dictionary<String,AnyObject>,let comments = readerGetIssueCommentsResponse["comments"] as? [Dictionary<String,AnyObject>],let items = readerGetIssueCommentsResponse["items"] as? [Dictionary<String,AnyObject>] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.caseDetails = caseDetails
                self.comments = comments
                self.items = items
                self.setUpData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.tblReportIssue.reloadData()
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }

    }
    func dataFeedingGetComment(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["caseNo":self.caseNo! as AnyObject,"skuId":self.shippingNo! as AnyObject], serviceType: .strApiGetCaseItemComments, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerGetCaseItemCommentsResponse = data["readerGetCaseItemCommentsResponse"] as? Dictionary< String,AnyObject>,let caseDetails = readerGetCaseItemCommentsResponse["itemDetails"] as? Dictionary<String,AnyObject>,let comments = readerGetCaseItemCommentsResponse["comments"] as? [Dictionary<String,AnyObject>] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.caseDetails = caseDetails
                self.comments = comments
                self.setUpData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.tblReportIssue.reloadData()
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }
 
    }
    
    func setUpData(){
        
        if(self.navigationController == nil)
        {
            return
        }
        
        trackingID = self.caseDetails!["l1"] as? String
        let vw = STRNavigationTitle.setTitle("Notes", subheading: "\(self.trackingID!)")
        vw.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: (self.navigationController?.navigationBar.frame.size.height)!)
        self.navigationItem.titleView = vw
    }
    
    func presentWithImageURL(_ url:String?){
        self.fromImageExpand = true;
        let vw = STRImageViewController(nibName: "STRImageViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: vw)
        vw.imageURL = url
        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    func addNodata(){
        let noData = Bundle.main.loadNibNamed("STRNoDataFound", owner: nil, options: nil)!.last as! STRNoDataFound
        noData.tag = 10002
        self.view.addSubview(noData)
        noData.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(120)-[noData]-(0)-[vwAddButton]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData,"vwAddButton":self.vwAddButton]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
        
    }

}
