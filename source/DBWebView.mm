#import "DBWebView.h"

extern "C" void UIKeyboardEnableAutomaticAppearance();
extern "C" void UIKeyboardDisableAutomaticAppearance();

@implementation DBWebView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {	
    UIView *theView = [super hitTest:point withEvent:event];
    if(theView){
        if( !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ){
            UIKeyboardEnableAutomaticAppearance();
            if(!timer)
                timer = [NSTimer scheduledTimerWithTimeInterval:1 
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
    [timer invalidate];
    timer = nil;
}


- (void)dealloc
{
    [timer invalidate];
}

@end
