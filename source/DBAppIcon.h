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
    
    CGRect theFrame;
    BOOL loaded, hasCache;
    int cacheWidth, cacheHeight;
}
@property(nonatomic, strong) NSMutableDictionary *dict;
@property(nonatomic, strong) UIImage *shadowImage;
@property(nonatomic, strong) UIImage *maskImage;
@property(nonatomic, strong) UIImage *overlayImage;
@property(nonatomic, strong) UIImage *editImage;
@property(nonatomic, strong) UIImage *badgeImage;
@property(nonatomic, strong) id application;
@property(nonatomic, strong) NSDictionary *labelStyle;
@property(nonatomic, readonly) BOOL loaded;
@property(nonatomic, weak) DBGrid*grid;

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
