import UIKit

class STRCHomeTableViewCell: UITableViewCell {
    var closureRightButton:((IndexPath)->())?
    
    var indexPath:IndexPath?
    @IBOutlet var lblOne: UILabel!
    @IBOutlet var lblTwo: UILabel!
    @IBOutlet var lblThree: UILabel!
    
    @IBOutlet var btnLeft: UIButton!
    @IBOutlet var btnRight: UIButton!
       override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func btnRight(_ sender: AnyObject) {
        if(self.closureRightButton != nil && self.indexPath != nil)
        {
            self.closureRightButton!(indexPath!)
        }
    }
    
    @IBAction func btnLeft(_ sender: AnyObject) {
    }
    

}
