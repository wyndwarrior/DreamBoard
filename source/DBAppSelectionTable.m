#import "DBAppSelectionTable.h"

@implementation DBAppSelectionTable
-(id)initWithFrame:(CGRect)frame data:(NSArray *)data delegate:(id)delegate title:(NSString *)title{
	[super initWithFrame:frame];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,44,frame.size.width,frame.size.height-44) style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	[self addSubview:_tableView];
	_delegate = delegate;
	tableData = data;
	//[tableView release];
	UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
																	style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"No Icon" 
																	style:UIBarButtonItemStyleBordered target:self action:@selector(none)];
	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:title];
	item.rightBarButtonItem = rightButton;
	item.leftBarButtonItem = leftButton;
	item.hidesBackButton = YES;
	[bar pushNavigationItem:item animated:NO];
	[rightButton release];
	[item release];
	[self addSubview:bar];
	[bar release];
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return tableData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [[tableData objectAtIndex:row] displayName];
    cell.detailTextLabel.text = [[tableData objectAtIndex:row] leafIdentifier];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:10];
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath; 
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    NSString *rowValue = [[tableData objectAtIndex:row] leafIdentifier];
	[_delegate addTo:rowValue];
	//NSLog(rowValue);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
-(void)dealloc{
	[_tableView release];
	[super dealloc];
}
@end
