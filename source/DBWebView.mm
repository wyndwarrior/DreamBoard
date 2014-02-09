#import "DBWebView.h"

extern "C" void UIKeyboardEnableAutomaticAppearance();
extern "C" void UIKeyboardDisableAutomaticAppearance();

@interface DBWebView ()

@property(nonatomic, strong) NSTimer *timer;

@end


@implementation DBWebView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {	
    UIView *theView = [super hitTest:point withEvent:event];
    if(theView){
        if( !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ){
            UIKeyboardEnableAutomaticAppearance();
            if(!self.timer)
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self 
                                                       selector:@selector(hideKb) 
                                                       userInfo:nil
                                                        repeats:YES];
        }
    }
    return theView;
}
- (void)hideKb{
    //TODO: hack much?
    if([[UIKeyboard activeKeyboard] delegate]!=nil && [[[[UIKeyboard activeKeyboard] delegate] description] hasPrefix:@"<<UIThreadSafeNode"])return;
    if( !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") )
        UIKeyboardDisableAutomaticAppearance();
    [self.timer invalidate];
    self.timer = nil;
}


- (void)dealloc
{
    [self.timer invalidate];
}

@end
