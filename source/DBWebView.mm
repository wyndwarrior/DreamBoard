#import "DBWebView.h"

extern "C" void UIKeyboardEnableAutomaticAppearance();
extern "C" void UIKeyboardDisableAutomaticAppearance();

@implementation DBWebView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {	
    UIView *theView = [super hitTest:point withEvent:event];
    if(theView){
        UIKeyboardEnableAutomaticAppearance();
        if(!timer)
            timer = [NSTimer scheduledTimerWithTimeInterval:1 
                                                     target:self 
                                                   selector:@selector(hideKb) 
                                                   userInfo:nil
                                                    repeats:YES];
    }
    return theView;
}
- (void)hideKb{
    if([[UIKeyboard activeKeyboard] delegate]!=nil && [[[[UIKeyboard activeKeyboard] delegate] description] hasPrefix:@"<<UIThreadSafeNode"])return;
    UIKeyboardDisableAutomaticAppearance();
    [timer invalidate];
    timer = nil;
}


- (void)dealloc
{
    [timer invalidate];
}

@end
