import UIKit

protocol STRNoDataFoundDelegate:class {
    func retryPressed()
}


class STRNoDataFound: UIView {

    
   weak  var delegate: STRNoDataFoundDelegate?
    
    
    @IBOutlet var imgNoData: UIImageView!
    @IBAction func btnRetry(_ sender: AnyObject) {
        if(self.delegate != nil)
        {
            self.delegate?.retryPressed();
        }
        
    } 
    
    @IBOutlet var btnRetry: UIButton!
    
    
    @IBOutlet var lblNodata: UILabel!
    override func awakeFromNib() {
        lblNodata.font = UIFont(name: "SourceSansPro-Regular", size: 22.0)
        btnRetry.titleLabel?.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0);

    }
    func showViewRetry(){
        self.imgNoData.image = UIImage(named: "iconretry")
    }
}
