#import "CSFileSlideView.h"
#import "CSSelectedFileCell.h"
@interface CSFileSlideView(){
    NSMutableArray   *filePathArray;
    NSIndexPath      *indexPathnew;
    NSString         *urlString;
}


@end
@implementation CSFileSlideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
           }
    return self;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(filePathArray) return filePathArray.count;
    return 0;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(90, 90);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
    
        
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"com.oss.chartsnapp.selectedfile";    CSSelectedFileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
        cell = [[CSSelectedFileCell alloc] init];
    }
    cell.shocut =self.shocut;
    cell.indexPath=indexPath;
    cell.performRemoval=^(NSString* url,NSIndexPath  *indexP){
        indexPathnew=indexP;
        urlString=url;
        UIAlertView    *alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Do you want delete Image" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag=101;
        [alert show];
    };
    [cell setImageViewFromUrl:[filePathArray objectAtIndex:(uint)indexPath.item]];
    return cell;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==101)
        if(buttonIndex==0)
            {
                       if(self.fileDelete)self.fileDelete(indexPathnew);
                       [self deleteFile:urlString];
                       [filePathArray removeObject:urlString];
                       [self.fileGallery reloadData];
            }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.cellSelect)
    self.cellSelect(indexPath);

}
-(void)replicateAwakeFromNib{
    if(self.fileGallery != nil)
        {
        [self.fileGallery removeFromSuperview];
        self.fileGallery =nil;
        }
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.fileGallery=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)collectionViewLayout:flowLayout];
    if(self.frame.size.height>90)
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    else
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.fileGallery setAutoresizingMask:self.autoresizingMask];
    self.fileGallery.delegate=self;
    self.fileGallery.backgroundColor=[UIColor clearColor];
    self.fileGallery.dataSource=self;
    [self addSubview:self.fileGallery];
        
    [self.fileGallery registerClass:[CSSelectedFileCell class] forCellWithReuseIdentifier:@"com.oss.chartsnapp.selectedfile"];

}
-(void)awakeFromNib{
  UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.fileGallery=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height)collectionViewLayout:flowLayout];
    if(self.frame.size.height>90)
         [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    else
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.fileGallery setAutoresizingMask:self.autoresizingMask];
    self.fileGallery.delegate=self;
    self.fileGallery.backgroundColor=[UIColor clearColor];
    self.fileGallery.dataSource=self;
    [self addSubview:self.fileGallery];
    [self.fileGallery registerClass:[CSSelectedFileCell class] forCellWithReuseIdentifier:@"com.oss.chartsnapp.selectedfile"];
}
#pragma mark setting up file path data source
-(NSInteger)addAssetURL:(NSString*)filePathURL{
    if(!filePathArray)filePathArray=[[NSMutableArray alloc] init];
    if([filePathArray containsObject:filePathURL])return 1;
    [filePathArray addObject:filePathURL];
    [self.fileGallery reloadData];
    return 0;
}
-(NSMutableArray*)getFilePathArray{
    if(filePathArray)return filePathArray;
    return NULL;
}

#pragma mark:- delete file
-(void)deleteFile:(NSString*)urlPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:urlPath  error:nil];
    if (success) {
         NSLog(@" deleted file -:");
    }
    else
        {
        NSLog(@"Could not delete file -:");
        }

}
-(void)setFrame{
    self.fileGallery.frame=CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
}
-(void)removeAllImages{
    [filePathArray removeAllObjects];
    [self.fileGallery reloadData];
}
-(BOOL)validate{
    if(filePathArray.count==0)return NO;
    return YES;
}
-(NSInteger)getImageCount{
    if(!filePathArray) return 0;
   return filePathArray.count;
}

@end
