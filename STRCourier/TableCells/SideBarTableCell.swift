import UIKit

class SideBarTableCell: UITableViewCell {
    @IBOutlet var imgName: UIImageView!
    @IBOutlet var lblName: UILabel!

    let img = ["completedcases","notifications","help","help","about","diagnostic","diagnostic","logout"]

    let imgSel = ["duebacksel","notificationsel","settingssel","helpsel","aboutsel","logoutsel"]
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
        setUpFont()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupCell(_ indexpath:IndexPath, selectedvalue isSelected:Bool, titleString: String)
    {
        if(isSelected)
        {
            self.lblName.text = titleString
            self.lblName.textColor = UIColor(red: CGFloat(252/255.0),green: CGFloat(180/255.0),blue: CGFloat(0/255.0),alpha: CGFloat(1.0))
              self.imgName.image = UIImage(named: imgSel[indexpath.row])
        }
        else{
            self.lblName.text = titleString
            self.lblName.textColor = UIColor(red: CGFloat(192/255.0),green: CGFloat(192/255.0),blue: CGFloat(192/255.0),alpha: CGFloat(1.0))
             self.imgName.image = UIImage(named: img[indexpath.row])
        }
    }
    func setUpFont(){
        lblName.font =  UIFont(name: "SourceSansPro-Regular", size: 18.0);
    }
}
