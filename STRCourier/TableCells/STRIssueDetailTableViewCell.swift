import UIKit

class STRIssueDetailTableViewCell: UITableViewCell {
    @IBOutlet var vwBase: UIView!
    @IBOutlet var imgUserProfile: STRProfileImageView!
    @IBOutlet var lblDate: UILabel!
    var fileSlideView: CSFileSlideView!
    var lblMsg:UILabel!
    var lblTop:UILabel!
    var itemView:UIView!
    var data: Dictionary<String,AnyObject>?
    var imageUrl:((String)->())?
    var cellType:STRTypeOfReport?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUpData(_ dict:Dictionary<String,AnyObject>,index:NSInteger)
    {
        self.cellType = .strReportCase
        for view in self.vwBase.subviews {
                           view.removeFromSuperview()
        }
        //GET DATA
        data =  dict
        let items = dict["items"] as? [Dictionary<String,AnyObject>]
        let images = dict["issueImages"] as? [Dictionary<String,AnyObject>]
        
        //BASIC SETUP
        
        lblDate.text = dict["l5"] as? String
        imgUserProfile.setUpImage((dict["userProfilePicUrl"] as? String)!)
        
        
        lblTop = nil
        lblTop = UILabel()
        lblTop.text = dict["l3"] as? String
        lblTop.numberOfLines = 1
        lblTop.translatesAutoresizingMaskIntoConstraints = false
        
        lblTop.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        lblTop.textColor = UIColor(red: 65.0/255.0, green: 65.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        
        lblMsg = nil
        lblMsg = UILabel()
        lblMsg.text  = dict["l2"] as? String
        lblMsg.numberOfLines = 0
        lblMsg.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblMsg.translatesAutoresizingMaskIntoConstraints=false
        lblMsg.font = UIFont(name: "SourceSansPro-Regular", size: 14.0)
        lblMsg.textColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        self.vwBase.addSubview(lblMsg)
        self.vwBase.addSubview(lblTop)
        
        //Add constrints
          self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(18)-[lblTop(20)]-(2)-[lblMsg]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblTop" : lblTop,"lblMsg":lblMsg]))
         self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lblTop]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblTop" : lblTop]))
         self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lblMsg]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg]))
        
        if((items ==  nil || items?.count == 0) && (images == nil || images?.count == 0))
        {
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblMsg]-(18)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg]))
        }
        
        if(items !=  nil && items?.count != 0)
        {
            itemView = viewItemList(items)
            self.vwBase.addSubview(itemView)
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblMsg]-(18)-[itemView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg,"itemView":itemView]))
             self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[itemView]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["itemView":itemView]))
            if((images == nil || images?.count == 0))
            {
                self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[itemView]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["itemView":itemView]))
            }
        }
        
        if(images != nil && images?.count != 0)
        {
            fileSlideView = nil
            fileSlideView = CSFileSlideView()
            fileSlideView.translatesAutoresizingMaskIntoConstraints = false
            self.vwBase.addSubview(fileSlideView)
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[fileSlideView]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["fileSlideView":fileSlideView]))
            
            if(items ==  nil || items?.count == 0)
            {
                 self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblMsg]-(8)-[fileSlideView(90)]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg,"fileSlideView":fileSlideView]))
            }
            else{
                 self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[itemView]-(8)-[fileSlideView(90)]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["itemView" : itemView,"fileSlideView":fileSlideView]))
            }
            
        }

     }
    
    
    func viewItemList(_ items:[Dictionary<String,AnyObject>]!)->UIView{
        let itemView = UIView()
        var lblPrev:UILabel?
        let lblTitle = UILabel()
        lblTitle.text = "Product(s):"
        lblTitle.font = UIFont(name: "SourceSansPro-Semibold", size: 14.0);
        lblTitle.textColor = UIColor(red: 65.0/255.0, green: 65.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        itemView.translatesAutoresizingMaskIntoConstraints = false

        itemView.addSubview(lblTitle)
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lblTitle]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblTitle" : lblTitle]))
        
        itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[lblTitle]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblTitle" : lblTitle]))
        
        
        for index in 0...(items.count-1) {
            let lbl = UILabel()
            lbl.font = UIFont(name: "SourceSansPro-Regular", size: 14.0)
            lbl.textColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
            let dict = items[index]
            lbl.text = (dict["l1"] as? String)! + " - " + (dict["l2"] as? String)!
            lbl.translatesAutoresizingMaskIntoConstraints = false
            itemView.addSubview(lbl)
            itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lbl]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lbl" : lbl]))
            if(items?.count == 1)
            {
                itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblTitle]-(2)-[lbl(20)]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lbl" : lbl,"lblTitle":lblTitle]))
            }
            else if(index == 0){
                 itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblTitle]-(2)-[lbl(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lbl" : lbl,"lblTitle":lblTitle]))
                lblPrev = lbl
            }
            else if(index == (items!.count-1))
            {
                itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblPrev]-(2)-[lbl(20)]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lbl" : lbl,"lblPrev":lblPrev!]))
            }
            else{
                itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblPrev]-(2)-[lbl(20)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lbl" : lbl,"lblPrev":lblPrev!]))
                lblPrev = nil
                lblPrev = lbl
            }
        }
        return itemView
    }
    func setUpData2(_ dict:Dictionary<String,AnyObject>,index:NSInteger)
    {
        self.cellType = .strReportDueback
        for view in self.vwBase.subviews {
            view.removeFromSuperview()
        }
        //GET DATA
        data =  dict
        let items = dict["items"] as? [Dictionary<String,AnyObject>]
        let images = dict["caseItemImages"] as? [Dictionary<String,AnyObject>]
        
        //BASIC SETUP
        
        lblDate.text = dict["l5"] as? String
        imgUserProfile.setUpImage((dict["userProfilePicUrl"] as? String)!)
        
        
        lblTop = nil
        lblTop = UILabel()
        lblTop.text = dict["l3"] as? String
        lblTop.numberOfLines = 1
        lblTop.translatesAutoresizingMaskIntoConstraints = false
        
        lblTop.font =  UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        lblTop.textColor = UIColor(red: 65.0/255.0, green: 65.0/255.0, blue: 65.0/255.0, alpha: 1.0)
        
        lblMsg = nil
        lblMsg = UILabel()
        lblMsg.text  = dict["l2"] as? String
        lblMsg.numberOfLines = 0
        lblMsg.lineBreakMode = NSLineBreakMode.byWordWrapping
        lblMsg.translatesAutoresizingMaskIntoConstraints=false
        lblMsg.font = UIFont(name: "SourceSansPro-Regular", size: 14.0)
        lblMsg.textColor = UIColor(red: 90.0/255.0, green: 90.0/255.0, blue: 90.0/255.0, alpha: 1.0)
        self.vwBase.addSubview(lblMsg)
        self.vwBase.addSubview(lblTop)
        
        //Add constrints
        self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(18)-[lblTop(20)]-(4)-[lblMsg]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblTop" : lblTop,"lblMsg":lblMsg]))
        self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lblTop]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblTop" : lblTop]))
        self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[lblMsg]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg]))
        
        if((items ==  nil || items?.count == 0) && (images == nil || images?.count == 0))
        {
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblMsg]-(18)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg]))
        }
        
        if(items !=  nil && items?.count != 0)
        {
            itemView = viewItemList(items)
            self.vwBase.addSubview(itemView)
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblMsg]-(18)-[itemView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg,"itemView":itemView]))
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[itemView]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["itemView":itemView]))
            if((images == nil || images?.count == 0))
            {
                self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[itemView]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["itemView":itemView]))
            }
        }
        
        if(images != nil && images?.count != 0)
        {
            fileSlideView = nil
            fileSlideView = CSFileSlideView()
            fileSlideView.translatesAutoresizingMaskIntoConstraints = false
            self.vwBase.addSubview(fileSlideView)
            self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[fileSlideView]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["fileSlideView":fileSlideView]))
            
            if(items ==  nil || items?.count == 0)
            {
                self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lblMsg]-(8)-[fileSlideView(90)]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lblMsg" : lblMsg,"fileSlideView":fileSlideView]))
            }
            else{
                self.vwBase.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[itemView]-(0)-[fileSlideView(90)]-(8)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["itemView" : itemView,"fileSlideView":fileSlideView]))
            }
            
        }
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        imgUserProfile.layer.cornerRadius = imgUserProfile.bounds.width/2
        lblDate.font = UIFont(name: "SourceSansPro-Regular", size: 12.0)
        let images = data!["issueImages"] as? [Dictionary<String,AnyObject>]
        if(images != nil && images?.count != 0)
        {
        fileSlideView.replicateAwakeFromNib()
        for dict in images!{
            fileSlideView.addAssetURL(dict["thumb"] as? String)
        }
        }
        let images2 = data!["caseItemImages"] as? [Dictionary<String,AnyObject>]
        if(images2 != nil && images2?.count != 0)
        {
            fileSlideView.replicateAwakeFromNib()
            for dict in images2!{
                fileSlideView.addAssetURL(dict["thumb"] as? String)
            }
        }
        
        if(fileSlideView != nil)
        {
            fileSlideView.cellSelect = {(indexPath) in
                print(indexPath?.row)
                if(self.imageUrl != nil )
                {
                    var images :[Dictionary<String,AnyObject>]!
                    if( self.cellType == .strReportCase)
                    {
                     images = self.data!["issueImages"] as? [Dictionary<String,AnyObject>]
                    }
                    else
                    {
                         images = self.data!["caseItemImages"] as? [Dictionary<String,AnyObject>]
                    }
                    self.imageUrl!(images![(indexPath?.row)!]["full"]! as! String)
                }
                
            }
        }
    }
}
