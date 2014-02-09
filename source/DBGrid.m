#import "DBGrid.h"

@interface DBGrid (){
    int ROWS, COLS, GAPX, GAPY, PAGEGAPX, PAGEGAPY;
}

@property(nonatomic, strong) NSMutableArray *appsArray;
@property(nonatomic, strong) NSMutableDictionary *dict;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end


@implementation DBGrid
- (id)initWithDict:(NSMutableDictionary *)__dict
{
    self = [super init];
    if (self) {
        self.dict = __dict;
        if(self.dict[@"Apps"]){
            self.appsArray = [self.dict[@"Apps"] mutableCopy];
            self.dict[@"Apps"] = self.appsArray;
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
    ROWS = self.dict[@"Rows"]?[self.dict[@"Rows"] intValue]:9999;
    COLS = self.dict[@"Cols"]?[self.dict[@"Cols"] intValue]:9999;
    GAPX = [self.dict[@"GapX"] intValue];
    GAPY = [self.dict[@"GapY"] intValue];
    if(self.dict[@"PageGapX"] && self.dict[@"PageGapY"]){
        PAGEGAPX = [self.dict[@"PageGapX"] intValue];
        PAGEGAPY = [self.dict[@"PageGapY"] intValue];
    }else
        PAGEGAPY = [self.dict[@"PageHeight"] intValue];
    
    
    int NUM = ROWS*COLS,
    ICONW = [self.dict[@"IconWidth"] intValue],
    ICONH = [self.dict[@"IconHeight"] intValue];
    BOOL allApps = [self.dict[@"AllApps"] boolValue];
    
    int maxX = 0;
    int maxY = 0;
    NSArray *theArray = allApps?[[DreamBoard sharedInstance] appsArray]:self.appsArray;
    for(int i = 0; i<theArray.count;)
        for(int r  = 0; r<ROWS && i<theArray.count; r++)
            for(int c = 0; c<COLS && i<theArray.count; c++, i++){
                DBAppIcon *appIcon = [[DBAppIcon alloc] init];
                appIcon.application = allApps?theArray[i]:[DBGrid find:theArray[i]];
                appIcon.badgeImage = self.badgeImage;
                appIcon.overlayImage = self.overlayImage;
                appIcon.shadowImage = self.shadowImage;
                appIcon.maskImage = self.maskImage;
                appIcon.editImage = self.editImage;
                appIcon.cacheWidth = ICONW;
                appIcon.cacheHeight = ICONH;
                appIcon.grid = self;
                appIcon.tag = i;
                appIcon.labelStyle = self.dict[@"LabelStyle"];
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
            DBAppIcon *icon = (DBAppIcon *)view;
            if(CGRectIntersectsRect(rect, view.frame)){
                if(!icon.loaded)
                    [icon loadIcon:[DreamBoard sharedInstance].dbtheme.isEditing && ![self.dict[@"AllApps"] boolValue] shouldCache:NO];
            }else if(icon.loaded)
                [icon unloadIcon];
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
    if(![self.dict[@"AllApps"] boolValue])
        self.appsArray[sender.tag] = bundle;
}

-(void)doActions{
    if(self.dict[@"Actions"])
        [DBActionParser parseActionArray:self.dict[@"Actions"]];
}

@end
