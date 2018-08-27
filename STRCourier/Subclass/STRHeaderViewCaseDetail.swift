import UIKit

class STRHeaderViewCaseDetail: UIView {
    var dictData: Dictionary<String,AnyObject>?
    @IBOutlet var imgSource: UIImageView!
    
    @IBOutlet var imgDestination: UIImageView!
    
    @IBOutlet var imgIntransit: UIImageView!
    
    @IBOutlet var layoutCallHeight: NSLayoutConstraint!
    @IBOutlet var lblStart: UILabel!
    @IBOutlet var lblStartDate: UILabel!
    @IBOutlet var lblDelivered: UILabel!
    @IBOutlet var lblDeliveredDate: UILabel!
    
    @IBOutlet var lblDocName: UILabel!
    @IBOutlet var lbl2: UILabel!
    @IBOutlet var lbl3: UILabel!
    @IBOutlet var lbl4: UILabel!
    
    @IBOutlet var lblPhoneNo: UILabel!
    @IBOutlet var imgPhoneIcon: UIImageView!
    
    @IBOutlet var vwBasePhone: UIView!
    
    @IBOutlet var lblFax: UILabel!
    
    @IBOutlet var btnCall: UIButton!
    
    @IBAction func btnCall(_ sender: AnyObject) {
        var ph = lblPhoneNo.text?.replacingOccurrences(of: "(", with: "")
          ph = ph?.replacingOccurrences(of: ")", with: "")
          ph = ph?.replacingOccurrences(of: "-", with: "")
          ph = ph?.replacingOccurrences(of: " ", with: "")
         if(utility.isPhoneNumber(ph!)){
            let url = URL(string: "tel://\(ph!)")
            UIApplication.shared.openURL(url!)
         }
    }
    
    static func headerViewForDict(_ dataDict:Dictionary<String,AnyObject>)->STRHeaderViewCaseDetail{
        let vw = Bundle.main.loadNibNamed("STRHeaderViewCaseDetail", owner: nil, options: nil)!.last as! STRHeaderViewCaseDetail
        vw.setUpDataOfHeader(dataDict)
        return vw
    }
    func setUpDataOfHeader(_ dict:Dictionary<String,AnyObject>){
        
        switch dict["shipStatus"] as! NSInteger{
        case 10:
            lblStart.text =  "Received On"
            lblDelivered.text = "ETD"
            imgIntransit.image = UIImage.init(named: "iconnewtruck")
            imgDestination.image = UIImage.init(named: "watchicon")
            break
        case 20:
            //scheduled
            lblStart.text =  "Scheduled On"
            lblDelivered.text = "ETD"
            imgIntransit.image = UIImage.init(named: "scduletruck")
            imgDestination.image = UIImage.init(named: "watchicon")
            break
        case 30:
            //soft shipped
            lblStart.text =  "Scheduled On"
            lblDelivered.text = "ETD"
            imgIntransit.image = UIImage.init(named: "intransittruck")
            imgDestination.image = UIImage.init(named: "watchicon")
            break
        case 25:
            //soft shipped
            lblStart.text =  "Scheduled On"
            lblDelivered.text = "ETD"
            imgIntransit.image = UIImage.init(named: "iconpartialtruck")
            imgDestination.image = UIImage.init(named: "watchicon")
            break
        case 40:
            lblStart.text =  "Received On"
            lblDelivered.text = "ETD"
            imgIntransit.image = UIImage.init(named: "intransittruck")
           
            imgDestination.image = UIImage.init(named: "watchicon")
            break
        case 45:
            lblStart.text =  "Received On"
            lblDelivered.text = "Delivered On"
            imgIntransit.image = UIImage.init(named: "iconpartialdeliverd")
            
            imgDestination.image = UIImage.init(named: "deliveredicon")
            break
        case 50:
            //Soft Delivered
            lblStart.text =  "Received On"
            lblDelivered.text = "Delivered On"
            imgIntransit.image = UIImage.init(named: "icondeliveredtruck")
            imgDestination.image = UIImage.init(named: "deliveredicon")
            break
        case 60:
            //Delivered
            lblStart.text =  "Received On"
            lblDelivered.text = "Delivered On"
            imgIntransit.image = UIImage.init(named: "icondeliveredtruck")
            imgDestination.image = UIImage.init(named: "deliveredicon")
            break

        default:
            break
        }
        lblStartDate.text = dict["l13"] as? String
        lblDeliveredDate.text = dict["l12"] as? String
        lblDocName.text = dict["l1"] as? String
        lbl2.text = "\(dict["l8"] as! String) | \(dict["l9"] as! String)"
        var str = dict["l2"] as? String
         str = str?.replacingOccurrences(of: "\r\n", with: " ")
        lbl3.text = str
        lblFax.text = ""//"Fax: \(dict["l11"] as! String)"
        lblPhoneNo.text = "\(dict["l10"] as! String)"
        
        if(lblPhoneNo.text == "" && dict["l10"] as! String == "" )
        {
            layoutCallHeight.constant = 0
        }
        if(lblPhoneNo.text == "")
        {
            vwBasePhone.isHidden = true
        }
        if(dict["l10"] as! String == "")
        {
            lblFax.text = ""
        }

    }
    override func awakeFromNib() {
        lblStart.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblStartDate.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblDelivered.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblDeliveredDate.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblDocName.font = UIFont(name: "SourceSansPro-Semibold", size: 18.0);
        lbl2.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lbl3.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblFax.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
        lblPhoneNo.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
        vwBasePhone.layer.cornerRadius = 15
        vwBasePhone.backgroundColor = UIColor(red: 250.0/255.0, green: 180.0/255.0, blue: 0.0, alpha: 1.0)

    }

}
