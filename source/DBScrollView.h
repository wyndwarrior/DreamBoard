#import "prefix.h"

#import "DBActionParser.h"
@interface DBScrollView : UIScrollView <UIScrollViewDelegate>{
    NSArray *actions;
}
@property(nonatomic, retain) NSArray *actions;
@end
