#import "PCALertView.h"
#import "PCAlertViewButton.h"
#import "PClbldescAlertView.h"


@interface PCALertView ()
@property(nonatomic,assign)NSInteger no_of_buttons;
@property(nonatomic,assign)NSString *lblHeader;
@property(nonatomic,assign)NSString *lbldesc;


@end
#define TRANSACTIONCANCELTAG     1010102

@implementation PCALertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

-(void)methodofPCAlert
{
    [self alertwithPcalert:_viewController withMsg:_alertMsg buttonTitle:_format,_otherButton, nil];
}

-(void)alertwithPcalert:(UIViewController*)viewController  withMsg:(NSString *)alertMsg buttonTitle:(NSString *)format, ...
{
    if(viewController==nil)return;
    self.arrButton = [[NSMutableArray alloc] init];
    self.arr_no_of_Button = [[NSMutableArray alloc] init];
    
    va_list args; //pointer to the variables
    va_start(args, format); //intialize to first argument
    for (NSString *arg = format; arg != nil; arg = va_arg(args, NSString*))
    {
        [self.arr_no_of_Button addObject:arg];
    }
    va_end(args);
    
    //self.lblHeader=alertTitle;
    self.lbldesc = alertMsg;
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewController.navigationController.view addSubview:self];
    [self layoutPCALertView:viewController];
   
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9]];
    
    UIView *viewAlert = [[UIView alloc] init];
    [viewAlert setBackgroundColor:[UIColor colorWithRed:252/255.0 green:180/255.0 blue:0/255.0 alpha:1]];
    [viewAlert setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewAlert setClipsToBounds:YES];
    [viewAlert.layer setCornerRadius:5.0];
    [self addSubview:viewAlert];
    [self layingOutInnerAlertViews:viewAlert];
}





-(void)layoutPCALertView:(UIViewController *)viewController
{
     
    [viewController.navigationController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[self]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(self)]];
    
    [viewController.navigationController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[self]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(self)]];
}
-(void)layingOutInnerAlertViews:(UIView *)viewAlert
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
   // CGFloat screenHeight = screenSize.height;
    
    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:viewAlert attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
    [self addConstraint:xCenterConstraint];
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:viewAlert attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
    [self addConstraint:yCenterConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:viewAlert attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:screenWidth -40]];
     [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=10)-[viewAlert]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(viewAlert)]];
    
    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:viewAlert attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:171]];
    [self allocingAlertViews:viewAlert];
    
}
-(void)allocingAlertViews:(UIView *)viewALert
{
//    UILabel *lblHeader = [[UILabel alloc] init];
//    [lblHeader setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [viewALert addSubview:lblHeader];
//     [lblHeader setTextAlignment:NSTextAlignmentCenter];
//    [lblHeader setText:self.lblHeader];
//    [lblHeader setFont:CAFETA(24)];
//    [lblHeader setTextColor:[Utility colorWithRGBA:0x303030FF]];
//    [self trackingFor:lblHeader withtracking:50 withFontSize:24];
   
    /*
     H7
     Helvetica Neue Bold 16PX
     #303030
     */
   // [lblHeader setBackgroundColor:[UIColor whiteColor]];
//    UIView *imagebackView = [[UIView alloc] init];
//    [imagebackView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    STRImageView *iconImage = [[STRImageView alloc] initWithImage:[UIImage imageNamed:@"iconedititem"]];
//    //[iconImage setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [viewALert addSubview:iconImage];
//    [viewALert addSubview:imagebackView];
    
    
    PClbldescAlertView
    *lbldescription = [[PClbldescAlertView alloc] init];
    [lbldescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewALert addSubview:lbldescription];
    [lbldescription setText:self.lbldesc];
    lbldescription.numberOfLines=0;
    [lbldescription setTextAlignment:NSTextAlignmentCenter];
        [lbldescription setBackgroundColor:[UIColor colorWithRed:252/255.0 green:180/255.0 blue:0/255.0 alpha:1]];
    [lbldescription setFont:[UIFont fontWithName:@"SourceSansPro-Semibold" size:16.0f]];
    [lbldescription setTextColor:[UIColor blackColor]];

    
    UIView *contrainerForButton = [[UIView alloc] init];
    [contrainerForButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewALert addSubview: contrainerForButton];
    [contrainerForButton setBackgroundColor:[UIColor greenColor]];

    [self layingOutinnerViewsofALert:viewALert forheader:nil withdescrip:lbldescription buttonContainer:contrainerForButton ];
    
}

