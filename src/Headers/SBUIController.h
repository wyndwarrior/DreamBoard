@interface SBUIController : NSObject
{
}
    
@property(nonatomic, retain) UIWindow *window;
-(BOOL)clickedMenuButton;
-(void)_toggleSwitcher;
-(void)activateApplicationAnimated:(SBApplication *)application;
-(void)activateApplicationFromSwitcher:(SBApplication *)application;
-(void)_launchIcon:(id)arg1;
-(void)launchIcon:(id)arg1 fromLocation:(int)arg2;
@end