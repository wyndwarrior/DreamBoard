#import "DBPrefix.h"
#import "ExposeSwitcher.h"
#import "DreamBoard.h"

@class UILongPressGestureRecognizer;
@interface SomeObject : NSObject {
}
-(void)addGestureRecognizer:(id)d;
@end
@interface ExposeSwitcherObject : UIView {
    UIButton *btn;
    NSString *name;
    UIImageView *shadow;
    UILabel *label;
    int row;
    int col;
    int index;
}
@property(assign)int row;
@property(assign)int col;
@property(assign)int index;
@property(nonatomic, weak) UIView *sbView;
@property(nonatomic, readonly) NSString *name;
-(id)initWithName:(NSString*)name;
-(void)go:(id)sender;
@end
