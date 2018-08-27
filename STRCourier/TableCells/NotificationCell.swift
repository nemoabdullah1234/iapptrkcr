import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet var imgIcon: UIImageView!

    @IBOutlet var lbl1: UILabel!
    
    @IBOutlet var lbl3: UILabel!
    @IBOutlet var lbl2: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpFont()
        lbl2.lineBreakMode = NSLineBreakMode.byWordWrapping
    }

    func setUpFont(){
       lbl1.font = UIFont(name: "SourceSansPro-Regular", size: 18.0);
       lbl2.font = UIFont(name: "SourceSansPro-Regular", size: 16.0);
       lbl3.font = UIFont(name: "SourceSansPro-Regular", size: 14.0);
    }

    func setUpData(_ dict:Dictionary<String,AnyObject>){
         lbl1.text = dict["title"] as? String
         lbl2.text = dict["message"] as? String
         lbl3.text = dict["notificationTime"] as? String
        
        switch dict["type"] as! String {
        case "4,5,7,8,2,10,12,11",
            "GPSBluetoothDown",
            "ShipmentPartialDeliveredCR",
            "ShipmentPartialShippedCR",
            "ShipmentPartialDeliveredSR",
            "ShipmentPartialShippedSR",
            "SurgeryDateChange",
            "IssueRespondedSR",
            "IssueCreatedSR",
            "IssueRespondedCR",
            "ShipmentDelayedSR",
            "ShipmentDelayedCR",
            "IssueCreatedCR":
            imgIcon.image = UIImage.init(named: "iconreport")
            break
        case "6":
            imgIcon.image = UIImage.init(named: "inoti")
            break
            
        case "1,3,9,13,15,16,14,17,18",
            "OrderCreation",
            "ShipmentSoftDeliveredCR",
            "ShipmentHardDeliveredCR",
            "ShipmentHardShippedCR",
            "ShipmentSoftShippedCR",
            "ShipmentScheduledCR",
            "ShipmentSoftDeliveredSR",
            "ShipmentHardDeliveredSR",
            "ShipmentHardShippedSR",
            "ShipmentSoftShippedSR",
            "ShipmentScheduledSR",
            "CarrierAssignment",
            "OrderAssignedFromSalesRep",
            "OrderAssignedToSalesRep":
            imgIcon.image = UIImage.init(named: "bell")
            break
        default:
            imgIcon.image = UIImage.init(named: "bell")
            break
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
