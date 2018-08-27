import UIKit

class STRImageViewController: UIViewController ,UIScrollViewDelegate{
    var imageURL:String?
    @IBAction func btnDone(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var lblDone: UILabel!
    @IBOutlet var scrlView: UIScrollView!
    @IBOutlet var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupFont()
        self.navigationController?.navigationBar.isHidden = true
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        self.imgView.sd_setImage(with: URL(string: self.imageURL!)) { (img, error, id, url) in
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        }
        // Do any additional setup after loading the view.
    }
    func setupFont(){
        self.lblDone.font = UIFont(name: "SourceSansPro-Semibold", size: 16.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
}
