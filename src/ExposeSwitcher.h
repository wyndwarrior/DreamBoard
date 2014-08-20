#import "DBPrefix.h"

#import "ExposeSwitcherObject.h"
#import "ExposeSwitcherDelegate.h"
@class ExposeSwitcherObject;
@interface ExposeSwitcher : UIViewController <UIScrollViewDelegate>{
    UIScrollView *mainScrollView;
    UIImageView *background;
    UIImageView *shadow;
    UIImageView *previewImage;
    UIPageControl *pagectrl;
    NSMutableArray *switcherObjects;
    
    NSString *cachePath;
    NSString *scanPath;
    NSString *currentObject;
    NSString *backgroundPath;
    NSString *shadowPath;
    
    id<ExposeSwitcherDelegate> delegate;
    
    int animationkey;
    double width;
    double height;
    double x[5][5];
    double y[5][5];
    
    CGRect bounds;
}

@property(nonatomic, strong) NSString *cachePath;
@property(nonatomic, strong) NSString *scanPath;
@property(nonatomic, strong) NSString *current;
@property(nonatomic, strong) NSString *backgroundPath;
@property(nonatomic, strong) NSString *shadowPath;
@property(nonatomic, strong) id<ExposeSwitcherDelegate> delegate;

-(void)updateCache;
-(void)switchTo:(ExposeSwitcherObject *)theme;
-(void)animationDidFinish;
-(void)updatePages;
+(UIImage *)shadowImage;
+(void)setShadowImagePath:(NSString*)path;
+(ExposeSwitcher *)sharedInstance;
-(void)didHold:(ExposeSwitcherObject *)theme;
@end