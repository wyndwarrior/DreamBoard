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
        
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/LibHide/hidden.plist"];
        NSArray *hideMe = @[@"com.apple.AdSheetPhone", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.iosdiagnostics", @"com.apple.iphoneos.iPodOut", @"com.apple.TrustMe", @"com.apple.WebSheet", @"com.apple.appleaccount.AACredentialRecoveryDialog", @"com.apple.AccountAuthenticationDialog", @"com.apple.CompassCalibrationViewService", @"com.apple.Copilot", @"com.apple.datadetectors.DDActionsService", @"com.apple.FacebookAccountMigrationDialog", @"com.apple.fieldtest", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.MusicUIService", @"com.apple.quicklook.quicklookd", @"com.apple.PassbookUIService", @"com.apple.purplebuddy", @"com.apple.SiriViewService", @"com.apple.social.remoteui.SocialUIService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.WebViewService"];
        [hiddenSet addObjectsFromArray:hideMe];
        if(dict && dict[@"Hidden"]){
            [hiddenSet addObjectsFromArray:dict[@"Hidden"]];
        }
        prefsPath = [[NSMutableDictionary alloc] init];

        prefsPath[@"Path"] = @"/var/mobile/Library/Preferences/com.wynd.dreamboard.plist";
        
        prefsDict = [[[NSDictionary alloc] initWithContentsOfFile:prefsPath[@"Path"]] mutableCopy];
        
        if( !prefsDict )
            prefsDict = [NSMutableDictionary dictionary];
        
        prefsPath[@"Prefs"] = prefsDict;
            
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateView:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

+(DreamBoard*)sharedInstance{
    if(!sharedInstance)sharedInstance = [[DreamBoard alloc] init];
    return sharedInstance;
}

-(void)rotateView:(NSNotification *)notification {
    UIInterfaceOrientation _ori = [[[notification userInfo] objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    ori = _ori;
    [self setOrientation];
}

-(void)setOrientation{
    if( self.sbView && self.dbtheme) {
        UIView *view = dbtheme.mainView;
        CGAffineTransform t = CGAffineTransformIdentity;
        
        if(ori == UIInterfaceOrientationPortraitUpsideDown)
            t = CGAffineTransformMakeRotation(M_PI);
        else if(ori == UIInterfaceOrientationLandscapeLeft)
            t = CGAffineTransformMakeRotation(M_PI/2);
        else if(ori == UIInterfaceOrientationLandscapeRight)
            t = CGAffineTransformMakeRotation(-M_PI/2);
        
        [UIView animateWithDuration:.4 animations:^{
            view.transform = t;
            CGRect rect = view.frame;
            rect.origin.x = 0;
            rect.origin.y = 0;
            view.frame = rect;
        }];
    }
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
    [self returnSbView];
}
-(void)didFinishSelection:(ExposeSwitcher *)view{
    window.userInteractionEnabled = YES;
}

-(UIView *)removeSbView{
    if( self.sbView){
        self.sbSuperview = self.sbView.superview;
        [self.sbView removeFromSuperview];
        self.sbViewFrame = self.sbView.frame;
        self.sbView.clipsToBounds = YES;
    }
    return self.sbView;
}

-(void)returnSbView{
    if(self.sbSuperview){
        [self.sbSuperview addSubview:self.sbView];
        self.sbView.transform = CGAffineTransformIdentity;
        self.sbView.frame = self.sbViewFrame;
        self.sbSuperview = nil;
        self.sbView.clipsToBounds = NO;
    }
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
    if( self.sbView){
        if( self.dbtheme )
            [self.dbtheme.mainView removeFromSuperview];
    }
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) return;
    if(hidden)return;
    for(UIView *_view in window.subviews)
        //TODO: hack much?
        if(_view!=view && ![view.description hasPrefix:@"<SBAppContextHostView"] && ![view.description hasPrefix:@"<SBHostWrapperView"])
            _view.hidden = YES;
    hidden^=1;
}

-(void)showAllExcept:(UIView *)_view{
    if( self.sbView){
        if( self.dbtheme )
            [self.sbView addSubview:self.dbtheme.mainView];
    }
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
    [self returnSbView];
    if( self.sbView)
        dbtheme = [[DBTheme alloc] initWithName:theme window:self.sbView];
    else
        dbtheme = [[DBTheme alloc] initWithName:theme window:window];
    dbtheme.isEditing = isEditing;
    [dbtheme loadTheme];
    [self setOrientation];
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

-(void)reLayout{
    if( self.dbtheme && !self.sbSuperview){
        if( ![self.sbView.subviews containsObject:self.dbtheme.mainView])
            [self.sbView addSubview:self.dbtheme.mainView];
        [self.sbView bringSubviewToFront:self.dbtheme.mainView];
    }
}

-(void)launch:(id)app{
    if( [app respondsToSelector:@selector(launch)])
        [app launch];
    else
        [self.sbuicontroller launchIcon:app fromLocation:0];
}

-(void)launchBundleId:(NSString *)bundle{
    for(int i = 0; i<appsArray.count; i++)
        if([[appsArray[i] leafIdentifier] isEqualToString:bundle]){
            [self launch:appsArray[i]];
            break;
        }
}

-(void)preLoadTheme{
    if(![prefsPath[@"Prefs"][@"Current Theme"] isEqualToString:@"Default"])
        [self loadTheme:prefsPath[@"Prefs"][@"Current Theme"]];
}

-(void)unlockDevice{
    id ac =[objc_getClass("SBAwayController") sharedAwayController];
    if([ac respondsToSelector:@selector(unlockWithSound:isAutoUnlock:)])
        [ac unlockWithSound:YES isAutoUnlock:NO];
    else if( [ac respondsToSelector:@selector(_unlockWithSound:isAutoUnlock:)] )
        [ac _unlockWithSound:YES isAutoUnlock:NO];
    else if( [ac respondsToSelector:@selector(unlockWithSound:)] )
        [ac unlockWithSound:YES];
    else{
#ifdef TARGET_THEOS
        id lc = [objc_getClass("SBLockScreenManager") sharedInstance];
        if( [lc respondsToSelector:@selector(startUIUnlockFromSource:withOptions:)]){
            [lc startUIUnlockFromSource:0 withOptions:nil];
            _Bool unlocked = false;
            if( [lc respondsToSelector:@selector(isUILocked)])
                unlocked = ![lc isUILocked];
            if( !unlocked && [lc respondsToSelector:@selector(applicationRequestedDeviceUnlock)])
                [lc applicationRequestedDeviceUnlock];
        }
#endif
    }
}

-(void)save:(NSString *)theme{
    prefsPath[@"Prefs"][@"Current Theme"] = theme;
    [prefsPath[@"Prefs"] writeToFile:prefsPath[@"Path"] atomically:YES];
}

@end
