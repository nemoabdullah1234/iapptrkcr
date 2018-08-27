import UIKit
enum STRInventoryStatus: Int{
    case strInventoryStatusFound = 0
    case strInventoryStatusNotFound
    case strInventoryStatusDispute
    case strInventoryStatusNotBeacon
    case strInventoryStatusInitial
}
class STRInventoryTableViewCell: UITableViewCell {

    @IBOutlet var lbl1: UILabel!
    @IBOutlet var imgStatus: UIImageView!
    @IBOutlet var lbl2: UILabel!
    var indexPath: IndexPath?
    func setCellData(_ dict:Dictionary<String,AnyObject>,indexPath:(IndexPath))
    {
        self.indexPath = indexPath
        self.lbl1.text = dict["code"] as? String
        self.lbl2.text = dict["name"] as? String
        let itemStatus =  dict["status"] as! NSInteger
        self.imgStatus.isHidden = false
        switch  itemStatus{
        case STRInventoryStatus.strInventoryStatusFound.rawValue:
            self.imgStatus.image = UIImage(named:"iconitemverified")
            break
        case STRInventoryStatus.strInventoryStatusNotFound.rawValue:
            self.imgStatus.image = UIImage(named:"iconitemnotverified")
            break
        case STRInventoryStatus.strInventoryStatusDispute.rawValue:
            self.imgStatus.backgroundColor = UIColor.orange
            break
        case STRInventoryStatus.strInventoryStatusNotBeacon.rawValue:
            self.imgStatus.isHidden = true
            break
        case STRInventoryStatus.strInventoryStatusInitial.rawValue:
            
           self.imgStatus.image = UIImage(named:"iconinitial")
            break
        default:
            break
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFont()
    }
    func setFont(){
        
          self.lbl1.font =  UIFont(name: "SourceSansPro-Regular", size: 14.0);
        self.lbl2.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0);
    }
    
    
    
    
}
