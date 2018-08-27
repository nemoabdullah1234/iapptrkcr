import UIKit

class ChatBubble: UIView {

    
    // Properties
    var imageViewChat: UIImageView?
    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    var labelName:UILabel?
    var labelTime: UILabel?
    var closure:((String)->())?
    var data: ChatBubbleData?
    
    
    /**
    Initializes a chat bubble view
    
    - parameter data:   ChatBubble Data
    - parameter startY: origin.y of the chat bubble frame in parent view
    
    - returns: Chat Bubble
    */
    init(data: ChatBubbleData, startY: CGFloat){
        self.data = data
        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(data.type, startY:startY))
        
        // Making Background transparent
        self.backgroundColor = UIColor.clear
        
        // adding gesture
      
        let tap = UITapGestureRecognizer.init(target: self, action:#selector(self.tap))
        tap.numberOfTapsRequired=1
        self.addGestureRecognizer(tap)
        
        let padding: CGFloat = 10.0
        let startX = padding
        var startY:CGFloat = 5.0

        
        
        labelName = UILabel(frame: CGRect(x: startX, y: startY, width: self.frame.width - 2 * startX , height: 5))
        labelName?.textAlignment = data.type == .mine ? .left : .left
        // labelName?.font = FontXtraSmall.Footnote
        labelName?.numberOfLines = 0 // Making it multiline
        labelName?.text = data.name
        labelName?.sizeToFit() // Getting fullsize of it
        self.addSubview(labelName!)

        
        
        
        // 2. Drawing image if any
        if data.imagePath != nil {
            
            let width: CGFloat = min(100, self.frame.width - 2 * padding)
            let height: CGFloat = 100 * (width / 100)
            imageViewChat = UIImageView(frame: CGRect(x: padding, y: labelName!.frame.maxY, width: width, height: height))
            //imageViewChat?.image = chatImage
            imageViewChat?.layer.cornerRadius = 5.0
            imageViewChat?.layer.masksToBounds = true
            self.addSubview(imageViewChat!)
        }
        
        // 3. Going to add Text if any
        if data.text != nil {
            // frame calculation
//            let startX = padding
//            var startY:CGFloat = 5.0
            if imageViewChat != nil {
                startY += imageViewChat!.frame.maxY
            }
            else{
                startY += labelName!.frame.maxY
            }
            
            
            labelChatText = UILabel(frame: CGRect(x: startX, y: startY, width: self.frame.width - 2 * startX , height: 5))
            labelChatText?.textAlignment = data.type == .mine ? .right : .left
            //   labelChatText?.font = FontXtraSmall.Body
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            labelChatText?.sizeToFit() // Getting fullsize of it
            self.addSubview(labelChatText!)
        }
        
        labelTime = UILabel(frame: CGRect(x: labelChatText!.frame.maxX-15,  y: labelChatText!.frame.maxY, width: self.frame.width - 2 * startX , height: 5))
        labelTime?.textAlignment = data.type == .mine ? .right : .right
        //   labelTime?.font = FontXtraSmall.Caption1
        labelTime?.numberOfLines = 0 // Making it multiline
        labelTime?.text = data.date
        //labelTime?.backgroundColor=UIColor.redColor()
        labelTime?.sizeToFit() // Getting fullsize of it
        
        if let img = imageViewChat{
        labelTime?.frame = CGRect(x: startX, y: labelChatText!.frame.maxY,width: max(labelChatText!.frame.size.width, (labelTime?.frame.size.width)!,imageViewChat!.frame.size.width,labelName!.frame.size.width), height: (labelTime?.frame.size.height)!)
        }
        else{
           labelTime?.frame = CGRect(x: startX, y: labelChatText!.frame.maxY,width: max(labelChatText!.frame.size.width, (labelTime?.frame.size.width)!,labelName!.frame.size.width), height: (labelTime?.frame.size.height)!)
        }
        self.addSubview(labelTime!)
        
        
        
        
        
        
        
        // 4. Calculation of new width and height of the chat bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        if let imageView = imageViewChat {
            // Height calculation of the parent view depending upon the image view and text label
            viewWidth = max(imageViewChat!.frame.maxX, labelChatText!.frame.maxX,labelName!.frame.maxX,labelTime!.frame.maxX) + padding
            viewHeight = max(imageViewChat!.frame.maxY, labelChatText!.frame.maxY) + padding + (labelTime?.frame.size.height)! + (labelName?.frame.size.height)!
            
        } else {
            viewHeight = labelChatText!.frame.maxY + padding/2 + (labelTime?.frame.size.height)! + (labelName?.frame.size.height)!
            viewWidth = max(labelChatText!.frame.width,labelName!.frame.maxX,labelTime!.frame.maxX) + labelChatText!.frame.minX + padding
        }
        
        // 5. Adding new width and height of the chat bubble frame
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: viewWidth, height: viewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
       let bubbleImageFileName = data.type == .mine ? "bubbleMine" : "bubbleSomeone"
        imageViewBG = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))
        if data.type == .mine {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 14, 17, 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsetsMake(14, 22, 17, 20))
        }
        // self.addSubview(imageViewBG!)
        // self.sendSubviewToBack(imageViewBG!)
        
        // Frame recalculation for filling up the bubble with background bubble image
         let repsotionXFactor:CGFloat = data.type == .mine ? 0.0 : -8.0
        let bgImageNewX = imageViewBG!.frame.minX + repsotionXFactor
        let bgImageNewWidth =  imageViewBG!.frame.width + CGFloat(12.0)
        let bgImageNewHeight =  imageViewBG!.frame.height + CGFloat(6.0)
        imageViewBG?.frame = CGRect(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)

        
        // Keepping a minimum distance from the edge of the screen
        var newStartX:CGFloat = 0.0
        if data.type == .mine  {
            // Need to maintain the minimum right side padding from the right edge of the screen
            let extraWidthToConsider = imageViewBG!.frame.width
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
        } else {
            // Need to maintain the minimum left side padding from the left edge of the screen
            newStartX = -imageViewBG!.frame.minX + 3.0
        }
        
        self.frame = CGRect(x: newStartX, y: self.frame.minY, width: frame.width, height: frame.height)
        self.layer.borderWidth=1
        self.layer.borderColor=UIColor.black.cgColor
        self.layer.cornerRadius=5
        
    }

    // 6. View persistance support
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - FRAME CALCULATION
    class func framePrimary(_ type:BubbleDataType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.65 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
       let startX: CGFloat = type == .mine ? ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRect(x: startX, y: startY, width: maxWidth, height: 5) // 5 is the primary height before drawing starts
    }
   
    
    func tap(){
        if((closure) != nil && imageViewChat?.image != nil)
        {
            closure!((self.data?.full)!)
        }

    }
}
