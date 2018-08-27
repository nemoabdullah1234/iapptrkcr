import UIKit
import SwiftSignatureView


struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}





class STRSignatureViewController: UIViewController{

    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    
    var blockGetImage:((UIImage)->())?
    var fullName:String?
    var phoneSTr:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signatureView.delegate = self
        fullNameLabel.text = fullName == " " ?  "Full Name" : fullName
        phoneNumberLabel.text = phoneSTr == "" ?  "Phone Number" : phoneSTr
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapClear() {
        signatureView.clear()
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Or to rotate and lock
        AppUtility.lockOrientation(.portrait, andRotateTo: .landscapeLeft)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    @IBAction func saveButtonPress(_ sender: UIButton) {
        if let signatureImage = self.signatureView.signature {
            // Saving signatureImage from the line above to the Photo Roll.
            // The first time you do this, the app asks for access to your pictures.
            
            if(self.blockGetImage != nil)
            {
                self.blockGetImage!(signatureImage)
            }
            
            
            UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            
            //On signature save pop the view controller
            self.dismiss(animated: true) { () -> Void in
                UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
            }
        }
    }
    @IBAction func backButtonPress(_ sender: UIButton) {
        self.dismiss(animated: true) { () -> Void in
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    func canRotate() -> Void {}
}
extension STRSignatureViewController : SwiftSignatureViewDelegate
{
    internal func swiftSignatureViewDidTapInside(_ view: SwiftSignatureView) {
        print("Did tap inside")
    }
    
    internal func swiftSignatureViewDidPanInside(_ view: SwiftSignatureView) {
        print("Did pan inside")
    }
}
