#import "prefix.h"

#import "DBActionParser.h"
@interface DBScrollView : UIScrollView <UIScrollViewDelegate>

@property(nonatomic, strong) NSArray *actions;

@end
