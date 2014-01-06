#import "prefix.h"
#import "DreamBoard.h"
#import "DBAppIcon.h"
@class DBAppIcon;
@interface DBGrid : UIScrollView <UIScrollViewDelegate> {
    NSMutableDictionary *dict;
    NSMutableArray *appsArray;
    
    int ROWS, COLS, GAPX, GAPY, PAGEGAPX, PAGEGAPY;
    
    UIImage *shadowImage;
    UIImage *maskImage;
    UIImage *overlayImage;
    UIImage *editImage;
    UIImage *badgeImage;
}
@property(nonatomic, strong) NSMutableDictionary *dict;
@property(nonatomic, strong) NSMutableArray *appsArray;

@property(nonatomic, strong) UIImage *shadowImage;
@property(nonatomic, strong) UIImage *maskImage;
@property(nonatomic, strong) UIImage *overlayImage;
@property(nonatomic, strong) UIImage *editImage;
@property(nonatomic, strong) UIImage *badgeImage;

- (id)initWithDict:(NSMutableDictionary *)_dict;
- (void)loadGrid;
+ (id)find:(NSString*)goal;
- (void)unloadAll;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)addTo:(NSString *)bundle sender:(DBAppIcon*)sender;
-(void)doActions;
@end
