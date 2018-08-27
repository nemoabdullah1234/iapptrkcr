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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class STRInventoryListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet var IconWidth: NSLayoutConstraint!
    @IBOutlet var btnImage: UIButton!
    @IBOutlet var vwEditButton: UIView!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var tblviewBottomLayout: NSLayoutConstraint!
    @IBOutlet var imgEdit: UIImageView!
    @IBOutlet var btnEdit: UIButton!
    
    @IBAction func btnImage(_ sender: AnyObject) {
        if(imageUrl != nil)
        {
            self.presentWithImageURL(imageUrl)
        }
    }

    @IBAction func btnEdit(_ sender: AnyObject) {
         self.view.endEditing(true)
        if(btnEdit.tag == 0)
        {
        self.editMode = true
        self.tblList.reloadData()
        btnEdit.tag = 1
            self.imgEdit.image = UIImage.init(named: "iconsaveitem")
        }
        else{
            if(validate())
            {
            btnEdit.tag = 0
                self.imgEdit.image = UIImage.init(named: "iconedititem");

            dataSave()
            }
            else{
                return
            }
        }
    }
    var imageUrl: String?
    var locationName: String?
    var titleString: String?
    var skuId: String?
    var idValue : String?
    var flagToShowEdit: Bool = false
    var sourceScreen: STRItemDetail?

    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var lbl1: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var lbl3: UILabel!
    @IBOutlet var tblList: UITableView!
    var editMode: Bool?
    var productDetails = Dictionary<String,AnyObject>()
    var itemList =  [Dictionary<String,AnyObject>]()
    var editedData = [Dictionary<String,AnyObject>]()
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeNavigationforAll(self)
        setUpFont()
        self.editMode = false
         self.vwEditButton.isHidden = self.flagToShowEdit
        
            self.vwEditButton.isHidden = true
            self.dataFeeding()

        let nib = UINib(nibName: "STRInventoryDetailTableViewCell", bundle: nil)
        self.tblList.register(nib, forCellReuseIdentifier: "STRInventoryDetailTableViewCell")
        self.dataFeeding()
        addKeyboardNotifications()
       
        let vw = STRNavigationTitle.setTitle("Inventory Details", subheading: self.locationName!)
        
        vw.frame = CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.frame.size.width)!, height: (self.navigationController?.navigationBar.frame.size.height)!)
        
        self.navigationItem.titleView = vw

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0, animations: { () -> Void in
            self.tblviewBottomLayout.constant = keyboardFrame.size.height
        }, completion: { (completed: Bool) -> Void in
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0, animations: { () -> Void in
            self.tblviewBottomLayout.constant = 0.0
        }, completion: { (completed: Bool) -> Void in
            
        }) 
    }

    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }
    func backToDashbaord(_ sender: AnyObject) {
       self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.itemList.count == 0 {
            return 0
        }
        for view in self.view.subviews{
            if view.tag == 10002 {
                view.removeFromSuperview()
            }
        }
        return self.itemList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: STRInventoryDetailTableViewCell = self.tblList.dequeueReusableCell(withIdentifier: "STRInventoryDetailTableViewCell") as! STRInventoryDetailTableViewCell
        cell.selectionStyle =  UITableViewCellSelectionStyle.none
        
       cell.setUpCellData(self.itemList[indexPath.row], indexPath: indexPath, editMode: self.editMode!)
        cell.blockTextFeild = {(indexPath) in
            self.tblList.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true);
        }
        cell.blockTextFeildData = { (data,index) in
        var dict = self.itemList[index.row]
            self.editedData.append(["quantity":data as AnyObject,"productId":dict["productId"] as! NSInteger as AnyObject,"skuId":dict["skuId"] as! NSInteger as AnyObject])
        dict["newQuantity"] = data as AnyObject
        self.itemList[index.row] = dict
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
    func dataFeeding(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["skuId": self.idValue! as AnyObject], serviceType: .strApiGetInventoryItemDetails, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let readerGetItemInventoryResponse = data["readerGetCaseItemQuantityResponse"] as? Dictionary<String,AnyObject>,let productDetails = readerGetItemInventoryResponse["productDetails"] as? Dictionary<String,AnyObject>, let items = readerGetItemInventoryResponse["items"] as? [Dictionary<String,AnyObject>] else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                self.productDetails.removeAll()
                self.itemList.removeAll()
                self.productDetails =  productDetails
                self.itemList.append(contentsOf: items)
                self.setUpData()
                self.addNodata()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
            
        }
    }
    func dataSave(){
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        let generalApiobj = GeneralAPI()
        generalApiobj.hitApiwith(["items":self.editedData as AnyObject], serviceType: .strApiUpdateItemInventory, success: { (response) in
            DispatchQueue.main.async {
                print(response)
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                guard let data = response["data"] as? [String:AnyObject],let _ = data["ReaderUpdateItemInventoryResponse"] as? Dictionary<String,AnyObject> else{
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                    return
                }
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue ,view: self)
                self.editMode = false
                self.btnEdit.tag = 0
                self.editedData.removeAll()
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.dataFeeding()
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                NSLog(" %@", err)
            }
            
        }
    }

    func setUpData(){
        self.tblList.reloadData()
        self.lbl1.text =  self.productDetails["code"] as? String
        self.lbl2.text = self.productDetails["name"] as? String
        self.lbl3.text = self.productDetails["category"] as? String
        let arr = self.productDetails["images"] as? [AnyObject]
        if(arr != nil && arr?.count > 0)
        {
        let dict = arr!.first as? Dictionary<String,String>
        if(dict != nil)
        {
         let img = dict!["thumb"]
         self.imageUrl = dict!["full"]
        let url = URL(string: img!)
         self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "iconnoimage"))
        }
        }
        let child = self.productDetails["haveChild"] as? Int
        if(child == 0)
        {
            self.imgEdit.image = UIImage(named: "editdisabled")
            self.btnEdit.isUserInteractionEnabled = false
        }
        
        self.tblList.reloadData()
    }
    
    func setUpFont(){
       self.lbl2.font =  UIFont.init(name: "SourceSansPro-Regular", size: 16.0)
        self.lbl1.font = UIFont.init(name: "SourceSansPro-Semibold", size: 18.0)
        self.lbl3.font = UIFont.init(name: "SourceSansPro-Regular", size: 16.0)
        self.imgProfile.layer.cornerRadius = 3
    }
    
    func validate()->(Bool){
         let rootViewController: UIViewController = UIApplication.shared.windows[0].rootViewController!
        if(editedData.count == 0)
        {
           utility.createAlert("", alertMessage: "Nothing to save", alertCancelTitle: "OK", view: rootViewController)
           return false
        }
        return true
    }
    func presentWithImageURL(_ url:String?){
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
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(119)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[noData]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["noData" : noData]))
    }

}
