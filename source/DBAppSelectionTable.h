#import "prefix.h"
#import "DBAppIcon.h"

@interface DBAppSelectionTable : UIView <UITableViewDelegate, UITableViewDataSource> {
	NSArray *tableData;
	UITableView *_tableView;
	id _delegate;
}
-(id)initWithFrame:(CGRect)frame data:(NSArray *)data delegate:(id)delegate title:(NSString *)title;
@end
