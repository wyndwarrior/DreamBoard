#import "DreamBoard.h"

@implementation DreamBoard
static DreamBoard *sharedInstance;
@synthesize appsArray, hiddenSet, isEditing, window, cachePath, scanPath, backgroundPath, shadowPath, shadowImagePath, dbtheme;

- (id)init
{
    self = [super init];
    if (self) {
        appsArray = [[NSMutableArray alloc] init];
        hiddenSet = [[NSMutableSet alloc] init];
        
        {
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/LibHide/hidden.plist"];
            NSArray *hideMe = @[@"com.apple.AdSheetPhone", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.iosdiagnostics", @"com.apple.iphoneos.iPodOut", @"com.apple.TrustMe", @"com.apple.WebSheet"];
            [hiddenSet addObjectsFromArray:hideMe];
            if(dict && dict[@"Hidden"]){
                [hiddenSet addObjectsFromArray:dict[@"Hidden"]];
            }
        }
        
        {
            prefsPath = [[NSMutableDictionary alloc] init];

            prefsPath[@"Path"] = @"/var/mobile/Library/Preferences/com.wynd.dreamboard.plist";
            
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:prefsPath[@"Path"]];
            if(dict){
                prefsDict = [dict mutableCopy];
            }
            
            if( !prefsDict )
                prefsDict = [NSMutableDictionary dictionary];
            
            prefsPath[@"Prefs"] = prefsDict;
        }
    }
    
    return self;
}

+(DreamBoard*)sharedInstance{
    if(!sharedInstance)sharedInstance = [[DreamBoard alloc] init];
    return sharedInstance;
}



-(void)show{
    window.userInteractionEnabled = NO;
    switcher = [[ExposeSwitcher alloc] init];
    switcher.cachePath = cachePath;
    switcher.scanPath  = scanPath;
    switcher.current   = [self currentTheme];
    switcher.backgroundPath = backgroundPath;
    switcher.shadowPath = shadowPath;
    switcher.delegate = self;
    [ExposeSwitcher setShadowImagePath:shadowImagePath];
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = frame.size.height-20;
    frame.size.height = 20;
    loading = [[DBLoadingView alloc] initWithFrame:frame];
    loading.label.text = @"Preparing theme switcher";
    [window addSubview:loading];
    [self performSelector:@selector(addSwitcher) withObject:nil afterDelay:0];
}

-(void)aboutToZoomIn:(ExposeSwitcherObject *)theme{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = frame.size.height-20;
    frame.size.height = 20;
    loading = [[DBLoadingView alloc] initWithFrame:frame];
    loading.label.text = @"Preparing theme";
    [window addSubview:loading];
}

-(void)addSwitcher{
    [switcher updateCache];
    [window addSubview:switcher.view];
    [loading hide];
}

-(void)didSelectObject:(NSString*)object view:(ExposeSwitcher *)view{
    window.userInteractionEnabled = NO;
    [self showAllExcept:view.view];
    [self loadTheme:object];
    [loading hide];
}
-(void)didFinishSelection:(ExposeSwitcher *)view{
    window.userInteractionEnabled = YES;
}

-(void)didFadeOut:(ExposeSwitcher *)view{
    [self hideAllExcept:view.view];
    if(![prefsPath[@"Prefs"][@"Launched"] boolValue]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to Dreamboard! Tap on any theme to switch to it. Tap and hold on any theme to see more options." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        prefsPath[@"Prefs"][@"Launched"] = @YES;
        [prefsPath[@"Prefs"] writeToFile:prefsPath[@"Path"] atomically:YES];
    }
}

-(void)hideAllExcept:(UIView *)view{
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) return;
    if(hidden)return;
    for(UIView *_view in window.subviews)
        //TODO: hack much?
        if(_view!=view && ![view.description hasPrefix:@"<SBAppContextHostView"] && ![view.description hasPrefix:@"<SBHostWrapperView"])
            _view.hidden = YES;
    hidden^=1;
}

-(void)showAllExcept:(UIView *)_view{
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) return;
    if(!hidden)return;
    for(UIView *view in window.subviews)
        if(view!=_view && ![view.description hasPrefix:@"<SBAppContextHostView"] && ![view.description hasPrefix:@"<SBHostWrapperView"])
            view.hidden = NO;
    hidden^=1;
}

