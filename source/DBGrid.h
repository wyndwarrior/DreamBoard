#import "prefix.h"
#import "DreamBoard.h"
#import "DBAppIcon.h"
@class DBAppIcon;
@interface DBGrid : UIScrollView <UIScrollViewDelegate>

@property(nonatomic, weak) UIImage *shadowImage;
@property(nonatomic, weak) UIImage *maskImage;
@property(nonatomic, weak) UIImage *overlayImage;
@property(nonatomic, weak) UIImage *editImage;
@property(nonatomic, weak) UIImage *badgeImage;

- (id)initWithDict:(NSMutableDictionary *)_dict;
+ (id)find:(NSString*)appIcon;

- (void)loadGrid;
- (void)unloadAll;

- (void)addTo:(NSString *)bundle sender:(DBAppIcon*)sender;
- (void)doActions;
@end
