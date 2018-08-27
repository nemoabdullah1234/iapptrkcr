import UIKit
import AKProximity

class STRDirectionMapViewController: UIViewController,UIWebViewDelegate {
    @IBOutlet var bottomSpace: NSLayoutConstraint!
    @IBOutlet var btnDirections: UIButton!
    @IBOutlet var btnWebView: UIWebView!
    @IBAction func btnDirections(_ sender: AnyObject) {

        let url : NSString = "http://maps.google.com/maps?saddr=\(BeaconHandler.sharedHandler.coordinate!.latitude),\(BeaconHandler.sharedHandler.coordinate!.longitude)&daddr=\(self.lat!),\(self.long!)" as NSString
    
    
        let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let searchURL : NSURL = NSURL(string: urlStr as String)!
        print(searchURL)
        
//
//        let pathURL: URL? = Foundation.URL(string: address)

        UIApplication.shared.openURL(searchURL as URL)
    }
    var URL:String?
    var shipmentNo:String?
    var status:String!
    var statusCode: NSInteger?
    var lat:String!
    var long:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavigationforBack(self)
        self.navigationItem.titleView = STRNavigationTitle.setTitle("\(self.shipmentNo!)", subheading: "\(status!)")
         setFont()
        if(URL != nil)
        {
            var str = URL
            let coordinate = BeaconHandler.sharedHandler.coordinate
            str = str!.appendingFormat("&latitude=\(coordinate?.latitude)&longitude=\(coordinate?.longitude)")
         self.btnWebView.loadRequest(URLRequest(url: Foundation.URL(string:str!.addingPercentEscapes(using: String.Encoding.utf8)!)!));//
        }
        
       if(self.statusCode == 3)
       {
        self.bottomSpace.constant = 0
       }
        else
       {
        self.bottomSpace.constant = 48
       }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

    }
    func setFont()
    {
        btnDirections.titleLabel!.font =  UIFont(name: "SourceSansPro-Semibold", size: 16.0);
    }
    
    func poptoPreviousScreen(){
        self.navigationController?.popViewController(animated: true)
    }
    func sortButtonClicked(_ sender:UIButton){
        let VW = STRSearchViewController(nibName: "STRSearchViewController", bundle: nil)
        self.navigationController?.pushViewController(VW, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "window.alert=null;")
    }
    

}
