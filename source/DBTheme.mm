#import "DBTheme.h"
extern "C" void UIKeyboardDisableAutomaticAppearance();

@implementation DBTheme
@synthesize isEditing;
- (id)initWithName:(NSString *)name window:(UIWindow *)_window
{
    self = [super init];
    if (self) {
        themeName = [name retain];
        window = [_window retain];
        //NSLog(@"%@", dictTheme);
        allAppIcons = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)loadTheme{
    UIKeyboardDisableAutomaticAppearance();
    if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Info.plist", MAINPATH, themeName]]){
        [DreamBoard throwRuntimeException:@"Info.plist not found" shouldExit:YES];
        return;
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Info.plist", MAINPATH, themeName]];
    
    if((![dict objectForKey:@"Plist"] || ![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/%@.plist", MAINPATH, themeName, [dict objectForKey:@"Plist"]]]) && ![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName]]){
        [DreamBoard throwRuntimeException:@"Theme plist not found" shouldExit:YES];
        [dict release];
        return;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName]])
        dictTheme = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName]] mutableCopy];
    else
        dictTheme = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/%@.plist", MAINPATH, themeName, [dict objectForKey:@"Plist"]]] mutableCopy];
    [dict release];
    
    if([dictTheme objectForKey:@"DynamicViews"]){
        dictDynViews = [[dictTheme objectForKey:@"DynamicViews"] mutableCopy];
        [dictTheme setObject:dictDynViews forKey:@"DynamicViews"];
    }
    
    dictViews = [[NSMutableDictionary alloc] init];
    
    if([dictTheme objectForKey:@"Variables"]){
        dictVars = [[dictTheme objectForKey:@"Variables"] mutableCopy];
        [dictTheme setObject:dictVars forKey:@"Variables"];
    }
    
    dictViewsInteraction = [[NSMutableDictionary alloc] init];
    dictViewsToggled = [[NSMutableDictionary alloc] init];
    dictViewsToggledInteraction = [[NSMutableDictionary alloc] init];
    
    if([dictTheme objectForKey:@"Functions"])
        functions = [[dictTheme objectForKey:@"Functions"] retain];
    
    if([dictTheme objectForKey:@"LabelStyle"])
        labelStyle = [[dictTheme objectForKey:@"LabelStyle"] retain];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Images/Badge.png", MAINPATH, themeName]])
        badgeImage = [[UIImage alloc] initWithContentsOfFile:
                      [NSString stringWithFormat:@"%@/DreamBoard/%@/Images/Badge.png", MAINPATH, themeName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Images/IconOverlay.png", MAINPATH, themeName]])
        overlayImage = [[UIImage alloc] initWithContentsOfFile:
                        [NSString stringWithFormat:@"%@/DreamBoard/%@/Images/IconOverlay.png", MAINPATH, themeName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Images/IconShadow.png", MAINPATH, themeName]])
        shadowImage = [[UIImage alloc] initWithContentsOfFile:
                       [NSString stringWithFormat:@"%@/DreamBoard/%@/Images/IconShadow.png", MAINPATH, themeName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Images/IconMask.png", MAINPATH, themeName]])
        maskImage = [[UIImage alloc] initWithContentsOfFile:
                     [NSString stringWithFormat:@"%@/DreamBoard/%@/Images/IconMask.png", MAINPATH, themeName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Images/AppIconIndicator.png", MAINPATH, themeName]])
        editImage = [[UIImage alloc] initWithContentsOfFile:
                     [NSString stringWithFormat:@"%@/DreamBoard/%@/Images/AppIconIndicator.png", MAINPATH, themeName]];
    
    [DBAppIcon setCacheLocation:[NSString stringWithFormat:@"%@/DreamBoard/_library/Cache/Icons/%@",MAINPATH, themeName]];
    
    [self cacheIfNeeded];
    
    mainView = [[UIView alloc] initWithFrame:window.frame];
    mainView.backgroundColor = UIColor.blackColor;
    mainView.clipsToBounds = YES;
    if([dictTheme objectForKey:@"MainView"]){
        NSMutableArray *arrayMainView = [[dictTheme objectForKey:@"MainView"] mutableCopy];
        for(int i = 0; i<(int)arrayMainView.count; i++){
            NSMutableDictionary *tmp = [[arrayMainView objectAtIndex:i] mutableCopy];
            UIView *view = [self loadView:tmp];
            [mainView insertSubview:view atIndex:0];
            [view release];
            [arrayMainView replaceObjectAtIndex:i withObject:tmp];
            [tmp release];
        }
        [dictTheme setObject:arrayMainView forKey:@"MainView"];
        [arrayMainView release];
    }
    
    if([dictTheme objectForKey:@"Onload"]){
        for(NSString *action in [dictTheme objectForKey:@"Onload"])
            [DBActionParser parseAction:action];
    }
    
    [window addSubview:mainView];
}

-(UIView *)loadView:(NSMutableDictionary *)dict{
    UIView *view = nil;
    
    /*if(![dict objectForKey:@"ViewType"]){
        [DreamBoard throwRuntimeException:@"Missing ViewType" shouldExit:NO];
        return nil;
    }*/
    
	NSString *type = [dict objectForKey:@"ViewType"];
	
	//check for type
	if([type isEqualToString:@"ScrollView"])
	{
		//create an uiscrollview
		DBScrollView *temp = [[DBScrollView alloc] init];
		
		//content size
		if([dict objectForKey:@"ContentWidth"] && [dict objectForKey:@"ContentHeight"])
			[temp setContentSize:CGSizeMake([[dict objectForKey:@"ContentWidth"] floatValue], 
											[[dict objectForKey:@"ContentHeight"] floatValue])];
		
		//scrollbars
		if([dict objectForKey:@"VerticalScrollBars"])
			temp.showsVerticalScrollIndicator = [[dict objectForKey:@"VerticalScrollBars"] boolValue];
		if([dict objectForKey:@"HorizontalScrollBars"])
			temp.showsHorizontalScrollIndicator = [[dict objectForKey:@"HorizontalScrollBars"] boolValue];
		
		//scrolling enabled
		if([dict objectForKey:@"ScrollingEnabled"])
			temp.scrollEnabled = [[dict objectForKey:@"ScrollingEnabled"] boolValue];
        
		//recursively add subviews
		if([dict objectForKey:@"Subviews"]){
			NSMutableArray *ray = [[dict objectForKey:@"Subviews"] mutableCopy];
			for(int i = 0; i<(int)ray.count; i++){
				NSMutableDictionary *tempDict = [[ray objectAtIndex:i] mutableCopy];
				UIView *v = [self loadView:tempDict];
				[temp insertSubview:v atIndex:0];
				[ray replaceObjectAtIndex:i withObject:tempDict];
                [v release];
				[tempDict release];
			}
			[dict setObject:ray forKey:@"Subviews"];
			[ray release];
		}
		
		//set content offset
		if([dict objectForKey:@"ContentOffsetX"] && [dict objectForKey:@"ContentOffsetY"])
			[temp setContentOffset:CGPointMake([[dict objectForKey:@"ContentOffsetX"] floatValue], [[dict objectForKey:@"ContentOffsetY"] floatValue]) animated:NO];
		
		//set paging
		if([dict objectForKey:@"Paging"])
			temp.pagingEnabled = [[dict objectForKey:@"Paging"] boolValue];
        
        if([dict objectForKey:@"Actions"])
            temp.actions = [dict objectForKey:@"Actions"];
        
		view = temp;
	}
	else if([type isEqualToString:@"WebView"])
	{
		//create an uiwebdocview
		UIWebDocumentView *temp = [[UIWebDocumentView alloc] init];
		
		//load the request
		if([dict objectForKey:@"URL"])
			[temp loadRequest:
			 [NSURLRequest requestWithURL:
			  [NSURL fileURLWithPath:
               [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,[dict objectForKey:@"URL"]]]]]];
        
		//clear the background
		[temp setBackgroundColor:[UIColor clearColor]];
		[temp setOpaque:NO];
		
		view = (UIView*)temp;
	}
    else if([type isEqualToString:@"AdvWebView"])
    {
        DBWebView *temp = [[DBWebView alloc] init];

        if([dict objectForKey:@"URL"])
            [temp loadRequest:
             [NSURLRequest requestWithURL:
              [NSURL fileURLWithPath:
               [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,[dict objectForKey:@"URL"]]]]]];

        //clear the background
        temp.backgroundColor = [UIColor clearColor];
        temp.opaque = NO;

        view = temp;
    }
	else if([type isEqualToString:@"ImageView"])
	{
		//create an uiimageview
		UIImageView *temp = [[UIImageView alloc] init];
		
		//set the image
		if([dict objectForKey:@"Image"])
			temp.image = [UIImage imageWithContentsOfFile:
						  [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,[dict objectForKey:@"Image"]]]];
		
		view = temp;
	}
	else if([type isEqualToString:@"Button"])
	{
		//create a new dreamboard button
		DBButton *temp = [[DBButton alloc] initWithDict:dict];
		
		view = temp;
	}
	else if([type isEqualToString:@"AppIcon"])
	{
		//create a new dreamboard button
		DBAppIcon *temp = [[DBAppIcon alloc] init];
        
        temp.application = [self findApp:[dict objectForKey:@"BundleID"]];
        temp.dict = dict;
        
        temp.badgeImage = badgeImage;
        temp.overlayImage = ([dict objectForKey:@"Overlay"]==nil?YES:[[dict objectForKey:@"Overlay"] boolValue])?overlayImage:nil;
        temp.shadowImage = ([dict objectForKey:@"Shadow"]==nil?YES:[[dict objectForKey:@"Shadow"] boolValue])?shadowImage:nil;
        temp.maskImage = ([dict objectForKey:@"MaskImage"]==nil?YES:[[dict objectForKey:@"MaskImage"] boolValue])?maskImage:nil;
        temp.editImage = editImage;
        temp.labelStyle = [dict objectForKey:@"LabelStyle"]==nil?labelStyle:[dict objectForKey:@"LabelStyle"];
        temp.cacheHeight = [[dict objectForKey:@"FrameHeight"] intValue];
        temp.cacheWidth = [[dict objectForKey:@"FrameWidth"] intValue];
        
        [self setViewDefaults:temp withDict:dict];
        
        [temp loadIcon:isEditing shouldCache:NO];
        
		view = temp;
	}
	else if([type isEqualToString:@"AppGrid"])
	{
		//create a new dreamboard grid
		DBGrid *temp = [[DBGrid alloc] initWithDict:dict];
        [self setViewDefaults:temp withDict:dict];
        temp.badgeImage = badgeImage;
        temp.overlayImage = overlayImage;
        temp.shadowImage = shadowImage;
        temp.maskImage = maskImage;
        temp.editImage = editImage;
        [temp loadGrid];
        if([dict objectForKey:@"ScrollingEnabled"])
			temp.scrollEnabled = [[dict objectForKey:@"ScrollingEnabled"] boolValue];
        if([dict objectForKey:@"Paging"])
			temp.pagingEnabled = [[dict objectForKey:@"Paging"] boolValue];
		view = temp;
	}
	else
	{
		//create a regular uiview
		view = [[UIView alloc] init];
		
		//recursively add subviews
		if([dict objectForKey:@"Subviews"]){
			NSMutableArray *ray = [[dict objectForKey:@"Subviews"] mutableCopy];
			for(int i = 0; i<(int)ray.count; i++){
				NSMutableDictionary *tempDict = [[ray objectAtIndex:i] mutableCopy];
				UIView *v = [self loadView:tempDict];
				[view insertSubview:v atIndex:0];
				[ray replaceObjectAtIndex:i withObject:tempDict];
				[tempDict release];
				[v release];
			}
			[dict setObject:ray forKey:@"Subviews"];
			[ray release];
		}
	}
	
	//set univeral uiview settings
	[self setViewDefaults:view withDict:dict];
	
	return view;
}

-(void)setViewDefaults:(UIView *)view withDict:(NSDictionary *)dict{
    CGRect frame = CGRectMake(0,0,0,0);
	if([dict objectForKey:@"FrameWidth"])
		frame.size.width = [[dict objectForKey:@"FrameWidth"] floatValue];
	
	if([dict objectForKey:@"FrameHeight"])
		frame.size.height = [[dict objectForKey:@"FrameHeight"] floatValue];
	
	if([dict objectForKey:@"FrameX"])
		frame.origin.x = [[dict objectForKey:@"FrameX"] floatValue];
	
	if([dict objectForKey:@"FrameY"])
		frame.origin.y = [[dict objectForKey:@"FrameY"] floatValue];
    
    if([dict objectForKey:@"Frame"]){
        NSArray *ray= [[dict objectForKey:@"Frame"] componentsSeparatedByString:@","];
        frame = CGRectMake([[ray objectAtIndex:0] floatValue], 
                           [[ray objectAtIndex:1] floatValue], 
                           [[ray objectAtIndex:2] floatValue], 
                           [[ray objectAtIndex:3] floatValue]);
    }
	
	view.frame = frame;
	
	//set user interaction
	if([dict objectForKey:@"UserInteraction"])
		view.userInteractionEnabled = [[dict objectForKey:@"UserInteraction"] boolValue];
	
	//set alpha
	if([dict objectForKey:@"Alpha"])
		view.alpha = [[dict objectForKey:@"Alpha"] floatValue];
	
	//set clip to bounds
	if([dict objectForKey:@"ClipToBounds"])
		view.clipsToBounds = [[dict objectForKey:@"ClipToBounds"] boolValue];
    
    if([dict objectForKey:@"Rotation"])
        view.transform = CGAffineTransformMakeRotation([[dict objectForKey:@"Rotation"] intValue]*M_PI/180.);
    
    if([dict objectForKey:@"Scale"])
        view.transform = CGAffineTransformMakeScale([[dict objectForKey:@"Scale"] floatValue], [[dict objectForKey:@"Scale"] floatValue]);
    
    if([dict objectForKey:@"id"]){
        NSString *ID = [dict objectForKey:@"id"];
        [dictViews setObject:view forKey:ID];
        if([dict objectForKey:@"UserInteraction"])
            [dictViewsInteraction setObject:[dict objectForKey:@"UserInteraction"] forKey:ID];
        else
            [dictViewsInteraction setObject:[NSNumber numberWithBool:YES] forKey:ID];
        if([dict objectForKey:@"Toggled"]){
            [dictViewsToggled setObject:[dict objectForKey:@"Toggled"] forKey:ID];
            if([dict objectForKey:@"ToggledInteraction"])
                [dictViewsToggledInteraction setObject:[dict objectForKey:@"ToggledInteraction"] forKey:ID];
        }
    }
}

-(id)findApp:(NSString*)app{
    for(id tmp in [DreamBoard sharedInstance].appsArray)
        if([[tmp leafIdentifier] isEqualToString:app])
            return tmp;
    return nil;
}

- (void)dealloc
{
    isDealloc = YES;
    [badgeImage release];
    [overlayImage release];
    [shadowImage release];
    [maskImage release];
    [editImage release];
    
    [window release];
    [themeName release];
    
    [dictTheme release];
    [dictDynViews release];
    [dictViews release];
    [dictVars release];
    
    [dictViewsInteraction release];
    [dictViewsToggled release];
    [dictViewsToggledInteraction release];
    
    [functions release];
    [labelStyle release];
    
    [mainView removeFromSuperview];
    [mainView release];
    
    [allAppIcons release];
    
    [super dealloc];
}

-(void)savePlist{
    [dictTheme writeToFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName] atomically:YES];
}

-(void)cacheIfNeeded{
    NSMutableArray *grids = [[NSMutableArray alloc] init];
    if([dictTheme objectForKey:@"MainView"])
    for(NSDictionary *dict in [dictTheme objectForKey:@"MainView"])
        [self getGrids:grids dict:dict];
    if([dictTheme objectForKey:@"DynamicViews"])
    for(NSString *str in [dictTheme objectForKey:@"DynamicViews"])
        [self getGrids:grids dict:[[dictTheme objectForKey:@"DynamicViews"] objectForKey:str]];
    for(NSDictionary *dict in grids)
        for(id app in [DreamBoard sharedInstance].appsArray)
            if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@-%dx%d.png", [DBAppIcon cacheLocation], [app leafIdentifier], [[dict objectForKey:@"IconWidth"] intValue], [[dict objectForKey:@"IconHeight"] intValue]]]){
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                DBAppIcon *temp = [[DBAppIcon alloc] init];
                
                temp.application = app;
                temp.badgeImage = badgeImage;
                temp.overlayImage = overlayImage;
                temp.shadowImage = shadowImage;
                temp.maskImage = maskImage;
                temp.editImage = editImage;
                temp.labelStyle = [dict objectForKey:@"LabelStyle"]==nil?labelStyle:[dict objectForKey:@"LabelStyle"];
                temp.cacheHeight = [[dict objectForKey:@"IconHeight"] intValue];
                temp.cacheWidth = [[dict objectForKey:@"IconWidth"] intValue];
                temp.frame = CGRectMake(0, 0, [[dict objectForKey:@"IconWidth"] intValue], [[dict objectForKey:@"IconHeight"] intValue]);
                [temp loadIcon:NO shouldCache:YES];
                [temp release];
                
                [pool drain];
            }
    [grids release];
        
    
}

-(void)getGrids:(NSMutableArray *)ray dict:(NSDictionary *)dict{
    if([[dict objectForKey:@"ViewType"] isEqualToString:@"AppGrid"])
        [ray addObject:dict];
    else if([dict objectForKey:@"Subviews"])
        for(NSDictionary *_dict in [dict objectForKey:@"Subviews"])
            [self getGrids:ray dict:_dict];
}

-(void)didUndim:(id)awayView{
    if([dictTheme objectForKey:@"LockView"] && !lockView){
        lockView = [[DBLockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        lockView.backgroundColor = UIColor.blackColor;
        lockView.delegate = self;
        NSMutableArray *temp = [[dictTheme objectForKey:@"LockView"] mutableCopy];
        [dictTheme setObject:temp forKey:@"LockView"];
        for(int i = 0; i<(int)temp.count; i++){
            NSMutableDictionary *tempDict = [[temp objectAtIndex:i] mutableCopy];
            [temp replaceObjectAtIndex:i withObject:tempDict];
            UIView *tempView = [self loadView:tempDict];
            [lockView insertSubview:tempView atIndex:0];
            [tempView release];
            [tempDict release];
        }
        [temp release];
        [awayView addSubview:lockView];
    }
}
-(void)didDim{
    if(lockView)[lockView removeFromSuperview];
}

-(void)didRemoveFromSuperview{
    [lockView release];
    lockView = nil;
}

@end
