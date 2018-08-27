import UIKit

class STRAboutViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet var lblVersion: UILabel!

    @IBOutlet var myWebView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.title = TitleName.About.rawValue
        customizeNavigationforAll(self)
        self.navigationController?.navigationBar.isTranslucent = false

        let url = URL (string: Kbase_url_front+"/aboutus");
        let requestObj = URLRequest(url: url!);
        myWebView!.delegate = self;
        myWebView!.loadRequest(requestObj);
        
        self.revealViewController().panGestureRecognizer().isEnabled = false
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
                //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        // Do any additional setup after loading the view.
        var buildType = "P"
        if(APIStage.contains("qc"))
        {
            buildType = "Q"
        }
        
        self.lblVersion.text = "V" + version + buildType + "Code :" + (((utility.getDevice()) != nil) ? utility.getDevice()!:"")
        setFont()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        
    }
    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    func toggleSideMenu(_ sender: AnyObject) {
        
        self.revealViewController().revealToggle(animated: true)
        
    }

    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
    
    func setFont(){
        self.lblVersion.font = UIFont(name: "SourceSansPro-Regular", size: 12.0);
    }

}
