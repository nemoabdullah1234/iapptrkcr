import UIKit

class STRProfileImageView: UIImageView {

    var dict:String?
    
    func setUpImage(_ data:String){
        dict = data
        let url = URL(string: dict!)
         self.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultpro1"))
    }
    
}
