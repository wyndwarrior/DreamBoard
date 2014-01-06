#import "DBScrollView.h"

@implementation DBScrollView
@synthesize actions;

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(actions)
        [DBActionParser parseActionArray:actions];
}

- (void)dealloc
{
    self.delegate = nil;
}

@end
