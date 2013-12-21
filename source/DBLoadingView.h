#import "prefix.h"

@interface DBLoadingView : UIView {
    UIView *trans;
    UIActivityIndicatorView *activity;
    UILabel *label;
}
@property(readonly) UILabel *label;
-(void)hide;
@end