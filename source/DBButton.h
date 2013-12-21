#import "prefix.h"
#import "DBActionParser.h"

@interface DBButton : UIView {
	UIButton *button;
	NSArray *actions;
}
-(id)initWithDict:(NSDictionary *)dict;
-(void)doActions;
@end
