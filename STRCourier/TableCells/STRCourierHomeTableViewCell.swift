import UIKit
enum STRCourierState:Int {
    case strCourierStateNew = 0
    case strCourierStateInTransit
    case strCourierStateDelivered
}
class STRCourierHomeTableViewCell: UITableViewCell {
    @IBOutlet var vwSideIndicator: UIView!
    
    @IBOutlet var imgSelected: UIImageView!
    @IBAction func btnSelected(_ sender: AnyObject) {
        
        if(self.blockSlected != nil)
        {
            self.blockSlected!(self.index!)
        }
    }
    
    @IBOutlet var btnSelected: UIButton!
    @IBOutlet var imgReport: UIImageView!
    
    @IBOutlet var lbl1: UILabel!
    
    @IBOutlet var lbl2: UILabel!
    
    @IBOutlet var layoutTrailing: NSLayoutConstraint!
    
    @IBOutlet var vwIntransit: UIView!
    
    @IBOutlet var lblStatus: UILabel!
    
    @IBOutlet var btnStart: UIButton!
    
    @IBOutlet var vwNew: UIView!
    
    @IBAction func btnNew(_ sender: AnyObject) {
        if(self.blockSTart != nil)
        {
            self.blockSTart!(self.index!)
        }
    }

    
    var index: IndexPath?
    var blockSlected:((IndexPath)->())?
    var blockSTart:((IndexPath)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpFont()
    }
    func setUpFont(){
        lbl1.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        lbl2.font = UIFont(name: "SourceSansPro-Regular", size: 13.0);
        lblStatus.font = UIFont(name: "SourceSansPro-Semibold", size:11)
        self.btnStart.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 10.0);
    }
    
    func setupCellData(_ dict:Dictionary<String,AnyObject>,index:IndexPath,expand:Bool,selected:Bool){
        self.index = index
        if(expand == true)
        {
            self.layoutTrailing.constant = 45
        }
        else{
             self.layoutTrailing.constant = 8
        }
        self.lbl1.text = dict["h1"] as? String
        self.lbl2.text = dict["h2"] as? String
        let status = dict["shipStatus"] as? Int
        switch  status!{
        case  10:
          self.vwNew.isHidden = false
          self.vwIntransit.isHidden = true
          self.lblStatus.text = ""
          self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 75/225.0, green: 76/225.0, blue: 133/225.0, alpha: 1)
          self.btnSelected.isEnabled = true
            break
            
        case  20:
            self.vwNew.isHidden = false
            self.vwIntransit.isHidden = true
            self.lblStatus.text = ""
            self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 75/225.0, green: 76/225.0, blue: 133/225.0, alpha: 1)
            self.btnSelected.isEnabled = true
            break
            
        case  300:
            self.vwNew.isHidden = false
            self.vwIntransit.isHidden = true
            self.lblStatus.text = ""
            self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 75/225.0, green: 76/225.0, blue: 133/225.0, alpha: 1)
            self.btnSelected.isEnabled = true
            break
            
        case  40:
            self.vwNew.isHidden = true
            self.vwIntransit.isHidden = false
            self.lblStatus.text = "IN TRANSIT"
            self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 116/225.0, green: 150/225.0, blue: 196/225.0, alpha: 1)
            self.btnSelected.isEnabled = false

         break
            
        case  50:
            self.vwNew.isHidden = true
            self.vwIntransit.isHidden = false
            self.lblStatus.text = "Soft Shipped"
            self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 116/225.0, green: 150/225.0, blue: 196/225.0, alpha: 1)
            self.btnSelected.isEnabled = false
            
            break
            
        case 60:
            self.vwNew.isHidden = true
            self.vwIntransit.isHidden = false
            self.lblStatus.text = "Delivered"
             self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 102/225.0, green: 180/225.0, blue:111/225.0, alpha: 1)
            self.btnSelected.isEnabled = false

          break
        case  20:
            self.vwNew.isHidden = false
            self.vwIntransit.isHidden = true
            self.lblStatus.text = ""
            self.vwSideIndicator.backgroundColor = UIColor(colorLiteralRed: 75/225.0, green: 76/225.0, blue: 133/225.0, alpha: 1)
            self.btnSelected.isEnabled = true
            break
        default:
            break
        }

        let isreported = dict["isReported"] as? NSInteger
        if(isreported == 0)
        {
            self.imgReport.isHidden = true
        }
        else{
            self.imgReport.isHidden = false
        }
        
        if(selected ==  true) {
            self.imgSelected.image = UIImage.init(named: "selected")
        }
        else
        {
            self.imgSelected.image = UIImage.init(named: "unselected")
        }
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