-(void)layingOutinnerViewsofALert:(UIView *)viewAlert forheader:(UIView *)lbl withdescrip:(UILabel *)lblDesc buttonContainer:(UIView *)view
{
 
//    [viewAlert addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[lbl]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(lbl)]];
////    
//    [viewAlert addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[lbl(==51)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(lbl)]];
    
    [viewAlert addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[lblDesc]-(10)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(lblDesc)]];
    
    [viewAlert addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(30)-[lblDesc]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(lblDesc)]];
    
    [viewAlert addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    
    [viewAlert addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lblDesc]-(30)-[view(==50)]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(view,lblDesc)]];
    //[lbl layoutIfNeeded];
   // [self underLine:lbl];
   [self buttonAllocing:view];
}


-(void)buttonAllocing:(UIView *)view
{
    for (self.no_of_buttons=0; self.no_of_buttons<[self.arr_no_of_Button count]; self.no_of_buttons++) {
        PCAlertViewButton *btn = [[PCAlertViewButton alloc] init];
        btn.tag =  self.no_of_buttons;
        [self.arrButton addObject:btn];
       
    }
    [self layingoutBtns:view];
}
-(void)layingoutBtns:(UIView *)view
{
    UIButton *previous;
    for (self.no_of_buttons=0; self.no_of_buttons<[self.arr_no_of_Button count]; self.no_of_buttons++)  {
       PCAlertViewButton *btn = (PCAlertViewButton *)([self.arrButton objectAtIndex:self.no_of_buttons]);
        [btn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        // btn.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        [view addSubview:btn];
//        [btn.layer setBorderColor:[Utility colorWithRGBA:0xF2F2F2FF].CGColor];
//        [btn.layer setBorderWidth:0.3];
        [btn addTarget:self
                   action:@selector(btnClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTitle:[self.arr_no_of_Button objectAtIndex:self.no_of_buttons] forState:UIControlStateNormal];

        
        [btn.titleLabel setFont:[UIFont fontWithName:@"SourceSansPro-Semibold" size:22.0f]];
         [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self trackingFor:btn.titleLabel withtracking:50 withFontSize:24];
        
        if (previous == nil) {
            
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[btn]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-5)-[btn]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        }
        
        else
        {
            
            [view addConstraint:[NSLayoutConstraint
                                 constraintWithItem:btn
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:0
                                 toItem:previous
                                 attribute:NSLayoutAttributeWidth
                                 multiplier:1.0
                                 constant:0]];
            
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previous]-(0)-[btn]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(previous,btn)]];
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-5)-[btn]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        }
        
        
        if (self.no_of_buttons == ([self.arrButton count] -1) )
        {
            
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[btn]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
            
        } previous=btn;
    }
}

#pragma mark:- custom methods
-(void)btnClicked:(UIButton *)btn
{
    
    [self removeFromSuperview];
    
    if(self.tag==TRANSACTIONCANCELTAG)
        {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.oss.poptoshowselection" object:nil];
        }
    else if ([self.delegate respondsToSelector:@selector(alertClickedBtn:alertView:)]) {
        [self.delegate alertClickedBtn:btn alertView:self];
    }
}

-(void)trackingFor:(UILabel *)lbl withtracking:(CGFloat )tracking withFontSize:(NSInteger)fontSize
{
    NSMutableAttributedString* attrStr1 = [[NSMutableAttributedString alloc] initWithString: lbl.text];
    [attrStr1 addAttribute:NSKernAttributeName value:@((tracking*fontSize)/1000.00) range:NSMakeRange(0, attrStr1.length)];
    lbl.attributedText=[attrStr1 copy];
}

-(void)underLine:(UILabel *)lbl
{
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(lbl.frame.origin.x , lbl.frame.origin.y + lbl.frame.size.height-2)];
    [linePath addLineToPoint:CGPointMake(lbl.frame.origin.x +lbl.frame.size.width , lbl.frame.origin.y + lbl.frame.size.height-2)];
    line.lineWidth = 2.0;
    line.path=linePath.CGPath;
    line.strokeColor = [UIColor grayColor].CGColor;
    [[lbl layer] addSublayer:line];
}

@end
