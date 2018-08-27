#import <UIKit/UIKit.h>
@class PCALertView;

@protocol PCALertViewDelegate <NSObject>

-(void)alertClickedBtn:(UIButton *)btn alertView:(PCALertView *)alertView;

@end


@interface PCALertView : UIView
@property(nonatomic,strong)NSMutableArray *arrButton;
@property(nonatomic,strong)NSMutableArray *arr_no_of_Button;
@property(nonatomic,strong)UIViewController *viewController;
@property(nonatomic,strong)NSString *alertMsg;
@property(nonatomic,strong)NSString *format;
@property(nonatomic,strong)NSString *otherButton;

-(void)alertwithPcalert:(UIViewController*)viewController  withMsg:(NSString *)alertMsg buttonTitle:(NSString *)format, ...;


-(void)methodofPCAlert;

@property(nonatomic ,assign)id<PCALertViewDelegate> delegate;
@end
