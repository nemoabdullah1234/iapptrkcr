import UIKit

class STRSearchTableViewController: UITableViewController,ZBarReaderDelegate {
        let searchController = UISearchController(searchResultsController: nil)
    var option = 0
    var dataList = [[String:AnyObject]]()
    var tblDataSource = [[String:AnyObject]]()
    
    
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden=false
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
       
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true;
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["Shipments", "Notifications", "Items", "📷"]
        tableView.tableHeaderView = searchController.searchBar
        tableView.tableFooterView  = UIView()
        self.extendedLayoutIncludesOpaqueBars = true
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tblDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "globalSearch")
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "globalSearch")
        }
        cell!.textLabel!.text = self.tblDataSource[indexPath.row]["l1"] as? String
        cell!.detailTextLabel!.text = self.tblDataSource[indexPath.row]["l2"] as? String
        cell!.detailTextLabel?.textColor = UIColor.darkGray
        return cell!
    }
    

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            }
    
    func dataFeeding() -> () {
        let api = GeneralAPI()
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        
        api.hitApiwith(["query":self.searchController.searchBar.text! as AnyObject], serviceType: .strApiGlobalSearch, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerSearchShipmentsResponse = data["readerSearchShipmentsResponse"] as? [[String:AnyObject]] else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.dataList = readerSearchShipmentsResponse
                self.tblDataSource.removeAll()
                for dict in readerSearchShipmentsResponse{
                    if dict["type"]!.intValue == self.option{
                        self.tblDataSource.append(dict)
                }
                }
                self.view.viewWithTag(101)?.removeFromSuperview()
                if self.tblDataSource.count == 0{
                    self.addNoData()
                }
                
                    self.tableView.reloadData()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }) { (error) in
            
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
                    self.tableView.reloadData()
                    self.searchController.searchBar.text = "\(symbl.data)"
                    self.dataFeeding()
        })
    }
    
    func addNoData(){
      let lbl = UILabel(frame: CGRect(x: 0,y: 80, width: self.tableView.frame.size.width, height: 44))
      lbl.tag=101
        
      lbl.text="No Data"
        
      lbl.textAlignment = NSTextAlignment.center
        
       self.view.addSubview(lbl)
    }
    
    
}
extension STRSearchTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if(selectedScope == 3)
        {
            let codeReader = ZBarReaderViewController()
                      let infoBtn = codeReader.view.subviews[2].subviews[0].subviews[3]
            infoBtn.isHidden=true
            codeReader.readerDelegate=self;
            let scanner = codeReader.scanner;
            scanner?.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
            self.navigationController?.present(codeReader, animated: true, completion: { 
                            })
        }
        if(selectedScope == 0)
        {
            option = 0

            self.tblDataSource.removeAll()
            for dict in dataList{
                if dict["type"]!.int32Value == 0{
                    self.tblDataSource.append(dict)
                }
            }
         self.tableView.reloadData()
        }
        if(selectedScope == 1)
        {
            option = 2
             self.tblDataSource.removeAll()
            for dict in dataList{
                if dict["type"]!.int32Value == 2{
                    self.tblDataSource.append(dict)
                }
            }
            self.tableView.reloadData()

        }

        if(selectedScope == 2)
        {
            option = 1

             self.tblDataSource.removeAll()
            for dict in dataList{
                if dict["type"]!.int32Value == 1{
                    self.tblDataSource.append(dict)
                }
            }
            self.tableView.reloadData()

        }
        self.view.viewWithTag(101)?.removeFromSuperview()
        if self.tblDataSource.count == 0{
            self.addNoData()
        }
        
    }

    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
          UIApplication.shared.setStatusBarHidden(true, with: .fade)
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
       self.dataFeeding()
    }
    
    
    
    
    
}



extension STRSearchTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    }
}
