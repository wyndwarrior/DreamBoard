#import "DBLockView.h"
@implementation DBLockView
@synthesize delegate;
-(void)removeFromSuperview{
    [super removeFromSuperview];
    [delegate didRemoveFromSuperview];
}
@end
