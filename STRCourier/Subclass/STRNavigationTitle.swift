import UIKit

class STRNavigationTitle: UIView {
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: MarqueeLabel!
    static func setTitle(_ title:String ,subheading subTitle:String) -> STRNavigationTitle{
        let customTitle = Bundle.main.loadNibNamed("STRNavTitle", owner: nil, options: nil)!.last as! STRNavigationTitle
        customTitle.setfont()
        customTitle.lblTitle.text = title
        customTitle.lblSubTitle.text = subTitle
        return customTitle;
    }
    func setfont(){

        lblSubTitle.font = UIFont(name: "Roboto-Medium", size: 15.0);
        lblTitle.font = UIFont(name: "Roboto-Light", size: 12.0);

    }
    
}
