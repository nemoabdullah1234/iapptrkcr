//
//  STRHomeViewController.swift
//  STRCourier
//
//  Created by Nitin Singh on 17/10/16.
//  Copyright © 2016 OSSCube. All rights reserved.
//

import UIKit

class STRHomeViewController: UIViewController, MGSwipeTableCellDelegate {
 
     @IBOutlet var tblView: UITableView!
    var cellTapped:Bool = true
    var currentRow = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "STRSwipeTableViewCell", bundle: nil)
        tblView.registerNib(nib, forCellReuseIdentifier: "swipeTableViewCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        let cell: STRSwipeTableViewCell = self.tblView.dequeueReusableCellWithIdentifier("swipeTableViewCell") as! STRSwipeTableViewCell
        cell.selectionStyle  = UITableViewCellSelectionStyle.None
       cell.lbl1.text = "Nitin Chauhan"
        cell.delegate = self;
        
        cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"check.png"), backgroundColor: UIColor.greenColor())
            ]
        cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
//        cell.rightButtons = [MGSwipeButton(title: "Show Map" , backgroundColor: UIColor.lightGrayColor())
//            ,MGSwipeButton(title: "Start Shipment",backgroundColor: UIColor.blueColor())]
//        cell.rightSwipeSettings.transition = MGSwipeTransition.Drag
        
        let deleteButton = MGSwipeButton(title: "Show Map", backgroundColor: UIColor.darkGrayColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            // do Stuff
            return true
        })
        let startShipmentButton = MGSwipeButton(title: "Start Shipment", backgroundColor: UIColor.blueColor(), callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            // do Stuff
            return true
        })
        deleteButton.buttonWidth = 100
        startShipmentButton.buttonWidth = 100
        cell.rightButtons = [deleteButton, startShipmentButton]
        
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        if indexPath.row == currentRow {
            if cellTapped == false {
                cellTapped = true
                return 141
            } else {
                cellTapped = false
                return 80
            }
        }
        return 80
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:STRSwipeTableViewCell? = tableView.cellForRowAtIndexPath(indexPath) as? STRSwipeTableViewCell
        
        cell?.bottomView.hidden = false
        
        
        
        let selectedRowIndex = indexPath
        currentRow = selectedRowIndex.row
        
      // self.tblView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.beginUpdates()

        tableView.endUpdates()
    }
    
    func swipeTableCell(cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true;
    }
    
    
   
    
}
