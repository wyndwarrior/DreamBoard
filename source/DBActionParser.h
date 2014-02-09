#import "prefix.h"
#import "DreamBoard.h"

@interface DBActionParser : NSObject

//action: can be a NSString or NSDictionary if/else block
//returns YES if actions should be stopped
+(BOOL)parseAction:(id)action;

+(BOOL)parseActionArray:(NSArray *)actions;

@end
