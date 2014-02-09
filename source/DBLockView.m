#import "DBLockView.h"
@implementation DBLockView
-(void)removeFromSuperview{
    [super removeFromSuperview];
    [self.delegate didRemoveFromSuperview];
}
@end
