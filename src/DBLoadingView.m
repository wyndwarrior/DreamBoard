#import "DBLoadingView.h"

@interface DBLoadingView ()

@property(nonatomic, strong) UIView *trans;
@property(nonatomic, strong) UIActivityIndicatorView *activity;

@end


@implementation DBLoadingView
@synthesize label;
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.alpha = 0;
        self.trans = [[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
        self.trans.backgroundColor = UIColor.blackColor;
        self.trans.alpha = .6;
        
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activity.frame = CGRectMake(5, 0, frame.size.height, frame.size.height);
        self.activity.transform = CGAffineTransformMakeScale(.75,.75);
        [self.activity startAnimating];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(5+frame.size.height+5,0,frame.size.width-10-frame.size.height,frame.size.height)];
        self.label.font = [UIFont boldSystemFontOfSize:12];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.trans];
        [self addSubview:self.activity];
        [self addSubview:self.label];
        
        [UIView animateWithDuration:.25 animations:^{
            self.alpha = 1;
        }];
    }
    return self;
}

-(void)hide{
    [UIView animateWithDuration:.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
