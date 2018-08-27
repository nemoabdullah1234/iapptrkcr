import UIKit

class STRLocationTableViewCell: UITableViewCell {
    @IBOutlet var lblLocationAddress: UILabel!

    @IBOutlet var lblLocationName: UILabel!
    @IBOutlet var imageViewTick: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setFont()
    }
    func setFont(){
        lblLocationName.font = UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        lblLocationAddress.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
    }
}
