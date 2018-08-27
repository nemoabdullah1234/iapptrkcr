import UIKit

class STRReportIssueSectionHeader: UIView {

    @IBOutlet var lblSectionTitle: UILabel!
   
    override func awakeFromNib() {
        setUpFont()
    }
    
    func setUpFont(){
        self.lblSectionTitle.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
    }
    
    func setUpTitle(_ title:String){
        lblSectionTitle.text = title
    }
    static func sectionView(_ title:String)->STRReportIssueSectionHeader{
        let vw = Bundle.main.loadNibNamed("STRReportIssueSectionHeader", owner: nil, options: nil)!.last as! STRReportIssueSectionHeader
        vw.setUpTitle(title)
        return vw
    }

}
