@interface SBUIController : NSObject
{
}
    
@property(nonatomic, retain) UIWindow *window;
-(BOOL)clickedMenuButton;
-(void)_toggleSwitcher;
-(void)activateApplicationAnimated:(SBApplication *)application;
-(void)activateApplicationFromSwitcher:(SBApplication *)application;
@end