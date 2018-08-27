import UIKit

class STRInventorySectionHeaderView: UIView {

    @IBOutlet var lblSectionTitle: UILabel!
    
    @IBOutlet var lblAll: UILabel!
    
    @IBOutlet var lblFound: UILabel!
    
    @IBOutlet var lblMissing: UILabel!
    
    @IBOutlet var vwSideColor: UIView!
    @IBOutlet var imgClose: UIImageView!
    
    @IBAction func btnSectionHeader(_ sender: AnyObject) {
        if(self.block_sectionClicked != nil)
        {
            stateOpen = !stateOpen
            stateOpen ? (imgClose.image = UIImage(named: "arrowopen")):(imgClose.image = UIImage(named: "arrowclose"))

            self.block_sectionClicked!(self.section!)
            
        }
    }
    var stateOpen = false
    var block_sectionClicked: ((Int)->())?
    var zonne_obj :Dictionary<String,AnyObject>?
    var product: [Dictionary<String,AnyObject>]?
    var section: Int?
    override func awakeFromNib() {
        setUpFont()
    }
    
    func setUpFont(){
        self.lblSectionTitle.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0)
        self.lblAll.font = UIFont(name: "SourceSansPro-Regular", size: 16.0)
        self.lblFound.font =  UIFont(name: "SourceSansPro-Regular", size: 16.0)
        self.lblMissing.font =  UIFont(name: "SourceSansPro-Regular", size: 16.0)
    }
    func setCount(){
        var found  = 0
        var notFound = 0
        for (_, dic) in self.product!.enumerated() {
            if (dic["status"] as! NSInteger == STRInventoryStatus.strInventoryStatusFound.rawValue) {
                found = found + 1
                
            }
        }
        for (_, dic) in self.product!.enumerated() {
      if (dic["status"] as! NSInteger != STRInventoryStatus.strInventoryStatusFound.rawValue) {
                notFound = notFound + 1
                
            }
        }
        if(self.product!.count == 0)
        {
            self.vwSideColor.backgroundColor = UIColor.white
        }
        else if(notFound == 0 && found == 0)
        {
             self.vwSideColor.backgroundColor = UIColor(red: CGFloat(198/255.0),green: CGFloat(227/255.0),blue: CGFloat(201/255.0),alpha: CGFloat(1.0))
        }
        else{
             self.vwSideColor.backgroundColor = UIColor(red: CGFloat(241/255.0),green: CGFloat(194/255.0),blue: CGFloat(194/255.0),alpha: CGFloat(1.0))
        }
        lblFound.text = "Nearby : \(found)"
        lblAll.text = "All : \(self.product!.count)"
    }
    
    func setUpTitle(_ dict: Dictionary<String,AnyObject>,section: Int){
        self.zonne_obj = dict
        self.section = section
        if (dict["floorValue"] as? Bool == true) {
            lblSectionTitle.text = dict["name"] as? String
            imgClose.isHidden = true;
            return
        }
        self.product = dict["productList"] as? [Dictionary<String,AnyObject>]
        lblSectionTitle.text = dict["name"] as? String
        
        if( dict["is_expanded"] as? Bool == false){
            stateOpen = false
            imgClose.image = UIImage(named: "arrowclose")
        }
        else{
            stateOpen = true
            imgClose.image = UIImage(named: "arrowopen")
        }

        
        setCount()
    
    }
    static func sectionView(_ dict: Dictionary<String,AnyObject>,section: Int)->STRInventorySectionHeaderView{
        let vw = Bundle.main.loadNibNamed("STRInventorySectionHeaderView", owner: nil, options: nil)!.last as! STRInventorySectionHeaderView
        vw.setUpTitle(dict,section: section)
        return vw
    }
    
}
