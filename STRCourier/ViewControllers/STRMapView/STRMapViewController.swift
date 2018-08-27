import UIKit
import AKProximity

class STRMapViewController: UIViewController {

    var titleSTring :String!
    @IBOutlet var webViewMap: UIWebView!
    
     var mapUrlStr :String!
     var mapData: Dictionary<String,AnyObject>?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        
       customizeNavigationforAll(self)
       self.title = titleSTring
        
        var str = mapUrlStr
        let coordinate = BeaconHandler.sharedHandler.coordinate
        str = str! + ("&latitude=\(coordinate!.latitude)&longitude=\(coordinate!.longitude)")
        self.webViewMap.loadRequest(URLRequest(url: URL(string:str!)!));
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        
    }
    
    func backToDashbaord(_ sender: AnyObject) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initSideBarMenu()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        let path = Bundle.main.path(forResource: "index", ofType:"html" , inDirectory: "HTML")
        let html = try! String(contentsOfFile: path!, encoding:String.Encoding.utf8)
        
        self.webViewMap.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        self.webViewMap.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func sortButtonClicked(_ sender : AnyObject){
        
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
        
    }

    

}
