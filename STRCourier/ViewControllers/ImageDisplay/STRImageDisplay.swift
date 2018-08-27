import UIKit

class STRImageDisplay: UIView {
    var hideClouser : (()->())?
    @IBOutlet var imgChat: UIImageView!
    @IBAction func btnHide(_ sender: AnyObject) {
        
        if(self.hideClouser != nil)
        {
            self.hideClouser!()
        }
        
    }
    func setUpImage(_ image: String){
        self.imgChat.sd_setImage(with: URL(string: image))
        
    }
}
