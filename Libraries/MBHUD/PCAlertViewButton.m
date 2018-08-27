#import "PCAlertViewButton.h"

@implementation PCAlertViewButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void) setHighlighted:(BOOL)highlighted
{
    if(highlighted) {
       
        [self setBackgroundColor:[UIColor blackColor]];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.layer setBorderColor:[UIColor blackColor].CGColor];
        //[self.layer setBorderWidth:1];
    } else {
        
        [self setBackgroundColor:[UIColor whiteColor]];
       [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        //[self.layer setBorderWidth:1];
     
    }
    [super setHighlighted:highlighted];
}

@end
