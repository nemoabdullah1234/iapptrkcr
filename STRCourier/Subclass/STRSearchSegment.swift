import UIKit

class STRSearchSegment: UIView {
@IBOutlet var vwYello1: UIView!
@IBOutlet var vwYello3: UIView!
@IBOutlet var lblAll: UILabel!
@IBOutlet var lblAlert: UILabel!
@IBOutlet var imgAll: UIImageView!
@IBOutlet var imgAlert: UIImageView!
    var selectedSegment: NSInteger?
var blockSegmentButtonClicked: ((NSInteger)->())?
 override func awakeFromNib() {
    setUpFont()
    }
    func setUpFont(){
       lblAll.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
       lblAll.textColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        lblAlert.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        lblAlert.textColor = UIColor(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
       vwYello1.isHidden=false
       vwYello3.isHidden=true
       imgAll.image = UIImage(named: "iconshipmentoff")
       imgAlert.image = UIImage(named: "iconitemoff")
    }
    func  setSegment(_ segement:NSInteger){
        selectedSegment =  segement
        switch segement {
        case 0:
            lblAll.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
            lblAlert.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
            lblAll.textColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1.0)
            lblAlert.textColor = UIColor(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
            vwYello1.isHidden=false
            vwYello3.isHidden=true
            imgAll.image = UIImage(named: "iconshipmenton")
            imgAlert.image = UIImage(named: "iconitemoff")
            break;
        case 2:
            lblAll.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
            lblAlert.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
            lblAll.textColor = UIColor(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
            lblAlert.textColor = UIColor(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
            vwYello1.isHidden=true
            vwYello3.isHidden=true
            imgAll.image = UIImage(named: "iconshipmentoff")
            imgAlert.image = UIImage(named: "iconitemoff")
            break;
        case 1:
            lblAll.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
            lblAlert.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
            lblAll.textColor = UIColor(colorLiteralRed: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1.0)
            lblAlert.textColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            vwYello1.isHidden=true
            vwYello3.isHidden=false
            imgAll.image = UIImage(named: "iconshipmentoff")
            imgAlert.image = UIImage(named: "iconitemon")
            break;
        default:
            break;
        }

    }
    @IBAction func btnSection(_ sender: UIButton){
        self.setSegment(sender.tag)
        self.blockSegmentButtonClicked!(sender.tag)
    }
}
