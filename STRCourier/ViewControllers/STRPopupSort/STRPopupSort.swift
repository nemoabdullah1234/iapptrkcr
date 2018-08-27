import UIKit

class STRPopupSort: UIView,UITableViewDelegate,UITableViewDataSource {
    var sortData = ["ETD","case NO","Hospital","Doctor","Surgery Type","Surgery Date"]
    var sortDataCountry = [AnyObject]()
    
    var closure :((String)->())?
   var closureTable :((AnyObject)->())?
    var isCountryTable : Bool?
    @IBOutlet var tblViewHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        tblPopup.layer.cornerRadius = 5;
        tblPopup.layer.shadowOpacity = 0.8;
        tblPopup.layer.shadowOffset = CGSize(width: 0.0, height: 0.0);
    }
    
    
    @IBOutlet var tblPopup: UITableView!
    func setUpPopup(_ type:Int) {
        isCountryTable = false
        switch type {
        case 1:
            sortData = ["ETD","Case NO","Hospital","Doctor","Surgery Type","Surgery Date"]
            self.tblPopup.reloadData()
            self.tblViewHeight.constant=self.tblPopup.contentSize.height
            tblPopup.isScrollEnabled = false
            break;
        case 2:

            sortData = ["Edit Profile","Sign Out"]

            self.tblPopup.reloadData()
            tblPopup.isScrollEnabled = false
            self.tblViewHeight.constant=self.tblPopup.contentSize.height
            break;
        case 3:
            
            sortData = ["Ascending","Descending"]
            
            self.tblPopup.reloadData()
            tblPopup.isScrollEnabled = false
            self.tblViewHeight.constant=self.tblPopup.contentSize.height
            break;
            
        case 4:
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            let height = bounds.size.height
            
            tblPopup.frame = CGRect(x: 20, y: 70, width: width - 40, height: height - 140)
          
            isCountryTable = true
            self.tblPopup.reloadData()
            break;
            
        default:
            break
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCountryTable == true {
            return sortDataCountry.count
        }
        return sortData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        if isCountryTable == true {
        let infoDictionary = sortDataCountry[indexPath.row] as? [String : AnyObject]
            print(infoDictionary)
            cell!.textLabel?.text = infoDictionary!["countryName"] as? String
            cell?.imageView?.image=UIImage(named: "rbunselected")
            cell?.imageView?.frame=CGRect(x: 4, y: 4, width: 36, height: 36)
            cell?.imageView?.contentMode=UIViewContentMode.scaleAspectFit
            return cell!
       }
        let move = sortData[indexPath.row]
        
            cell!.textLabel!.text = move
               cell?.imageView?.image=UIImage(named: "rbunselected")
               cell?.imageView?.frame=CGRect(x: 4, y: 4, width: 36, height: 36)
               cell?.imageView?.contentMode=UIViewContentMode.scaleAspectFit
                return cell!
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isCountryTable == true {
            self.closureTable!((sortDataCountry[indexPath.row] as? [String : AnyObject])! as AnyObject)
        }else{
        self.closure!(sortData[indexPath.row])
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self .removeFromSuperview()
    }
    
    
}
