import UIKit

class STRCaseDetailNewTableViewCell: UITableViewCell {
    @IBOutlet var lblCode: UILabel!
    @IBOutlet var lblItem: UILabel!
    @IBOutlet var imgIcon: UIImageView!
    @IBOutlet var imgStatus: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         setUpFont()
    }
  
    func setUpFont(){
         lblCode.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
         lblItem.font = UIFont(name: "SourceSansPro-Semibold", size: 18.0);
           }
    
    func setUpData(_ dict:Dictionary<String,AnyObject>,IndexPath index:NSInteger){
        lblCode.text = (dict["l1"] as? String)?.uppercased()
        lblItem.text = dict["l2"] as? String
        let itemStatus =  dict["status"] as! NSInteger
        self.imgStatus.isHidden = false
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
