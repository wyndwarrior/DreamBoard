#import "DBLoadingView.h"
@implementation DBLoadingView
@synthesize label;
-(id)initWithFrame:(CGRect)frame{
    [super initWithFrame:frame];
    self.alpha = 0;
    trans = [[UIView alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
    trans.backgroundColor = UIColor.blackColor;
    trans.alpha = .6;
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activity.frame = CGRectMake(5, 0, frame.size.height, frame.size.height);
    activity.transform = CGAffineTransformMakeScale(.75,.75);
    [activity startAnimating];
    label = [[UILabel alloc] initWithFrame:CGRectMake(5+frame.size.height+5,0,frame.size.width-10-frame.size.height,frame.size.height)];
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:trans];
    [self addSubview:activity];
    [self addSubview:label];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];
    self.alpha = 1;
    [UIView commitAnimations];
    return self;
}

-(void)hide{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.25];
    [UIView setAnimationDelegate:self]; 
    [UIView setAnimationDidStopSelector:@selector(done)];
    self.alpha = 0;
    [UIView commitAnimations];
}

-(void)done{
    [self removeFromSuperview];
}

-(void)dealloc{
    [trans release];
    [activity release];
    [label release];
    [super dealloc];
}

@end
