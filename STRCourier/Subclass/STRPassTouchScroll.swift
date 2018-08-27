import UIKit

class STRPassTouchScroll: UIScrollView {
  @IBOutlet var view: UIView!
  @IBOutlet var tblView: UIView!

    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        if(self.view.frame.contains(point))
        {
            return true
        }
        
        return false
    }

}
