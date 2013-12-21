@class ExposeSwitcher, ExposeSwitcherObject;
@protocol ExposeSwitcherDelegate <NSObject>
@optional
-(void)didFinishZoomingOut:(ExposeSwitcher *)view;
-(void)didSelectObject:(NSString*)object view:(ExposeSwitcher *)view;
-(void)didFinishSelection:(ExposeSwitcher *)view;
-(void)didFadeOut:(ExposeSwitcher *)view;
-(void)didHold:(ExposeSwitcherObject*)object;
-(void)aboutToZoomIn:(ExposeSwitcherObject*)theme;
@end