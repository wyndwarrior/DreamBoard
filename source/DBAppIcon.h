#import "DBPrefix.h"
#import "DBAppSelectionTable.h"
#import "DreamBoard.h"

@class DBGrid;
@interface DBAppIcon : UIView

@property(nonatomic, strong) NSMutableDictionary *dict;
@property(nonatomic, strong) NSDictionary *labelStyle;
@property(nonatomic, weak) DBGrid* grid;
@property(nonatomic, weak) UIImage *shadowImage;
@property(nonatomic, weak) UIImage *maskImage;
@property(nonatomic, weak) UIImage *overlayImage;
@property(nonatomic, weak) UIImage *editImage;
@property(nonatomic, weak) UIImage *badgeImage;
@property(nonatomic, weak) id application;
@property(nonatomic, readonly) BOOL loaded;

@property(nonatomic, assign) int cacheWidth;
@property(nonatomic, assign) int cacheHeight;

-(void)loadIcon:(BOOL)isEditing shouldCache:(BOOL)shouldCache;
-(void)unloadIcon;
-(void)launch;
-(void)updateBadge;
-(void)updateFrame;

+(void)setCacheLocation:(NSString*)_cache;
+(UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+(void)cacheIconForBundle:(NSString*)bundle view:(UIView *)view;
+(NSString*)cacheLocation;

-(void)addTo:(NSString *)bundle;

@end
