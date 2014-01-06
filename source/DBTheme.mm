#import "DBTheme.h"
extern "C" void UIKeyboardDisableAutomaticAppearance();

@implementation DBTheme
@synthesize isEditing;
- (id)initWithName:(NSString *)name window:(UIWindow *)_window
{
    self = [super init];
    if (self) {
        themeName = name;
        window = _window;
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
    
    if((!dict[@"Plist"] || ![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/%@.plist", MAINPATH, themeName, dict[@"Plist"]]]) && ![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName]]){
        [DreamBoard throwRuntimeException:@"Theme plist not found" shouldExit:YES];
        return;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName]])
        dictTheme = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName]] mutableCopy];
    else
        dictTheme = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/%@.plist", MAINPATH, themeName, dict[@"Plist"]]] mutableCopy];
    
    if(dictTheme[@"DynamicViews"]){
        dictDynViews = [dictTheme[@"DynamicViews"] mutableCopy];
        dictTheme[@"DynamicViews"] = dictDynViews;
    }
    
    dictViews = [[NSMutableDictionary alloc] init];
    
    if(dictTheme[@"Variables"]){
        dictVars = [dictTheme[@"Variables"] mutableCopy];
        dictTheme[@"Variables"] = dictVars;
    }
    
    dictViewsInteraction = [[NSMutableDictionary alloc] init];
    dictViewsToggled = [[NSMutableDictionary alloc] init];
    dictViewsToggledInteraction = [[NSMutableDictionary alloc] init];
    
    if(dictTheme[@"Functions"])
        functions = dictTheme[@"Functions"];
    
    if(dictTheme[@"LabelStyle"])
        labelStyle = dictTheme[@"LabelStyle"];
    
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
    if(dictTheme[@"MainView"]){
        NSMutableArray *arrayMainView = [dictTheme[@"MainView"] mutableCopy];
        for(int i = 0; i<(int)arrayMainView.count; i++){
            NSMutableDictionary *tmp = [arrayMainView[i] mutableCopy];
            UIView *view = [self loadView:tmp];
            [mainView insertSubview:view atIndex:0];
            arrayMainView[i] = tmp;
        }
        dictTheme[@"MainView"] = arrayMainView;
    }
    
    if(dictTheme[@"Onload"]){
        for(NSString *action in dictTheme[@"Onload"])
            [DBActionParser parseAction:action];
    }
    
    [window addSubview:mainView];
}

