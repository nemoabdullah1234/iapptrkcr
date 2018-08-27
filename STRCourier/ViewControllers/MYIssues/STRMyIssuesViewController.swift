import UIKit

class STRMyIssuesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet var tblMyIssues: UITableView!
    var tableData:[Dictionary<String,AnyObject>]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        customizeNavigationforAll(self)
        self.getData()
        // Do any additional setup after loading the view.
        
    }
    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.tableData != nil)
        {
            return (self.tableData?.count)!
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "globalSearch")
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "globalSearch")
        }
        cell!.textLabel!.text = self.tableData![indexPath.row]["ShippingNo"] as? String
         cell!.detailTextLabel!.text = self.tableData![indexPath.row]["l2"] as? String
        cell!.detailTextLabel?.textColor = UIColor.darkGray
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableData![indexPath.row]
        let VW = STRReportIssueViewController(nibName: "STRReportIssueViewController", bundle: nil)
        VW.issueID = data["issueId"] as! String
        VW.shipmentNo = data["ShippingNo"] as! String
        VW.caseNo = data["CaseNo"] as! String
        self.navigationController?.pushViewController(VW, animated: true)
    }
    // Data Feeding
    
    func getData() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith([:], serviceType: .strGetIssues, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerMyIssuesResponse = data["readerMyIssuesResponse"] as? [String:AnyObject],let issues = readerMyIssuesResponse["issues"] as? [[String:AnyObject]] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.tableData=issues
                self.tblMyIssues.reloadData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
        }
    }


}
