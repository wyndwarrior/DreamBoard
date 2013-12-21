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
@property(nonatomic, retain) NSMutableDictionary *dict;
@property(nonatomic, retain) NSMutableArray *appsArray;

@property(nonatomic, retain) UIImage *shadowImage;
@property(nonatomic, retain) UIImage *maskImage;
@property(nonatomic, retain) UIImage *overlayImage;
@property(nonatomic, retain) UIImage *editImage;
@property(nonatomic, retain) UIImage *badgeImage;

- (id)initWithDict:(NSMutableDictionary *)_dict;
- (void)loadGrid;
+ (id)find:(NSString*)goal;
- (void)unloadAll;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)addTo:(NSString *)bundle sender:(DBAppIcon*)sender;
-(void)doActions;
@end