-(void)didHold:(ExposeSwitcherObject*)object{
    ExpObj = object;
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Info.plist", MAINPATH, object.name]];
    if(!dict)return;
    UIAlertView *alert;
    if(dict[@"NoneEditable"]!=nil&&[dict[@"NoneEditable"] boolValue])
        alert = [[UIAlertView alloc] initWithTitle:object.name message:dict[@"Description"] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    else
        alert = [[UIAlertView alloc] initWithTitle:object.name message:dict[@"Description"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Edit", @"Reset", nil];
    [alert show];
}

-(void)didFinishZoomingOut:(ExposeSwitcher *)view{
    window.userInteractionEnabled = YES;
}

-(NSString*)currentTheme{
    return currentTheme!=nil?currentTheme:@"Default";
}

-(void)hideSwitcher{
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) return;
    if(dbtheme){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        dbtheme->mainView.frame = CGRectMake(0, 0, dbtheme->mainView.frame.size.width, dbtheme->mainView.frame.size.height);
        [UIView commitAnimations];
    }
}
-(void)showSwitcher{
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) return;
    if(dbtheme){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.25];
        dbtheme->mainView.frame = CGRectMake(0, -93, dbtheme->mainView.frame.size.width, dbtheme->mainView.frame.size.height);
        [UIView commitAnimations];
    }
}
-(void)toggleSwitcher{
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) return;
    if(dbtheme){
    if(dbtheme->mainView.frame.origin.y == -93)
        [self hideSwitcher];
    else
        [self showSwitcher];
    }
}
-(void)startEditing{
    isEditing = YES;
    dbtheme.isEditing = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Editing Mode" message:@"Welcome to editing mode. Tap on any app icon placeholder to change the icon. Press the home button when you are done!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
    if(dbtheme)
    for(DBAppIcon *app in dbtheme->allAppIcons)
        if(app.loaded){
            [app unloadIcon];
            [app loadIcon:YES shouldCache:NO];
        }
}
-(void)stopEditing{
    isEditing = NO;
    dbtheme.isEditing = NO;
    if(dbtheme)
    for(DBAppIcon *app in dbtheme->allAppIcons)
        if(app.loaded){
            [app unloadIcon];
            [app loadIcon:NO shouldCache:NO];
        }
    [dbtheme savePlist];
}
-(void)updateBadgeForApp:(NSString*)leafIdentifier{
    if(dbtheme)
    for(DBAppIcon *app in dbtheme->allAppIcons)
        if(app.application && [[app.application leafIdentifier] isEqualToString:leafIdentifier] && app.loaded){
            [app unloadIcon];
            [app loadIcon:dbtheme.isEditing shouldCache:NO];
        }
}
-(void)loadTheme:(NSString*) theme{
    if([theme isEqualToString:self.currentTheme])return;
    if([theme isEqualToString:@"Default"]){
        //if there is already a theme, unload it
        if(currentTheme)
            [self unloadTheme];
        prefsPath[@"Prefs"][@"Current Theme"] = theme;
        [prefsPath[@"Prefs"] writeToFile:prefsPath[@"Path"] atomically:YES];
        return;
    }
    if(dbtheme)[self unloadTheme];
    currentTheme = theme;
    dbtheme = [[DBTheme alloc] initWithName:theme window:window];
    if(isEditing)
    dbtheme.isEditing = YES;
    [dbtheme loadTheme];
    prefsPath[@"Prefs"][@"Current Theme"] = theme;
    [prefsPath[@"Prefs"] writeToFile:prefsPath[@"Path"] atomically:YES];
}
-(void)unloadTheme{
    window.userInteractionEnabled = NO;
    if(dbtheme){
        dbtheme = nil;
    }
    if(currentTheme){
        currentTheme = nil;
    }
    window.userInteractionEnabled = YES;
}

+(void)throwRuntimeException:(NSString*)msg shouldExit:(BOOL)exit{
    if(exit)
        [[[UIAlertView alloc] initWithTitle:@"Runtime Error" message:msg delegate:[DreamBoard sharedInstance] cancelButtonTitle:@"Continue" otherButtonTitles:@"Exit",nil] show];
    else
        [[[UIAlertView alloc] initWithTitle:@"Runtime Error" message:msg delegate:[DreamBoard sharedInstance] cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([alertView.title isEqualToString:@"Runtime Error"]){
        if (buttonIndex != [alertView cancelButtonIndex])
            [self unloadTheme];
    }else{
        if (buttonIndex == [alertView cancelButtonIndex])return;
        if(buttonIndex == 1){
            [[ExposeSwitcher sharedInstance] switchTo:ExpObj];
            if(dbtheme!=nil && [ExpObj.name isEqualToString:currentTheme])
                [self startEditing];
            else{
                isEditing = YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Editing Mode" message:@"Welcome to editing mode. Tap on any app icon placeholder to change the icon. Press the home button when you are done!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
            }
        }else if(buttonIndex == 2){
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Current.plist", MAINPATH, alertView.title] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/DreamBoard/_library/Cache/Icons/%@", MAINPATH, alertView.title] error:nil];
        }
    }
}

+(NSString *)replaceRootDir:(NSString *)str{
    return [str stringByReplacingOccurrencesOfString:@"$ROOT" withString:[NSString stringWithFormat:@"/DreamBoard/%@", [[DreamBoard sharedInstance] currentTheme]]];
}

-(void)launch:(id)app{
    if( [app respondsToSelector:@selector(launch)])
        [app launch];
    else
        [self.sbuicontroller launchIcon:app fromLocation:0];
}

-(void)preLoadTheme{
    if(![prefsPath[@"Prefs"][@"Current Theme"] isEqualToString:@"Default"])
        [self loadTheme:prefsPath[@"Prefs"][@"Current Theme"]];
}

-(void)save:(NSString *)theme{
    prefsPath[@"Prefs"][@"Current Theme"] = theme;
    [prefsPath[@"Prefs"] writeToFile:prefsPath[@"Path"] atomically:YES];
}

@end
