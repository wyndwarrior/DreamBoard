#import "prefix.h"
#import "ExposeSwitcher.h"
#import "ExposeSwitcherDelegate.h"
#import "DBTheme.h"
#import "DBLoadingView.h"

@protocol ExposeSwitcherDelegate;
@class ExposeSwitcher, DBTheme, ExposeSwitcherObject, DBLoadingView;
@interface DreamBoard : NSObject <ExposeSwitcherDelegate> {
    //array of SBApplicationIcons
    NSMutableArray *appsArray;
    
    //set of hidden apps
    NSMutableSet *hiddenSet;
    
    //theme preferences
    NSMutableDictionary *prefsDict;
    NSMutableDictionary *prefsPath;
    
    NSString *currentTheme;
    
    ExposeSwitcher *switcher;
    UIWindow *window;
    
    //DBTheme *dbtheme;
    
    BOOL isEditing;
    
    NSString *cachePath;
    NSString *scanPath;
    NSString *backgroundPath;
    NSString *shadowPath;
    NSString *shadowImagePath;
    
    DBTheme *dbtheme;
    BOOL hidden;
    
    ExposeSwitcherObject* ExpObj;
    DBLoadingView *loading;
}

@property(nonatomic, readonly) NSMutableArray *appsArray;
@property(nonatomic, readonly) NSMutableSet *hiddenSet;
@property(nonatomic, retain) UIWindow *window;
@property(readonly)BOOL isEditing;

@property(nonatomic, retain) NSString *cachePath;
@property(nonatomic, retain) NSString *scanPath;
@property(nonatomic, retain) NSString *backgroundPath;
@property(nonatomic, retain) NSString *shadowPath;
@property(nonatomic, retain) NSString *shadowImagePath;
@property(nonatomic, readonly) DBTheme *dbtheme;

+(DreamBoard*)sharedInstance;

//show the theme switcher
-(void)show;

//show/hide the app switcher
-(void)hideSwitcher;
-(void)showSwitcher;
-(void)toggleSwitcher;

//start/stop editing
-(void)startEditing;
-(void)stopEditing;

//update badges
-(void)updateBadgeForApp:(NSString*)leafIdentifier;

//load theme, if Default then unloads theme
-(void)loadTheme:(NSString*) theme;
-(void)unloadTheme;

-(NSString*)currentTheme;

+(void)throwRuntimeException:(NSString*)msg shouldExit:(BOOL)exit;
-(void)hideAllExcept:(UIView*)view;
-(void)showAllExcept:(UIView*)_view;
+(NSString *)replaceRootDir:(NSString *)str;
-(void)preLoadTheme;
-(void)save:(NSString *)theme;

@end
