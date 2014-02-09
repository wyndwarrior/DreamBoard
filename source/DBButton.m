#import "DBButton.h"

@interface DBButton ()

@property(nonatomic, strong) UIButton *button;
@property(nonatomic, strong) NSArray *actions;

- (void)doActions;

@end


@implementation DBButton
-(id)initWithDict:(NSDictionary *)dict{
	self = [super init];
	
    if( self ){
        self.button = [[UIButton alloc] init];
        [self.button addTarget:self action:@selector(doActions) forControlEvents:UIControlEventTouchUpInside];
        
        if(dict[@"Actions"])
            self.actions = dict[@"Actions"];
        
        if(dict[@"Image"])
            [self.button setImage:
             [UIImage imageWithContentsOfFile:
              [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,dict[@"Image"]]]] forState:UIControlStateNormal];
        
        [self addSubview:self.button];
    }
	
	return self;
}

-(void)doActions{
    [DBActionParser parseActionArray:self.actions];
}

-(void)setFrame:(CGRect)frame{
	[super setFrame:frame];
	[self.button setFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
}


@end
