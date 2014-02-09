#import "ExposeSwitcherObject.h"


@implementation ExposeSwitcherObject

@synthesize row, col, index, name;

- (id)initWithName:(NSString*)_name;
{
    self = [super init];
    if (self) {
        name = _name;
        btn = [[UIButton alloc] init];
        if( !([self.name isEqualToString:@"Default"] && [[DreamBoard sharedInstance] sbView]))
            [btn setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", [ExposeSwitcher sharedInstance].cachePath ,_name]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
        btn.contentMode = UIViewContentModeScaleToFill;
        
        UILongPressGestureRecognizer * recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(goHold:)];    
        [(id)btn addGestureRecognizer:recognizer];
        
        shadow = [[UIImageView alloc] init];
        shadow.image = [ExposeSwitcher shadowImage];
        label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:11];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = _name;
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(.7,.7);
        
        if( [self.name isEqualToString:@"Default"] && [[DreamBoard sharedInstance] sbView] ){
            self.sbView = [[DreamBoard sharedInstance] removeSbView];
            [self addSubview:self.sbView];
        }else
            [self addSubview:shadow];
        [self addSubview:label];
        [self addSubview:btn];
        
        self.clipsToBounds = NO;
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if( self.sbView.superview == self)
        [self.sbView setFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [btn setFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat h = bounds.size.height,
    w = bounds.size.width;
    self.sbView.transform = CGAffineTransformMakeScale(frame.size.width/w, frame.size.height/h);
    [self.sbView setFrame:CGRectMake(0,0,frame.size.width, frame.size.height)];
    [shadow setFrame:CGRectMake(-20,-20,frame.size.width+40, frame.size.height+40)];
    [label setFrame:CGRectMake(0,frame.size.height+4, frame.size.width, 12)];
}


-(void)go:(id)sender{
    [[ExposeSwitcher sharedInstance] switchTo:self];
}

-(void)goHold:(id)sender{
    if([sender state]==1)
        [[ExposeSwitcher sharedInstance] didHold:self];
}

@end