-(UIView *)loadView:(NSMutableDictionary *)dict{
    UIView *view = nil;
    
    
	NSString *type = dict[@"ViewType"];
	
	if([type isEqualToString:@"ScrollView"])
	{
		DBScrollView *temp = [[DBScrollView alloc] init];
		
		if(dict[@"ContentWidth"] && dict[@"ContentHeight"])
			[temp setContentSize:CGSizeMake([dict[@"ContentWidth"] floatValue], 
											[dict[@"ContentHeight"] floatValue])];
		
		if(dict[@"VerticalScrollBars"])
			temp.showsVerticalScrollIndicator = [dict[@"VerticalScrollBars"] boolValue];
		if(dict[@"HorizontalScrollBars"])
			temp.showsHorizontalScrollIndicator = [dict[@"HorizontalScrollBars"] boolValue];
		
		if(dict[@"ScrollingEnabled"])
			temp.scrollEnabled = [dict[@"ScrollingEnabled"] boolValue];
        
		if(dict[@"Subviews"]){
			NSMutableArray *ray = [dict[@"Subviews"] mutableCopy];
			for(int i = 0; i<(int)ray.count; i++){
				NSMutableDictionary *tempDict = [ray[i] mutableCopy];
				UIView *v = [self loadView:tempDict];
				[temp insertSubview:v atIndex:0];
				ray[i] = tempDict;
			}
			dict[@"Subviews"] = ray;
		}
		
		if(dict[@"ContentOffsetX"] && dict[@"ContentOffsetY"])
			[temp setContentOffset:CGPointMake([dict[@"ContentOffsetX"] floatValue], [dict[@"ContentOffsetY"] floatValue]) animated:NO];
		
		if(dict[@"Paging"])
			temp.pagingEnabled = [dict[@"Paging"] boolValue];
        
        if(dict[@"Actions"])
            temp.actions = dict[@"Actions"];
        
		view = temp;
	}
	else if([type isEqualToString:@"WebView"])
	{
		UIWebDocumentView *temp = [[UIWebDocumentView alloc] init];
		
		if(dict[@"URL"])
			[temp loadRequest:
			 [NSURLRequest requestWithURL:
			  [NSURL fileURLWithPath:
               [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,dict[@"URL"]]]]]];
        
		[temp setBackgroundColor:[UIColor clearColor]];
		[temp setOpaque:NO];
		
		view = (UIView*)temp;
	}
    else if([type isEqualToString:@"AdvWebView"])
    {
        DBWebView *temp = [[DBWebView alloc] init];

        if(dict[@"URL"])
            [temp loadRequest:
             [NSURLRequest requestWithURL:
              [NSURL fileURLWithPath:
               [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,dict[@"URL"]]]]]];

        temp.backgroundColor = [UIColor clearColor];
        temp.opaque = NO;

        view = temp;
    }
	else if([type isEqualToString:@"ImageView"])
	{
		UIImageView *temp = [[UIImageView alloc] init];
		
		if(dict[@"Image"])
			temp.image = [UIImage imageWithContentsOfFile:
						  [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",MAINPATH,dict[@"Image"]]]];
		
		view = temp;
	}
	else if([type isEqualToString:@"Button"])
	{		DBButton *temp = [[DBButton alloc] initWithDict:dict];
		
		view = temp;
	}
	else if([type isEqualToString:@"AppIcon"])
	{
		DBAppIcon *temp = [[DBAppIcon alloc] init];
        
        temp.application = [self findApp:dict[@"BundleID"]];
        temp.dict = dict;
        
        temp.badgeImage = badgeImage;
        temp.overlayImage = (dict[@"Overlay"]==nil?YES:[dict[@"Overlay"] boolValue])?overlayImage:nil;
        temp.shadowImage = (dict[@"Shadow"]==nil?YES:[dict[@"Shadow"] boolValue])?shadowImage:nil;
        temp.maskImage = (dict[@"MaskImage"]==nil?YES:[dict[@"MaskImage"] boolValue])?maskImage:nil;
        temp.editImage = editImage;
        temp.labelStyle = dict[@"LabelStyle"]==nil?labelStyle:dict[@"LabelStyle"];
        temp.cacheHeight = [dict[@"FrameHeight"] intValue];
        temp.cacheWidth = [dict[@"FrameWidth"] intValue];
        
        [self setViewDefaults:temp withDict:dict];
        
        [temp loadIcon:isEditing shouldCache:NO];
        
		view = temp;
	}
	else if([type isEqualToString:@"AppGrid"])
	{
		DBGrid *temp = [[DBGrid alloc] initWithDict:dict];
        [self setViewDefaults:temp withDict:dict];
        temp.badgeImage = badgeImage;
        temp.overlayImage = overlayImage;
        temp.shadowImage = shadowImage;
        temp.maskImage = maskImage;
        temp.editImage = editImage;
        [temp loadGrid];
        if(dict[@"ScrollingEnabled"])
			temp.scrollEnabled = [dict[@"ScrollingEnabled"] boolValue];
        if(dict[@"Paging"])
			temp.pagingEnabled = [dict[@"Paging"] boolValue];
		view = temp;
	}
	else
	{
		view = [[UIView alloc] init];
		
		if(dict[@"Subviews"]){
			NSMutableArray *ray = [dict[@"Subviews"] mutableCopy];
			for(int i = 0; i<(int)ray.count; i++){
				NSMutableDictionary *tempDict = [ray[i] mutableCopy];
				UIView *v = [self loadView:tempDict];
				[view insertSubview:v atIndex:0];
				ray[i] = tempDict;
			}
			dict[@"Subviews"] = ray;
		}
	}
	
	[self setViewDefaults:view withDict:dict];
	
	return view;
}

-(void)setViewDefaults:(UIView *)view withDict:(NSDictionary *)dict{
    CGRect frame = CGRectMake(0,0,0,0);
	if(dict[@"FrameWidth"])
		frame.size.width = [dict[@"FrameWidth"] floatValue];
	
	if(dict[@"FrameHeight"])
		frame.size.height = [dict[@"FrameHeight"] floatValue];
	
	if(dict[@"FrameX"])
		frame.origin.x = [dict[@"FrameX"] floatValue];
	
	if(dict[@"FrameY"])
		frame.origin.y = [dict[@"FrameY"] floatValue];
    
    if(dict[@"Frame"]){
        NSArray *ray= [dict[@"Frame"] componentsSeparatedByString:@","];
        frame = CGRectMake([ray[0] floatValue], 
                           [ray[1] floatValue], 
                           [ray[2] floatValue], 
                           [ray[3] floatValue]);
    }
	
	view.frame = frame;
	
	if(dict[@"UserInteraction"])
		view.userInteractionEnabled = [dict[@"UserInteraction"] boolValue];
	
	if(dict[@"Alpha"])
		view.alpha = [dict[@"Alpha"] floatValue];
	
	if(dict[@"ClipToBounds"])
		view.clipsToBounds = [dict[@"ClipToBounds"] boolValue];
    
    if(dict[@"Rotation"])
        view.transform = CGAffineTransformMakeRotation([dict[@"Rotation"] intValue]*M_PI/180.);
    
    if(dict[@"Scale"])
        view.transform = CGAffineTransformMakeScale([dict[@"Scale"] floatValue], [dict[@"Scale"] floatValue]);
    
    if(dict[@"id"]){
        NSString *ID = dict[@"id"];
        dictViews[ID] = view;
        if(dict[@"UserInteraction"])
            dictViewsInteraction[ID] = dict[@"UserInteraction"];
        else
            dictViewsInteraction[ID] = @YES;
        if(dict[@"Toggled"]){
            dictViewsToggled[ID] = dict[@"Toggled"];
            if(dict[@"ToggledInteraction"])
                dictViewsToggledInteraction[ID] = dict[@"ToggledInteraction"];
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
    [mainView removeFromSuperview];
}

-(void)savePlist{
    [dictTheme writeToFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, themeName] atomically:YES];
}

-(void)cacheIfNeeded{
    NSMutableArray *grids = [[NSMutableArray alloc] init];
    if(dictTheme[@"MainView"])
    for(NSDictionary *dict in dictTheme[@"MainView"])
        [self getGrids:grids dict:dict];
    if(dictTheme[@"DynamicViews"])
    for(NSString *str in dictTheme[@"DynamicViews"])
        [self getGrids:grids dict:dictTheme[@"DynamicViews"][str]];
    for(NSDictionary *dict in grids)
        for(id app in [DreamBoard sharedInstance].appsArray)
            if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@-%dx%d.png", [DBAppIcon cacheLocation], [app leafIdentifier], [dict[@"IconWidth"] intValue], [dict[@"IconHeight"] intValue]]]){
                @autoreleasepool {
                    DBAppIcon *temp = [[DBAppIcon alloc] init];
                    
                    temp.application = app;
                    temp.badgeImage = badgeImage;
                    temp.overlayImage = overlayImage;
                    temp.shadowImage = shadowImage;
                    temp.maskImage = maskImage;
                    temp.editImage = editImage;
                    temp.labelStyle = dict[@"LabelStyle"]==nil?labelStyle:dict[@"LabelStyle"];
                    temp.cacheHeight = [dict[@"IconHeight"] intValue];
                    temp.cacheWidth = [dict[@"IconWidth"] intValue];
                    temp.frame = CGRectMake(0, 0, [dict[@"IconWidth"] intValue], [dict[@"IconHeight"] intValue]);
                    [temp loadIcon:NO shouldCache:YES];
                
                }
            }
        
    
}

-(void)getGrids:(NSMutableArray *)ray dict:(NSDictionary *)dict{
    if([dict[@"ViewType"] isEqualToString:@"AppGrid"])
        [ray addObject:dict];
    else if(dict[@"Subviews"])
        for(NSDictionary *_dict in dict[@"Subviews"])
            [self getGrids:ray dict:_dict];
}

-(void)didUndim:(id)awayView{
    if(dictTheme[@"LockView"] && !lockView){
        lockView = [[DBLockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        lockView.backgroundColor = UIColor.blackColor;
        lockView.delegate = self;
        NSMutableArray *temp = [dictTheme[@"LockView"] mutableCopy];
        dictTheme[@"LockView"] = temp;
        for(int i = 0; i<(int)temp.count; i++){
            NSMutableDictionary *tempDict = [temp[i] mutableCopy];
            temp[i] = tempDict;
            UIView *tempView = [self loadView:tempDict];
            [lockView insertSubview:tempView atIndex:0];
        }
        [awayView addSubview:lockView];
    }
}
-(void)didDim{
    if(lockView)[lockView removeFromSuperview];
}

-(void)didRemoveFromSuperview{
    lockView = nil;
}

@end
