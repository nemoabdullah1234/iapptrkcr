#import <UIKit/UIKit.h>

@interface CSFileSlideView :  UIView<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UICollectionView *fileGallery;
@property(nonatomic,copy)void(^cellSelect)(NSIndexPath*);
@property(nonatomic,copy)void(^fileDelete)(NSIndexPath*);
@property(nonatomic,copy)BOOL(^removeFile)(NSIndexPath*);
@property(nonatomic,assign)BOOL            shocut;
-(NSInteger)addAssetURL:(NSString*)filePathURL;
-(void)replicateAwakeFromNib;
-(void)removeAllImages;
-(BOOL)validate;
-(void)setFrame;
-(NSInteger)getImageCount;
@end
