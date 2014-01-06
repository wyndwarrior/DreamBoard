#import "DBButton.h"

@implementation DBButton
-(id)initWithDict:(NSDictionary *)dict{
	self = [super init];
	
	button = [[UIButton alloc] init];
	[button addTarget:self action:@selector(doActions) forControlEvents:UIControlEventTouchUpInside];
	
	if(dict[@"Actions"])
		actions = dict[@"Actions"];
    
	if(dict[@"Image"])
		[button setImage:
		 [UIImage imageWithContentsOfFile:
		  [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,dict[@"Image"]]]] forState:UIControlStateNormal];
    
	[self addSubview:button];
	
	return self;
}

-(void)doActions{
	for(NSString *action in actions)
		[DBActionParser parseAction:action];
}

-(void)setFrame:(CGRect)frame{
	[super setFrame:frame];
	[button setFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
}


@end
