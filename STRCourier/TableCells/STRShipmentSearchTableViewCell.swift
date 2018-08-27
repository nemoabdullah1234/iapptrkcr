import UIKit

class STRShipmentSearchTableViewCell: UITableViewCell {
    @IBOutlet var imgTag: UIImageView!
    @IBOutlet var imgReport: UIImageView!
    @IBOutlet var lbl1: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var lblStatus: UILabel!
    @IBOutlet var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupFont()
    }
    
    func setupFont(){
        lbl1.font = UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        lbl2.font =  UIFont(name: "SourceSansPro-Regular", size: 17.0);
        lblDate.font = UIFont(name: "SourceSansPro-Regular", size: 13.0);
        lblStatus.font = UIFont(name: "SourceSansPro-Semibold", size: 12.0);
    }
    
    func setUpCell(_ dict:Dictionary<String,AnyObject>?){
        
        lbl1.text = dict!["l1"] as? String
        lbl2.text = dict!["h1"] as? String
        let status = dict!["shipStatus"] as? NSInteger
        switch status! {
        case 10:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "newbackground")
            break
        case 20:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "tapdeliverd")
            break
        case 25:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "iconpartial")
            break
        case 30:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "searchintransit")
            break
        case 40:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "searchintransit")
            break
        case 45:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "iconbnddelivered")
            break
        case 50:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "searchdelivered")
            break
        case 60:
            lblDate.text = dict!["l3"] as? String
            imgTag.image = UIImage.init(named: "searchdelivered")
            break
        default:
            break
        }
        lblStatus.text = dict!["l2"] as? String
        
        if(dict!["isReported"] as? NSInteger == 0){
            imgReport.isHidden = true
        }
        else{
            imgReport.isHidden = false
        }
    }
    
        override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
