#import "DBAppSelectionTable.h"

@interface DBAppSelectionTable ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UINavigationBar *navBar;

@end


@implementation DBAppSelectionTable

+(DBAppSelectionTable *)sharedTable{
    static DBAppSelectionTable *shared= nil;
    if( !shared )
        shared = [[DBAppSelectionTable alloc] init];
    return shared;
}

-(id)init{
    self = [super initWithFrame:CGRectZero];
	if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
        self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        [self addSubview:self.navBar];
    }
	return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
	_tableView.frame = CGRectMake(0,44,frame.size.width,frame.size.height-44);
	self.navBar.frame = CGRectMake(0, 0, frame.size.width, 44);
}

-(void)setTitle:(NSString *)title{
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																	style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"No Icon"
                                                                   style:UIBarButtonItemStyleBordered target:self action:@selector(none)];
	item.rightBarButtonItem = rightButton;
	item.leftBarButtonItem = leftButton;
	item.hidesBackButton = YES;
    [self.navBar popNavigationItemAnimated:NO];
	[self.navBar pushNavigationItem:item animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [_tableData[row] displayName];
    cell.detailTextLabel.text = [_tableData[row] leafIdentifier];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath; 
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    NSString *rowValue = [_tableData[row] leafIdentifier];
	[_delegate addTo:rowValue];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self removeFromSuperview];
}

-(void)cancel{
	[self removeFromSuperview];
}

-(void)none{
	[_delegate addTo:@"NO ICON PLACEHOLDER"];
	[self removeFromSuperview];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
@end
