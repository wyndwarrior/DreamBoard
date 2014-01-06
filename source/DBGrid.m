#import "DBGrid.h"

@implementation DBGrid
@synthesize dict, appsArray, badgeImage, editImage, maskImage, overlayImage, shadowImage;
- (id)initWithDict:(NSMutableDictionary *)_dict
{
    self = [super init];
    if (self) {
        self.dict = _dict;
        if([dict objectForKey:@"Apps"]){
            self.appsArray = [[dict objectForKey:@"Apps"] mutableCopy];
            [dict setObject:appsArray forKey:@"Apps"];
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
    ROWS = [dict objectForKey:@"Rows"]?[[dict objectForKey:@"Rows"] intValue]:9999;
    COLS = [dict objectForKey:@"Cols"]?[[dict objectForKey:@"Cols"] intValue]:9999;
    GAPX = [[dict objectForKey:@"GapX"] intValue];
    GAPY = [[dict objectForKey:@"GapY"] intValue];
    if([dict objectForKey:@"PageGapX"] && [dict objectForKey:@"PageGapY"]){
        PAGEGAPX = [[dict objectForKey:@"PageGapX"] intValue];
        PAGEGAPY = [[dict objectForKey:@"PalpageGapY"] intValue];
    }else
        PAGEGAPY = [[dict objectForKey:@"PageHeight"] intValue];
    
    
    int NUM = ROWS*COLS,
    ICONW = [[dict objectForKey:@"IconWidth"] intValue],
    ICONH = [[dict objectForKey:@"IconHeight"] intValue];
    BOOL allApps = [[dict objectForKey:@"AllApps"] boolValue];
    
    int maxX = 0;
    int maxY = 0;
    NSArray *theArray = allApps?[[DreamBoard sharedInstance] appsArray]:appsArray;
    for(int i = 0; i<theArray.count;)
        for(int r  = 0; r<ROWS && i<theArray.count; r++)
            for(int c = 0; c<COLS && i<theArray.count; c++, i++){
                DBAppIcon *appIcon = [[DBAppIcon alloc] init];
                appIcon.application = allApps?[theArray objectAtIndex:i]:[DBGrid find:[theArray objectAtIndex:i]];
                appIcon.badgeImage = badgeImage;
                appIcon.overlayImage = overlayImage;
                appIcon.shadowImage = shadowImage;
                appIcon.maskImage = maskImage;
                appIcon.editImage = editImage;
                appIcon.cacheWidth = ICONW;
                appIcon.cacheHeight = ICONH;
                appIcon.grid = self;
                appIcon.tag = i;
                appIcon.labelStyle = [dict objectForKey:@"LabelStyle"];
                //[appIcon loadIcon:NO shouldCache:NO];
                maxX = MAX(maxX, c*GAPX + i/NUM*PAGEGAPX);
                maxY = MAX(maxY, r*GAPY + i/NUM*PAGEGAPY);
                appIcon.frame = CGRectMake(c*GAPX + i/NUM*PAGEGAPX, r*GAPY + i/NUM*PAGEGAPY , ICONW, ICONH);
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
                    [(DBAppIcon*)view loadIcon:[DreamBoard sharedInstance].dbtheme.isEditing&&![[dict objectForKey:@"AllApps"] boolValue] shouldCache:NO];
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

/*- (void)setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
    if(alpha == 0 || !self.userInteractionEnabled)
        [self unloadAll];
    else
        [self scrollViewDidScroll:nil];
}*/


-(void)addTo:(NSString *)bundle sender:(DBAppIcon *)sender{
    if(![[dict objectForKey:@"AllApps"] boolValue])
        [appsArray replaceObjectAtIndex:sender.tag withObject:bundle];
}

-(void)doActions{
    if([dict objectForKey:@"Actions"])
        [DBActionParser parseActionArray:[dict objectForKey:@"Actions"]];
}

@end
