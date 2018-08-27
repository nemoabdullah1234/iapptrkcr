import UIKit

class STRHelpViewController: UIViewController , UIWebViewDelegate{

    @IBOutlet var myWebView: UIWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.title = TitleName.Help.rawValue
       customizeNavigationforAll(self)
        self.navigationController?.navigationBar.isTranslucent = false

        let url = URL (string: Kbase_url_front+"/faq");
        let requestObj = URLRequest(url: url!);
        myWebView!.delegate = self;
        myWebView!.loadRequest(requestObj);
        self.revealViewController().panGestureRecognizer().isEnabled = false
        // Do any additional setup after loading the view.
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

    

}
