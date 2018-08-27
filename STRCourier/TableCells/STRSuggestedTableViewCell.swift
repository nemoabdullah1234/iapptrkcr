import UIKit

class STRSuggestedTableViewCell: UITableViewCell {

    @IBOutlet var lblSuggestion: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setUpCell(_ text:String){
        self.lblSuggestion.text = text
         lblSuggestion.font =  UIFont(name: "SourceSansPro-Regular", size: 14.0)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
