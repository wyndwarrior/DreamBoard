#import "prefix.h"
#import "DreamBoard.h"

@interface DBActionParser : NSObject {
}
+(BOOL)parseAction:(id)action;
+(BOOL)parseActionArray:(NSArray *)actions;
+(BOOL)parseBool:(NSString*)b;
+(void)preParse:(NSMutableArray*)splitActions;
+(NSString*)concatString:(NSArray*)splitActions;
+(void)recurrm:(NSDictionary *)dict;
@end
