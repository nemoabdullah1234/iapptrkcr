import UIKit
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
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}
public protocol LocationSelectorDelegate{
    func setSelectedLocationInfo( locationInfo : Dictionary<String,AnyObject>)
}

class STRChangeLocationViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet var btnCross: UIButton!
    @IBOutlet var vwWhiteBase: UIView!
    @IBAction func clearText(_ sender: AnyObject) {
        removeNodata()
        self.arrNearDS = self.arrNear!
        self.arrayOtherDS = self.arrayOther!
        self.tblView.reloadData()
        self.txtSearch.text = ""
    }
     var delegate: LocationSelectorDelegate?
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var lblNoData: UILabel!
    
    @IBOutlet var vwSegemntNew: UIView!
    let arraySectionHeadr = ["Near By","Other Locations"]
    var arrayOther: [Dictionary<String,AnyObject>]?
    var arrNear : [Dictionary<String,AnyObject>]?
    var idCurrent: String?
    @IBAction func btnBack(_ sender: AnyObject) {
        let dict = utility.getselectedLocation()
        if(dict.count>0)
        {
            self.dismiss(animated: true) {
                
            }
        }
        else{
           // utility.showAlertSheet("", message:"Select Location" , viewController: self)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.initSideBarMenu()
        }
    }
    var arrayOtherDS = [Dictionary<String,AnyObject>]()
    var arrNearDS = [Dictionary<String,AnyObject>]()
    override func viewDidLoad() {
        
        
    super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector:#selector(STRChangeLocationViewController.textChanged(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: self.txtSearch)
        let nib = UINib(nibName: "STRLocationTableViewCell", bundle: nil)
        self.tblView.register(nib, forCellReuseIdentifier: "STRLocationTableViewCell")
        tblView.estimatedRowHeight = 55
        self.vwWhiteBase.layer.cornerRadius = 4.0
        self.automaticallyAdjustsScrollViewInsets = false
        let dictLocation = utility.getselectedLocation() as? Dictionary<String,Any>

        //   var dict : Dictionary<String,AnyObject>?
        //   dict = arrNear?[0]
        if((dictLocation?.count)!>0)
        {
           idCurrent = dictLocation?["locationId"] as? String
        }
    
       
        
       setUpDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    func sortButtonClicked(_ sender : AnyObject){
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    func backToDashbaord(_ sender: AnyObject) {
        let dict = utility.getselectedLocation()
        if(dict.count>0)
        {
        self.dismiss(animated: true) { 
            
        }
        }
        else{
            utility.showAlertSheet("", message:"Select Location" , viewController: self)
        }
    }

       //MARK: change text location
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtSearch.resignFirstResponder()
       return true
    }
    func textChanged(_ textFeildNotification: Notification)
    {
        let textField = textFeildNotification.object as! UITextField
        
        if (textField.text == "") {
            self.arrNearDS = self.arrNear!
            self.arrayOtherDS = self.arrayOther!
            removeNodata()
        }
        else    {
            self.txtSearch.text = textField.text;
            self.enumerateArray()
        }
        
        self.tblView.reloadData()

    }
    func enumerateArray(){
        self.arrayOtherDS.removeAll()
        self.arrNearDS.removeAll()
        addNodata()
        for (_,data) in (self.arrNear?.enumerated())!{
            let str = data["address"] as? String
            if(str?.contains(txtSearch.text!) == true)
            {
                self.arrNearDS.append(data)
                removeNodata()

            }
        }
        
        for (_,data) in (self.arrayOther?.enumerated())!{
            let str = data["address"] as? String
            if(str?.contains(txtSearch.text!) == true)
            {
                self.arrayOtherDS.append(data)
                removeNodata()

            }
        }
         self.tblView.reloadData()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(range.location == 0 && string == " ")
        {
            return false
        }
            return true
    }
    func setUpDataSource(){
        if(self.arrNear?.count >= 0)
        {
            self.arrNearDS = self.arrNear!
        }
        if(self.arrayOther?.count >= 0)
        {
            self.arrayOtherDS = self.arrayOther!
        }
        self.tblView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.arrNear!.count == 0 && self.arrayOther!.count ==  0)
        {
            
            addNodata()
            return 0
        }
        
        if(self.arrNearDS == nil || self.arrNearDS.count == 0)
        {
        return 1
        }
        else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.arrNearDS.count == 0 && section == 0)
        {
        return self.arrayOtherDS.count
        }
        else{
              if(section == 0)
              {
                return self.arrNearDS.count
            }
              else{
                return self.arrayOtherDS.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: STRLocationTableViewCell = self.tblView.dequeueReusableCell(withIdentifier: "STRLocationTableViewCell") as! STRLocationTableViewCell
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        
        var dict : Dictionary<String,AnyObject>?
        if(self.arrNearDS.count == 0 && indexPath.section == 0)
        {
           dict = self.arrayOtherDS[indexPath.row]
        }
        else{
            if(indexPath.section == 0)
            {
                dict = self.arrNearDS[indexPath.row]

            }
            else{
                dict = self.arrayOtherDS[indexPath.row]
            }
        }
        if(dict!["locationId"] as? String  == self.idCurrent)
        {
            cell.imageViewTick.isHidden = false
        }
        else{
            cell.imageViewTick.isHidden = true
        }
        cell.lblLocationName.text = "\(dict!["locationId"]!)"
        cell.lblLocationAddress.text = dict!["address"] as? String
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dict : Dictionary<String,AnyObject>?
        if(self.arrNearDS.count == 0 && indexPath.section == 0)
        {
            dict = self.arrayOtherDS[indexPath.row]
        }
        else{
            if(indexPath.section == 0)
            {
                dict = self.arrNearDS[indexPath.row]
                
            }
            else{
                dict = self.arrayOtherDS[indexPath.row]
            }
        }
        utility.setselectedLocation(dict!)
        self.delegate?.setSelectedLocationInfo(locationInfo: dict!)
        self.dismiss(animated: true) { 
            
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(self.arrNearDS.count > 0)
        {
        let   title = self.arraySectionHeadr[section]
        let vw = STRReportIssueSectionHeader.sectionView(title)
        vw.frame =  CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        vw.backgroundColor = UIColor(colorLiteralRed: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1.0)
        return vw
        }
        else{
            return nil
        }

    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(self.arrNearDS.count == 0)
        {
        return 0
        }
        else{
          return   30
        }
    }
    func addNodata(){
        let noData = Bundle.main.loadNibNamed("STRNoDataFound", owner: nil, options: nil)!.last as! STRNoDataFound
        noData.tag = 10002
        self.view.addSubview(noData)
        noData.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vwSegemntNew]-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData,"vwSegemntNew":self.vwSegemntNew]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
    }
    func removeNodata(){
        for view in self.view.subviews{
            if(view.tag == 10002)
            {
                view.removeFromSuperview()
            }
            self.view.viewWithTag(10002)?.removeFromSuperview()
        }

    }

   
}
