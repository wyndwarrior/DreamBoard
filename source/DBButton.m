#import "DBButton.h"

@implementation DBButton
-(id)initWithDict:(NSDictionary *)dict{
	self = [super init];
	
	//create our new button
	button = [[UIButton alloc] init];
	[button addTarget:self action:@selector(doActions) forControlEvents:UIControlEventTouchUpInside];
	
	//grab actions
	if([dict objectForKey:@"Actions"])
		actions = [[dict objectForKey:@"Actions"] retain];
    
	//grab button image
	if([dict objectForKey:@"Image"])
		[button setImage:
		 [UIImage imageWithContentsOfFile:
		  [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,[dict objectForKey:@"Image"]]]] forState:UIControlStateNormal];
    
	//add it to our view
	[self addSubview:button];
	
	return self;
}

-(void)doActions{
	//go through all the actions
	for(NSString *action in actions)
		[DBActionParser parseAction:action];
}

-(void)setFrame:(CGRect)frame{
	//update our button frame as well
	[super setFrame:frame];
	[button setFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
}

-(void)dealloc{
    [button release];
    [actions release];
	[super dealloc];
}

@end
