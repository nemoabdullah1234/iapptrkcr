#import "CSSelectedFileCell.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "UIImageView+AFNetworking.h"
@implementation CSSelectedFileCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        fileImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 75, 75)];
        fileImageView.clipsToBounds = YES;
        fileImageView.contentMode =  UIViewContentModeCenter;
        fileImageView.backgroundColor=[UIColor whiteColor];
        fileImageView.layer.cornerRadius = 2.0;
        btnCut=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnCut setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [btnCut addTarget:self action:@selector(removeFile:) forControlEvents:UIControlEventTouchUpInside];
        btnCut.frame=CGRectMake(60,0, 30, 30);
        [self addSubview:fileImageView];
        [self addSubview:btnCut];
    }
    return self;
}

-(void)setImageViewFromUrl:(NSString*)url{
    filePathURL=[url copy];
    
    if([url rangeOfString:@"http"].location==NSNotFound)
        {
        fileImageView.image=[UIImage imageWithContentsOfFile:url];
        if(self.indexPath.row == 0 && !self.shocut)
            {
            btnCut.hidden=YES;
            }
        else
            {
            btnCut.hidden=NO;
            }
        }
    else
        {
    [fileImageView setImageWithURL:[NSURL URLWithString:url]];
         btnCut.hidden=YES;
        }
   
}



-(void)removeFile:(UIButton*)btn{
    self.performRemoval(filePathURL,self.indexPath);
}


@end
