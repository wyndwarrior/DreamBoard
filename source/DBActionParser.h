#import "prefix.h"
#import "DreamBoard.h"

@interface DBActionParser : NSObject {
}

//action: can be a NSString or NSDictionary if/else block
//returns: NO if actions should stop or runtime error occurs
+(BOOL)parseAction:(id)action;


+(BOOL)parseActionArray:(NSArray *)actions;
+(BOOL)parseBool:(NSString*)b;

//replace variables with values
+(void)preParse:(NSMutableArray*)splitActions;

+(void)parseArithmetic:(NSMutableArray*)splitActions;
+(NSString*)concatString:(NSArray*)splitActions;
+(void)recurrm:(NSDictionary *)dict;
@end
