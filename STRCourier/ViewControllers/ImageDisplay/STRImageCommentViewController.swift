import UIKit

class STRImageCommentViewController: UIViewController {
    
    var closure:((String)->())?
    @IBOutlet var bottomLayOut: NSLayoutConstraint!
    @IBOutlet var txtComment: UITextField!
    @IBOutlet var imgSelected: UIImageView!
    
    @IBOutlet var scrlView: UIScrollView!
    var textComment :String?
    var image : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardNotifications()
        self.txtComment.text = textComment
        self.imgSelected.image = image
        self.scrlView.zoomScale = 1
        setUpNaveBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
    }
    func setUpNaveBar(){
        let button: UIButton = UIButton.init()
        
        button.setImage(nil, for: UIControlState())
        button.setTitle("Done", for: UIControlState())
        button.addTarget(self, action: #selector(STRImageCommentViewController.done), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
    }
    
    func done(){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnSend(_ sender: AnyObject) {
        if(self.closure != nil)
        {
            self.closure!(txtComment.text!)
        }
        self.dismiss(animated: false) { 
            
        }
    }

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(STRReportIssueViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(STRReportIssueViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.bottomLayOut.constant = keyboardFrame.size.height
            
        }, completion: { (completed: Bool) -> Void in
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.bottomLayOut.constant = 0.0
        }, completion: { (completed: Bool) -> Void in

        
        }) 
    }
    //MARK: textField delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
    }
}
