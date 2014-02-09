#import "prefix.h"
#import "DreamBoard.h"
#import "DBAppIcon.h"
#import "DBGrid.h"
#import "DBButton.h"
#import "DBScrollView.h"
#import "DBLockView.h"
#import "DBWebView.h"

@class DBLockView;
@interface DBTheme : NSObject {
    NSString *themeName;
    UIView *window;
    
    UIImage *badgeImage;
    UIImage *overlayImage;
    UIImage *shadowImage;
    UIImage *maskImage;
    UIImage *editImage;
    
@public
    
    NSMutableDictionary *dictTheme;
    NSMutableDictionary *dictDynViews;
    NSMutableDictionary *dictViews;
    NSMutableDictionary *dictVars;
    
    NSMutableDictionary *dictViewsInteraction;
    NSMutableDictionary *dictViewsToggled;
    NSMutableDictionary *dictViewsToggledInteraction;
    
    NSDictionary *functions;
    NSDictionary *labelStyle;
    
    NSMutableArray *allAppIcons;
    
    UIView *mainView;
    DBLockView *lockView;
    BOOL isEditing;
    BOOL isDealloc;
}
@property(nonatomic, assign) BOOL isEditing;
@property(nonatomic, strong) UIView *mainView;

-(UIView *)loadView:(NSMutableDictionary *)dict;
-(id)initWithName:(NSString*)name window:(UIView *)_window;
-(id)findApp:(NSString*)app;

-(id)getView:(NSString *)name;
-(void)addView:(NSString *)name view:(UIView *)view;
-(void)removeView:(NSString *)name;
-(BOOL)viewIsInteractive:(NSString *)name;
-(BOOL)toggle:(NSString *)name;
-(id)getFunction:(NSString *)name;

-(NSMutableArray *)allAppIcons;

-(void)setVariable:(NSString *)name value:(id)val;
-(id)getVariable:(NSString *)name;
-(NSMutableDictionary *)getDynamicView:(NSString *)name;

-(void)loadTheme;
-(void)savePlist;
-(void)cacheIfNeeded;
-(void)setViewDefaults:(UIView *)view withDict:(NSDictionary *)dict;
-(void)getGrids:(NSMutableArray*)ray dict:(NSDictionary*)dict;
-(void)didUndim:(id)awayView;
-(void)didDim;
-(void)didRemoveFromSuperview;
@end
