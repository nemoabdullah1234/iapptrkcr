import Foundation
import UIKit // For using UIImage

// 1. Type Enum
/**
Enum specifing the type

- Mine:     Chat message is outgoing
- Opponent: Chat message is incoming
*/
enum BubbleDataType: Int{
    case mine = 0
    case opponent
}

/// DataModel for maintaining the message data for a single chat bubble
class ChatBubbleData {
    // 2.Properties
    var text: String?
    var image: UIImage?
    var date: String?
    var type: BubbleDataType
    var name: String?
    var imagePath: String?
    var full : String?
    // 3. Initialization
    init(text: String?,image: UIImage?,date: String? ,name: String?, type:BubbleDataType = .mine ,imagePath:String? ,full:String?   ) {
        // Default type is Mine
        self.text = text
        self.image = image
        self.date = date
        self.type = type
        self.name = name
        self.imagePath=imagePath
        self.full=full
    }
}
