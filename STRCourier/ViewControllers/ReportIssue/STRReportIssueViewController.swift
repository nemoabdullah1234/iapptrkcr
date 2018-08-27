import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class STRReportIssueViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate {
    @IBOutlet var messageComposingView: UIView!
    @IBOutlet weak var messageCointainerScroll: UIScrollView!
    @IBOutlet weak var buttomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet var backView: UIView!
    var selectedImage : UIImage?
    var lastChatBubbleY: CGFloat = 10.0
    var internalPadding: CGFloat = 8.0
    var lastMessageType: BubbleDataType?
    var imagePicker = UIImagePickerController()
    var issueID:String!
    var skuid:String!
    
    @IBOutlet var dueBackView: UIView!
    @IBOutlet var trackView: UIView!
    @IBOutlet var lbll1: UILabel!
    
    @IBOutlet var lbll2: UILabel!
    
    @IBOutlet var lbll3: UILabel!
    
    @IBOutlet var lbll4: MarqueeLabel!
    
    @IBOutlet var imgImage: UIImageView!
    
    @IBOutlet var lblItem1: UILabel!
    
    @IBOutlet var lblItem2: UILabel!
    
    
    var shipmentNo:String!
    var caseNo:String!
    
    var caseDetails:Dictionary<String,AnyObject>?
    var arrayOfComments:Array<ChatBubbleData>?
    var imageComment: STRImageCommentViewController?
    
    var isfromCompleteCases: NSString?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        customNavigationforBack(self)
        self.title = TitleName.ReportIssue.rawValue
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        sendButton.isEnabled = false
        arrayOfComments=[ChatBubbleData]()
        
        self.addKeyboardNotifications()
        
        sendButton!.layer.cornerRadius = 5;
        
        
        backView!.layer.cornerRadius = 5;
        backView!.layer.borderWidth = 1
        backView!.layer.borderColor = UIColor.darkGray.cgColor
        setUpFont()
        if isfromCompleteCases == "1" {
            trackView.isHidden = false
            dueBackView.isHidden = true
            self.dataFeedingItemComment()
            messageComposingView .isHidden = true
        }else if isfromCompleteCases == "2"{
             trackView.isHidden = true
            dueBackView.isHidden = false
            self.dataFeedingItemComment()
        }else{
             self.dataFeeding()
            trackView.isHidden = false
             dueBackView.isHidden = true
             messageComposingView .isHidden = false
        }
        
        
        }
    func poptoPreviousScreen()->(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.messageCointainerScroll.contentSize = CGSize(width: self.view.frame.width, height: lastChatBubbleY + internalPadding)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(STRReportIssueViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(STRReportIssueViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    
    // MARK:- Notification
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = keyboardFrame.size.height
            
        }, completion: { (completed: Bool) -> Void in
            self.moveToLastMessage()
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.buttomLayoutConstraint.constant = 0.0
        }, completion: { (completed: Bool) -> Void in
            self.moveToLastMessage()
        }) 
    }
    
    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        
        if isfromCompleteCases == "2" {
            self.postCommentforItem()
        }else{
            self.postComment()
        }
        
       
         textField.resignFirstResponder()
    }
    
    @IBAction func cameraButtonClicked(_ sender: AnyObject) {
        
        self.textField.resignFirstResponder()
        
        let actionSheetTitle = "Images"
        let imageClicked = "Take Photo";
        let ImageGallery = "Select Photo";
        let  cancelTitle = "Cancel Button";
        let actionSheet = UIActionSheet(title: actionSheetTitle, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil, otherButtonTitles:imageClicked , ImageGallery)
        actionSheet.show(in: self.view)
       
    }
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if(buttonIndex == 1)
        {
            imagePicker.sourceType = .camera
              self.perform(#selector(presentv), with: nil, afterDelay: 0)
        }
        else if(buttonIndex == 2)
        {
            imagePicker.sourceType = .photoLibrary
              self.perform(#selector(presentv), with: nil, afterDelay: 0)
        }
    }
    
    func presentv(){
        self.present(imagePicker, animated: true, completion: {
            Void in
        })
    }

    func addRandomTypeChatBubble() {
        let bubbleData = ChatBubbleData(text: textField.text,image: selectedImage,  date: getDateString(Date()),name:utility.getUserLastName(), type: .mine,imagePath:selectedImage != nil ? " " : nil,full:nil)
          arrayOfComments?.append(bubbleData)
         addChatBubble(bubbleData)
    }
    func addChatBubble(_ data: ChatBubbleData) {
        let padding:CGFloat = lastMessageType == data.type ? internalPadding/3.0 :  internalPadding
        let chatBubble = ChatBubble(data: data, startY:lastChatBubbleY + padding)
        if(selectedImage != nil && (data.imagePath == nil))
        {
            chatBubble.imageViewChat?.image=selectedImage
        }
        else if(data.imagePath != nil){
            chatBubble.imageViewChat!.sd_setImage(with: URL(string:data.imagePath!))
        }
        
        chatBubble.closure={(indexData) in
        self.showImage(indexData)
        }
        
        
        self.messageCointainerScroll.addSubview(chatBubble)
        
        lastChatBubbleY = chatBubble.frame.maxY
        
        
        self.messageCointainerScroll.contentSize = CGSize(width: self.view.frame.width, height: lastChatBubbleY + internalPadding)
        self.moveToLastMessage()
        lastMessageType = data.type
        textField.text = ""
        sendButton.isEnabled = false
    }
    
    func moveToLastMessage() {
        
        if messageCointainerScroll.contentSize.height > messageCointainerScroll.frame.height {
            let contentOffSet = CGPoint(x: 0.0, y: messageCointainerScroll.contentSize.height - messageCointainerScroll.frame.height)
            self.messageCointainerScroll.setContentOffset(contentOffSet, animated: true)
            self.messageCointainerScroll.isScrollEnabled=true
        }
    }
    func getRandomChatDataType() -> BubbleDataType {
        return BubbleDataType(rawValue: Int(arc4random() % 2))!
    }
    
    
    // MARK: TEXT FILED DELEGATE METHODS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Send button clicked
        textField.resignFirstResponder()
        if isfromCompleteCases == "2" {
            self.postCommentforItem()
        }else{
            self.postComment()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text: String
        
        if string.characters.count > 0 {
            text = String(format:"%@%@",textField.text!, string);
        } else {
            let string = textField.text! as NSString
            text = string.substring(to: string.length - 1) as String
        }
        if text.characters.count > 0 {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
        return true
    }
    
    //MARK: Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage //2
        
        selectedImage?.resizeWithV(640)
          picker.dismiss(animated: true, completion: { () -> Void in
            self.perform(#selector(self.present2), with: nil, afterDelay: 0)
           
                    })
        
       
    }
   
    func present2(){
        if(self.imageComment ==  nil)
        {
            self.imageComment =  STRImageCommentViewController(nibName: "STRImageCommentViewController", bundle: nil)
        }
        self.imageComment?.textComment = self.textField.text
        self.imageComment!.image = self.selectedImage
        let navigation=UINavigationController(rootViewController: self.imageComment!)
        self.imageComment?.closure = {(comment)in
            self.textField.text = comment
            if self.isfromCompleteCases == "2" {
                self.postCommentforItem()
            }else{
                self.postComment()
            }
            
        }
        self.present(navigation, animated: true) {
            
        }

    }
    // MARK: getConversation
    /// leave
    func dataFeeding(){
        let web = GeneralAPI()
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"

        let someDict:[String:String] = ["issueId":issueID!, "ShipmentNumber" : shipmentNo! , "caseNo": caseNo!]
        
        web.hitApiwith(someDict as Dictionary<String, AnyObject>, serviceType: .strApiGETComments, success: { (response) in
            print(response)
            DispatchQueue.main.async {
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
                    return
                }
                
                guard let data = response["data"] as? [String:AnyObject],let readerGetIssueCommentsResponse = data["readerGetIssueCommentsResponse"] as? [String:AnyObject],let caseDetails = readerGetIssueCommentsResponse["caseDetails"] as? [String:AnyObject],let comments = readerGetIssueCommentsResponse["comments"] as? [[String:AnyObject]]  else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    return
                }
                print(data)
                self.caseDetails=caseDetails
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                self.setUpDetails()
                self.loadChat(comments)
            }
            }) { (err) in
                
                DispatchQueue.main.async {
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue , view:self)
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                }

                
        }
        
    }
    
    func dataFeedingItemComment(){
    }
    
    
    func loadChat(_ comments:[[String:AnyObject]]){
        for dict in comments{
            print(dict)
            if(dict["rtype"]?.intValue == 1)
            {
            
           let arr = dict["issueImages"]
             if(arr?.count>0)
             {
                
                let arayImage = dict["issueImages"] as! [AnyObject]
                let arrr = arayImage[0] as! [String:AnyObject]
                let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil , date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath:(arrr["thumb"] as? String)! ,full:(arrr["full"] as? String)!)
                
                arrayOfComments?.append(chatData)
                }
             else{
                let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath: nil ,full:nil)
                arrayOfComments?.append(chatData)
                }
            }
            else{
                  let arr = dict["issueImages"]
                if(arr?.count>0)
                {
                    let arayImage = dict["issueImages"] as! [AnyObject]
                    let arrr = arayImage[0] as! [String:AnyObject]
                    
                    let imgString = arrr["thumb"] as? String
                    print(imgString)
                    
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine,imagePath:imgString ,full:(arrr["full"] as? String)!)
                arrayOfComments?.append(chatData)
                }
                else{
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine, imagePath:nil,full:nil)
                    arrayOfComments?.append(chatData)
                }

            }
        }
        for e in self.messageCointainerScroll.subviews{
            e.removeFromSuperview()
        }
        self.lastChatBubbleY = 10.0
        self.messageCointainerScroll.setNeedsLayout()

        for chat in arrayOfComments!{
        addChatBubble(chat)
        }
        self.messageCointainerScroll.contentSize = CGSize(width: self.view.frame.width, height: lastChatBubbleY + internalPadding)
    }
    func loadPostedChat(_ dict:[String:AnyObject]){
            print(dict)
            if(dict["rtype"]?.intValue == 1)
            {
                
                let arr = dict["issueImages"]
                if(arr?.count>0)
                {
                    
                    let arayImage = dict["issueImages"] as! [AnyObject]
                    let arrr = arayImage[0] as! [String:AnyObject]
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil , date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath:(arrr["thumb"] as? String)! ,full:(arrr["full"] as? String)!)
                    
                    arrayOfComments?.append(chatData)
                }
                else{
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath: nil ,full:nil)
                    arrayOfComments?.append(chatData)
                }
            }
            else{
                let arr = dict["issueImages"]
                if(arr?.count>0)
                {
                    
                    let arayImage = dict["issueImages"] as! [AnyObject]
                    let arrr = arayImage[0] as! [String:AnyObject]
                    
                    let imgString = arrr["thumb"] as? String
                    print(imgString)
                    
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine,imagePath:imgString ,full:(arrr["full"] as? String)!)
                    arrayOfComments?.append(chatData)
                }
                else{
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine, imagePath:nil,full:nil)
                    arrayOfComments?.append(chatData)
                }
                
            }
        
        for e in self.messageCointainerScroll.subviews{
            e.removeFromSuperview()
        }
        self.lastChatBubbleY = 10.0
        self.messageCointainerScroll.setNeedsLayout()
        for chat in arrayOfComments!{
            addChatBubble(chat)
        }
        self.messageCointainerScroll.contentSize = CGSize(width: self.view.frame.width, height: lastChatBubbleY + internalPadding)
    }
    
    
    func loadChatComments(_ comments:[[String:AnyObject]]){
        arrayOfComments?.removeAll()
        for dict in comments{
            print(dict)
            if(dict["rtype"]?.intValue == 1)
            {
                
                let arr = dict["caseItemImages"]
                if(arr?.count>0)
                {
                    
                    let arayImage = dict["caseItemImages"] as! [AnyObject]
                    let arrr = arayImage[0] as! [String:AnyObject]
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil , date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath:(arrr["thumb"] as? String)! ,full:(arrr["full"] as? String)!)
                    
                    arrayOfComments?.append(chatData)
                }
                else{
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath: nil ,full:nil)
                    arrayOfComments?.append(chatData)
                }
            }
            else{
                let arr = dict["caseItemImages"]
                if(arr?.count>0)
                {
                    
                    let arayImage = dict["caseItemImages"] as! [AnyObject]
                    let arrr = arayImage[0] as! [String:AnyObject]
                    
                    let imgString = arrr["thumb"] as? String
                    print(imgString)
                    
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine,imagePath:imgString ,full:(arrr["full"] as? String)!)
                    arrayOfComments?.append(chatData)
                }
                else{
                    let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine, imagePath:nil,full:nil)
                    arrayOfComments?.append(chatData)
                }
                
            }
        }
        for e in self.messageCointainerScroll.subviews{
            e.removeFromSuperview()
        }
        self.lastChatBubbleY = 10.0
        self.messageCointainerScroll.setNeedsLayout()

        for chat in arrayOfComments!{
            addChatBubble(chat)
        }
        self.messageCointainerScroll.contentSize = CGSize(width: self.view.frame.width, height: lastChatBubbleY + internalPadding)
    }
    
    
    func loadPostedChatItemComment(_ dict:[String:AnyObject]){
        print(dict)
        if(dict["rtype"]?.intValue == 1)
        {
            
            let arr = dict["caseItemImages"]
            if(arr?.count>0)
            {
                
                let arayImage = dict["caseItemImages"] as! [AnyObject]
                let arrr = arayImage[0] as! [String:AnyObject]
                let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil , date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath:(arrr["thumb"] as? String)! ,full:(arrr["full"] as? String)!)
                
                arrayOfComments?.append(chatData)
            }
            else{
                let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .opponent,imagePath: nil ,full:nil)
                arrayOfComments?.append(chatData)
            }
        }
        else{
            let arr = dict["caseItemImages"]
            if(arr?.count>0)
            {
                
                let arayImage = dict["caseItemImages"] as! [AnyObject]
                let arrr = arayImage[0] as! [String:AnyObject]
                
                let imgString = arrr["thumb"] as? String
                print(imgString)
                
                let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine,imagePath:imgString ,full:(arrr["full"] as? String)!)
                arrayOfComments?.append(chatData)
            }
            else{
                let chatData = ChatBubbleData(text: dict["l2"] as? String, image: nil, date: dict["l1"] as? String, name: dict["l3"] as? String, type: .mine, imagePath:nil,full:nil)
                arrayOfComments?.append(chatData)
            }
            
        }
        for e in self.messageCointainerScroll.subviews{
            e.removeFromSuperview()
        }
        self.lastChatBubbleY = 10.0
        self.messageCointainerScroll.setNeedsLayout()

        for chat in arrayOfComments!{
            addChatBubble(chat)
        }
        self.messageCointainerScroll.contentSize = CGSize(width: self.view.frame.width, height: lastChatBubbleY + internalPadding)
    }
    
    
    

    func getDateString(_ date:Date)->(String){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy hh:mm:ss"
        return dateFormatter.string(from: date)

    }
    //leave
    func postComment(){
        //caseNo
        //shippingNo
        //comment
        //images
        let base64String : String?
        let data : Data?
        if selectedImage != nil
        {
          data = UIImageJPEGRepresentation(selectedImage!, 0.0)
          base64String = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        }
        else
        {
            base64String = " "
        }
        print(caseDetails)
        let web = GeneralAPI()
        var loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification?.mode = MBProgressHUDMode.indeterminate
        loadingNotification?.labelText = "Loading"
        var message:String?
        
        if(self.textField.text?.characters.count==0)
        {
            message=" "
            
        }
        else{
            message=self.textField.text
        }
        var dict = [String:AnyObject]()
        
        if selectedImage != nil{
            dict = ["shippingNo":shipmentNo! as AnyObject,"caseNo":caseNo! as AnyObject,"comment":message! as AnyObject,"images":[base64String!] as [String] as AnyObject]
        }
        else{
           dict = ["shippingNo":shipmentNo! as AnyObject,"caseNo":caseNo! as AnyObject,"comment":message! as AnyObject]
        }
        web.hitApiwith(dict, serviceType: .strPostComment, success: { (response) in
            print(response)
            DispatchQueue.main.async {
                if(response["status"]?.intValue != 1)
                {
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    loadingNotification = nil
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: "\(response["message"] as! String)", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
                    return
                }
                
                
                guard let data = response["data"] as? [String:AnyObject],let ReaderReportShippingIssueResponse = data["readerReportShippingIssueResponse"] ,let comments = ReaderReportShippingIssueResponse["comment"] as? [String:AnyObject] else{
                    
                    MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
                    utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue , view:self)
                    return
                }
                
                self.loadPostedChat(comments)
                self.selectedImage=nil
                print(data)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
        }) { (err) in
            
            DispatchQueue.main.async {
                utility.createAlert(TextMessage.alert.rawValue, alertMessage: TextMessage.tryAgain.rawValue, alertCancelTitle: TextMessage.Ok.rawValue , view:self)
                MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            }
            
            
        }

        
    }
    func postCommentforItem(){

    }
    func validate()->(Bool){
        if(textField.text?.characters.count==0)
        {
             utility.createAlert(TextMessage.alert.rawValue, alertMessage: "Please enter a comment", alertCancelTitle: TextMessage.Ok.rawValue, view:self)
            return false
        }
        return true
    }
    func setUpDetails(){
         lbll1.text=caseDetails!["l1"] as? String
         lbll2.text=caseDetails!["l2"] as? String
       
        if caseDetails!["isReported"]?.intValue == 1 {
            imgImage.image = UIImage(named: "reportedstatus")
        }else
        {
            imgImage.image = UIImage(named: "")
        }
        
         lbll2.textColor =  colorWithHexString((caseDetails!["color"] as? String)!)
         lbll3.text=caseDetails!["l3"] as? String
         lbll4.text=caseDetails!["l4"] as? String
    }
    
    
    func setUpDetailforComment(){
        lblItem1.text=caseDetails!["l1"] as? String
        lblItem2.text=caseDetails!["l2"] as? String
    }
    
    func showImage(_ index: String)
    {
        let imgDisplay =  Bundle.main.loadNibNamed("STRImageDisplay", owner: self, options: nil)! .first as! STRImageDisplay
        imgDisplay.tag=10001
        imgDisplay.frame=(self.navigationController?.view.frame)!;
        imgDisplay.layoutIfNeeded()
        imgDisplay.hideClouser={()in
        self.navigationController?.view.viewWithTag(10001)?.removeFromSuperview()
        }
        imgDisplay.setUpImage(index)
        self.navigationController?.view.addSubview(imgDisplay)

    }
    func setUpFont(){
    }

    
}
