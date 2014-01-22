#import "DBGrid.h"

@implementation DBGrid
@synthesize dict, appsArray, badgeImage, editImage, maskImage, overlayImage, shadowImage;
- (id)initWithDict:(NSMutableDictionary *)_dict
{
    self = [super init];
    if (self) {
        self.dict = _dict;
        if(dict[@"Apps"]){
            self.appsArray = [dict[@"Apps"] mutableCopy];
            dict[@"Apps"] = appsArray;
        }
        self.delegate = self;
    }
    return self;
}

+ (id)find:(NSString*)goal{
    for(id app in [[DreamBoard sharedInstance] appsArray])
        if([[app leafIdentifier] isEqualToString:goal])
            return app;
    return nil;
}

- (void)loadGrid{
    ROWS = dict[@"Rows"]?[dict[@"Rows"] intValue]:9999;
    COLS = dict[@"Cols"]?[dict[@"Cols"] intValue]:9999;
    GAPX = [dict[@"GapX"] intValue];
    GAPY = [dict[@"GapY"] intValue];
    if(dict[@"PageGapX"] && dict[@"PageGapY"]){
        PAGEGAPX = [dict[@"PageGapX"] intValue];
        PAGEGAPY = [dict[@"PageGapY"] intValue];
    }else
        PAGEGAPY = [dict[@"PageHeight"] intValue];
    
    
    int NUM = ROWS*COLS,
    ICONW = [dict[@"IconWidth"] intValue],
    ICONH = [dict[@"IconHeight"] intValue];
    BOOL allApps = [dict[@"AllApps"] boolValue];
    
    int maxX = 0;
    int maxY = 0;
    NSArray *theArray = allApps?[[DreamBoard sharedInstance] appsArray]:appsArray;
    for(int i = 0; i<theArray.count;)
        for(int r  = 0; r<ROWS && i<theArray.count; r++)
            for(int c = 0; c<COLS && i<theArray.count; c++, i++){
                DBAppIcon *appIcon = [[DBAppIcon alloc] init];
                appIcon.application = allApps?theArray[i]:[DBGrid find:theArray[i]];
                appIcon.badgeImage = badgeImage;
                appIcon.overlayImage = overlayImage;
                appIcon.shadowImage = shadowImage;
                appIcon.maskImage = maskImage;
                appIcon.editImage = editImage;
                appIcon.cacheWidth = ICONW;
                appIcon.cacheHeight = ICONH;
                appIcon.grid = self;
                appIcon.tag = i;
                appIcon.labelStyle = dict[@"LabelStyle"];
                maxX = MAX(maxX, c*GAPX + i/NUM*PAGEGAPX);
                maxY = MAX(maxY, r*GAPY + i/NUM*PAGEGAPY);
                appIcon.frame = CGRectMake(c*GAPX + i/NUM*PAGEGAPX, r*GAPY + i/NUM*PAGEGAPY , ICONW, ICONH);
                NSLog(@"%d, %@", i, NSStringFromCGRect(appIcon.frame));
                [self addSubview:appIcon];
            }
    self.contentSize = CGSizeMake(maxX+GAPX, maxY+GAPY);
    [self scrollViewDidScroll:nil];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect rect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height);
    for(UIView *view in self.subviews)
        if([view isKindOfClass:[DBAppIcon class]]){
            if(CGRectIntersectsRect(rect, view.frame)){
                if(!((DBAppIcon*)view).loaded)
                    [(DBAppIcon*)view loadIcon:[DreamBoard sharedInstance].dbtheme.isEditing&&![dict[@"AllApps"] boolValue] shouldCache:NO];
            }else if(((DBAppIcon*)view).loaded)
                [(DBAppIcon*)view unloadIcon];
        }
}

-(void)unloadAll{
    for(UIView *view in self.subviews)
        if([view isKindOfClass:[DBAppIcon class]])
            if(((DBAppIcon*)view).loaded)
                [(DBAppIcon*)view unloadIcon];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled{
    [super setUserInteractionEnabled:userInteractionEnabled];
    if(userInteractionEnabled)
        [self scrollViewDidScroll:nil];
    else
        [self unloadAll];
}


-(void)addTo:(NSString *)bundle sender:(DBAppIcon *)sender{
    if(![dict[@"AllApps"] boolValue])
        appsArray[sender.tag] = bundle;
}

-(void)doActions{
    if(dict[@"Actions"])
        [DBActionParser parseActionArray:dict[@"Actions"]];
}

@end
