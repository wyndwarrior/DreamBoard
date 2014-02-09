#import "prefix.h"
#import "DBAppIcon.h"

@interface DBAppSelectionTable : UIView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id delegate;
@property (nonatomic, weak) NSArray *tableData;

-(void)setTitle:(NSString *)title;
+(DBAppSelectionTable *)sharedTable;
@end
