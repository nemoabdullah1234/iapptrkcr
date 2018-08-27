#import <UIKit/UIKit.h>

@interface CSSelectedFileCell : UICollectionViewCell{
    
    UIImageView     *fileImageView;
    NSString        *filePathURL;
    UIButton        *btnCut;
    
}
@property(nonatomic,retain)NSIndexPath     *indexPath;
@property(nonatomic,assign)BOOL            shocut;
@property(nonatomic,copy)void(^performRemoval)(NSString*,NSIndexPath*);
-(void)setImageViewFromUrl:(NSString*)url;
-(void)setImageFromWebURL:(NSString*)webUrl;
@end
