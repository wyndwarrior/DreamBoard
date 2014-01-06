#import "prefix.h"

#import "DBActionParser.h"
@interface DBScrollView : UIScrollView <UIScrollViewDelegate>{
    NSArray *actions;
}
@property(nonatomic, strong) NSArray *actions;
@end
