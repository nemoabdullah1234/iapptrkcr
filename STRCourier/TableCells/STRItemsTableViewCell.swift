import UIKit

class STRItemsTableViewCell: UITableViewCell {

    @IBOutlet var lbl1: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var btnCheck: UIButton!
    @IBAction func btnCheck(_ sender: AnyObject) {
        }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFont()
    }
    
    func setFont(){
        self.lbl1.font =  UIFont(name: "SourceSansPro-Regular", size: 14.0)
        self.lbl2.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
