import UIKit
import Crashlytics
enum SearchType: Int{
    case voice = 0
    case text
    case barCode
    case recent
}

class STRSearchViewController: UIViewController,ZBarReaderDelegate {
    @IBAction func btnBarCode(_ sender: AnyObject) {
        searcType = .barCode

        let codeReader = ZBarReaderViewController()
        codeReader.readerDelegate=self;
        let scanner = codeReader.scanner;
        scanner?.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        self.navigationController?.present(codeReader, animated: true, completion: {
        })

    }
    
    @IBOutlet weak var microphoneButton: UIButton!
 
    @IBOutlet var btnBarCode: UIButton!
    @IBAction func btnBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet var txtSearch: UITextField!
    @IBOutlet var vwWhiteBase: UIView!
     @IBOutlet var vwSegment: STRSearchSegment!
     @IBOutlet var tblSearch: UITableView!
    var option = 0
    var dataList = [[String:AnyObject]]()
    var tblDataSource = [[String:AnyObject]]()
    var suggestedArray = [String]()
    @IBOutlet var tblSuggestion: UITableView!
    
    var index:NSInteger?
    var searcType: SearchType?
 
    @IBAction func microPhoneTap(_ sender: Any) {
        
        
        let vc =  VoiceViewController(nibName: "VoiceViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let  arr = UserDefaults.standard.object(forKey: "STRSEARCHSUGGESTION") as? [String]
        if (arr != nil)
        {
        for (_,str) in (arr?.enumerated())!{
            self.suggestedArray.append(str)
         }
        }
        
        self.vwSegment.blockSegmentButtonClicked = {(segment) in
        self.changeDataSource(segment)
        }
        let nib = UINib(nibName: "STRItemSearchCellTableViewCell", bundle: nil)
        tblSearch.register(nib, forCellReuseIdentifier: "STRItemSearchCellTableViewCell")
        let nib2 = UINib(nibName: "STRShipmentSearchTableViewCell", bundle: nil)
        tblSearch.register(nib2, forCellReuseIdentifier: "STRShipmentSearchTableViewCell")
        tblSearch.rowHeight = UITableViewAutomaticDimension
         let nib3 = UINib(nibName: "STRSuggestedTableViewCell", bundle: nil)
        tblSearch.estimatedRowHeight = 60
        tblSuggestion.register(nib3, forCellReuseIdentifier: "STRSuggestedTableViewCell")
        tblSearch.rowHeight = UITableViewAutomaticDimension
        tblSearch.estimatedRowHeight = 40
        self.vwWhiteBase.layer.cornerRadius = 4.0
        self.vwSegment.setSegment(0)
        
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        UserDefaults.standard.set(self.suggestedArray, forKey: "STRSEARCHSUGGESTION")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView ==  self.tblSearch)
        {
            if(self.tblDataSource.count == 0 && self.suggestedArray.count==0)
            {
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

            return self.tblDataSource.count
        }
        else
        {
            if(self.tblDataSource.count == 0 && self.suggestedArray.count==0)
            {
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


            return suggestedArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        if(tableView == self.tblSuggestion)
        {
            let cell: STRSuggestedTableViewCell = self.tblSuggestion.dequeueReusableCell(withIdentifier: "STRSuggestedTableViewCell") as! STRSuggestedTableViewCell
            cell.setUpCell(self.suggestedArray[indexPath.row])
            cell.selectionStyle =  UITableViewCellSelectionStyle.none

            return cell
        }
        if(self.option == 1)
        {
        let cell: STRItemSearchCellTableViewCell = self.tblSearch.dequeueReusableCell(withIdentifier: "STRItemSearchCellTableViewCell") as! STRItemSearchCellTableViewCell
        cell.setUpCellData(self.tblDataSource[indexPath.row], indexPath: indexPath)
            cell.selectionStyle =  UITableViewCellSelectionStyle.none

        return cell
        }
        else
        {
         let cell: STRShipmentSearchTableViewCell = self.tblSearch.dequeueReusableCell(withIdentifier: "STRShipmentSearchTableViewCell") as! STRShipmentSearchTableViewCell
            cell.setUpCell(self.tblDataSource[indexPath.row] as? [String : AnyObject])
              cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if(tableView == self.tblSuggestion)
        {
            searcType = .recent
            self.txtSearch.text = self.suggestedArray[indexPath.row];
            self.dataFeeding()
            self.view.endEditing(true)
        }
        else
        {
            if(self.option == 1)
            {
                let infoDictionary = self.tblDataSource[indexPath.row] as? [String : AnyObject]
                let vw = STRInventoryListViewController(nibName: "STRInventoryListViewController", bundle: nil)
                vw.skuId =  String(infoDictionary!["params"]!["skuId"]! as! String);
                vw.locationName = String(infoDictionary!["l3"]! as! String)
                vw.titleString = String(infoDictionary!["params"]!["caseNo"]! as! String)
                vw.idValue = String(infoDictionary!["params"]!["skuId"]! as! String);
                vw.flagToShowEdit = true
                self.navigationController?.pushViewController(vw, animated: true)
                

                
            }else{

            
             let infoDictionary = self.tblDataSource[indexPath.row] as? [String : AnyObject]
            let vc =  STRDetailSliderViewController(nibName: "STRDetailSliderViewController", bundle: nil)
            vc.caseNo =  String(infoDictionary!["params"]!["caseNo"]! as! String);
            vc.shipmentNo =  String(infoDictionary!["params"]!["shipmentNo"]! as! String);
             vc.shipmentid =  String(infoDictionary!["params"]!["shipmentNo"]! as! String);
            self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField .resignFirstResponder()
        let str  = txtSearch.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if(str?.characters.count != 0)
        {
        searcType = .text

        dataFeeding()
        }
        return true
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(tableView == self.tblSuggestion)
        {
        let vw = STRReportIssueSectionHeader.sectionView("Recent")
        vw.frame =  CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        vw.backgroundColor = UIColor(colorLiteralRed: 228/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1.0)
        return vw
        }
        else{
            let vw = UIView(frame:CGRect.zero)
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if(tableView == self.tblSuggestion)
        {
            return 44
        }
            
        else{
            return 0
        }
        
    }

    //MARK: search api calls
    func dataFeeding() -> () {
        addString(self.txtSearch.text!)
        let api = GeneralAPI()
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        
        api.hitApiwith(["query":self.txtSearch.text! as AnyObject], serviceType: .strApiGlobalSearch, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    self.searcScreenLog(false)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerSearchShipmentsResponse = data["readerSearchShipmentsResponse"] as? [[String:AnyObject]] else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    self.searcScreenLog(false)
                    return
                }
                self.searcScreenLog(true)
                self.dataList = readerSearchShipmentsResponse
                self.tblDataSource.removeAll()
                for dict in readerSearchShipmentsResponse{
                    if dict["type"]!.intValue == self.option{
                        self.tblDataSource.append(dict)
                    }
                }
                for view in self.view.subviews{
                    if(view.tag == 10002)
                    {
                        view.removeFromSuperview()
                    }
                    self.view.viewWithTag(10002)?.removeFromSuperview()
                }

                if self.tblDataSource.count == 0{
                }
                self.hideSuggestedTable()
                self.tblSearch.reloadData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }) { (error) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
        
    }

    func changeDataSource(_ type:NSInteger)
    {
        if(type == 0)
        {
            option = 0
            
            self.tblDataSource.removeAll()
            for dict in dataList{
                if dict["type"]!.int32Value == 0{
                    self.tblDataSource.append(dict)
                }
            }
            self.tblSearch.reloadData()
        }
        if(type == 1)
        {
            option = 1
            self.tblDataSource.removeAll()
            for dict in dataList{
                if dict["type"]!.int32Value == 1{
                    self.tblDataSource.append(dict)
                }
            }
            self.tblSearch.reloadData()
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let results: ZBarSymbolSet = info[ZBarReaderControllerResults] as! ZBarSymbolSet
        var symbl=ZBarSymbol()
        for symbol in results{
            symbl = symbol as! ZBarSymbol
            break
        }
        print(symbl.data)
        
        picker.dismiss(animated: true, completion: {
            self.tblDataSource.removeAll()
            self.tblSearch.reloadData()
            self.txtSearch.text = "\(symbl.data)"
            self.dataFeeding()
        })
    }
    
    func addString(_ text:String){
        if(suggestedArray.contains(text) || suggestedArray.count == 10)
        {
            return
        }
        else{
            self.suggestedArray.append(text)
        }
    }
    func showSuggestedTable(){
        self.tblSuggestion.isHidden = false
    }
    func hideSuggestedTable(){
        self.tblSuggestion.isHidden = true
    }
    func addNodata(){
        let noData = Bundle.main.loadNibNamed("STRNoDataFound", owner: nil, options: nil)!.last as! STRNoDataFound
        noData.tag = 10002
        self.view.addSubview(noData)
        noData.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[vwSegment]-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData,"vwSegment":self.vwSegment]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
    }
    
    
    /*Fabric event loging*/
    func searcScreenLog(_ success:Bool){
        var tab:String?
        var recent:String?
        var barcode:String?
        var voice:String?
        var text:String?
        var didSuceed:String?
        switch searcType! {
        case .text:
            recent = "NO"
            barcode = "NO"
            voice = "NO"
            text = "YES"
            break
        case .voice:
            recent = "NO"
            barcode = "NO"
            voice = "YES"
            text = "NO"
            break
        case .barCode:
            recent = "NO"
            barcode = "YES"
            voice = "NO"
            text = "NO"
            break
        case .recent:
            recent = "YES"
            barcode = "NO"
            voice = "NO"
            text = "NO"
            break
        }
        if success{
            didSuceed = "YES"
        }
        else{
            didSuceed = "NO"
        }
        if(self.option == 0)
        {
            tab = "Shipment"
        }
        else{
            tab = "Product"
        }
        
    Answers.logCustomEvent(withName: "SEARCH SCREEN", customAttributes: ["recent":recent!,
           "barcode":barcode!,"voice":voice!,"text":text!,"search string": txtSearch.text!,"tab":tab!,"success":didSuceed!])
    }
    
}
extension ZBarSymbolSet: Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}

