#import "prefix.h"
#import "DBAppSelectionTable.h"
#import "DreamBoard.h"

@class DBGrid;
@interface DBAppIcon : UIView {
    id application;
    UIImage *shadowImage;
    UIImage *maskImage;
    UIImage *overlayImage;
    UIImage *editImage;
    UIImage *badgeImage;
    
    UILabel *iconLabel;
    UIButton *iconButton;
    UIImageView *shadowImageView;
    UIImageView *overlayImageView;
    UIImageView *editImageView;
    UIImageView *iconImageView;
    UIView *badge;
    
    NSMutableDictionary *dict;
    NSDictionary *labelStyle;
    
    DBGrid *grid;
    
    CGRect theFrame;
    BOOL loaded, hasCache;
    int cacheWidth, cacheHeight;
}
@property(nonatomic, retain) NSMutableDictionary *dict;
@property(nonatomic, retain) UIImage *shadowImage;
@property(nonatomic, retain) UIImage *maskImage;
@property(nonatomic, retain) UIImage *overlayImage;
@property(nonatomic, retain) UIImage *editImage;
@property(nonatomic, retain) UIImage *badgeImage;
@property(nonatomic, retain) id application;
@property(nonatomic, retain) NSDictionary *labelStyle;
@property(nonatomic, readonly) BOOL loaded;
@property(nonatomic, assign) DBGrid*grid;

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
