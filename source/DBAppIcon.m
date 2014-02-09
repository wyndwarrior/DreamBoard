#import "DBAppIcon.h"

@interface DBAppIcon (){
    CGRect theFrame;
    BOOL touchBegan;
}


@property(nonatomic, strong) UILabel *iconLabel;
@property(nonatomic, strong) UIImageView *shadowImageView;
@property(nonatomic, strong) UIImageView *overlayImageView;
@property(nonatomic, strong) UIImageView *editImageView;
@property(nonatomic, strong) UIImageView *iconImageView;
@property(nonatomic, strong) UIView *badge;
@property(nonatomic, assign) BOOL hasCache;

-(void)dim;
-(void)unDim;

@end

@implementation DBAppIcon

static NSString *cache;

-(id)init{
    self = [super init];
    if (self){
        if([DreamBoard sharedInstance].dbtheme && [[DreamBoard sharedInstance].dbtheme allAppIcons])
            [[[DreamBoard sharedInstance].dbtheme allAppIcons] addObject:self];
    }
    return self;
}

+(void)setCacheLocation:(NSString*)_cache{
    cache = _cache;
}

+(NSString*)cacheLocation{
    return cache;
}

-(void)loadIcon:(BOOL)isEditing shouldCache:(BOOL)shouldCache{
    if(self.loaded)return;
    _loaded = YES;
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@-%dx%d.png", cache, [self.application leafIdentifier], self.cacheWidth, self.cacheHeight];
    self.hasCache = [[NSFileManager defaultManager] fileExistsAtPath:cachePath];
    
    if(self.application && !self.hasCache){
        UIImage *iconImage = nil;
        BOOL isCustom = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/DreamBoard/%@/Icons/%@.png", MAINPATH, [DreamBoard sharedInstance].currentTheme, [self.application displayName]]];
        if (isCustom)
            iconImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/DreamBoard/%@/Icons/%@.png", MAINPATH, [DreamBoard sharedInstance].currentTheme, [self.application displayName]]];
        else
            iconImage = [self.application getIconImage:2];
        if(self.maskImage!=nil && !isCustom)
            iconImage = [DBAppIcon maskImage:iconImage withMask:self.maskImage];
        if(self.shadowImage)
            self.shadowImageView = [[UIImageView alloc] initWithImage:self.shadowImage];
        if(self.overlayImage!=nil && !isCustom)
            self.overlayImageView = [[UIImageView alloc] initWithImage:self.overlayImage];
        self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        if(self.shadowImageView)
            [self addSubview:self.shadowImageView];
        [self addSubview:self.iconImageView];
        if(self.overlayImage)
            [self addSubview:self.overlayImageView];
    }else if(self.application && self.hasCache){
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:cachePath]];
        [self addSubview:self.iconImageView];
    }
    
    if(self.application && !self.hasCache){
        if(self.labelStyle){
            CGRect rect = CGRectMake([self.labelStyle[@"labelX"] intValue],
                                     [self.labelStyle[@"labelY"] intValue],
                                     [self.labelStyle[@"labelWidth"] intValue],
                                     [self.labelStyle[@"labelHeight"] intValue]);
            self.iconLabel = [[UILabel alloc] initWithFrame:rect];
            self.iconLabel.font = [UIFont boldSystemFontOfSize:
                              [self.labelStyle[@"labelFontSize"] intValue]];
            
        }else{
            self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,70,60,12)];
            self.iconLabel.font = [UIFont boldSystemFontOfSize:11];
        }
        
        self.iconLabel.textColor = [UIColor whiteColor];
        self.iconLabel.textAlignment = NSTextAlignmentCenter;
        self.iconLabel.backgroundColor = [UIColor clearColor];
        self.iconLabel.text = [self.application displayName];
        self.iconLabel.userInteractionEnabled = NO;
        
        [self addSubview:self.iconLabel];
    }
    
    if(isEditing){
        self.editImageView = [[UIImageView alloc] initWithImage:self.editImage];
        [self addSubview:self.editImageView];
    }
    
    [self updateFrame];
    
    if (!self.hasCache && self.application && shouldCache)
        [DBAppIcon cacheIconForBundle:[self.application leafIdentifier] view:self];
    
    if(self.application)
        [self updateBadge];
}

-(void)dim{
    touchBegan = YES;
    [UIView animateWithDuration:0.13 animations:^{
        self.alpha = 0.6;
    }];
}

-(void)unDim{
    touchBegan = NO;
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 1;
    } completion:nil];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dim];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if( ![self pointInside:[[touches anyObject] locationInView:self] withEvent:event] )
        [self unDim];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if( touchBegan )
        [self launch];
    [self unDim];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self unDim];
}

-(void)unloadIcon{
    _loaded = NO;
    if(self.overlayImageView){
        [self.overlayImageView removeFromSuperview];
        self.overlayImageView = nil;
    }
    if(self.shadowImageView){
        [self.shadowImageView removeFromSuperview];
        self.shadowImageView = nil;
    }
    if(self.iconImageView){
        [self.iconImageView removeFromSuperview];
        self.iconImageView = nil;
    }
    if(self.editImageView){
        [self.editImageView removeFromSuperview];
        self.editImageView = nil;
    }
    if(self.iconLabel){
        [self.iconLabel removeFromSuperview];
        self.iconLabel = nil;
    }
    if(self.badge){
        [self.badge removeFromSuperview];
        self.badge = nil;
    }
}
-(void)updateBadge{
    SBIcon *ap = (SBIcon*)self.application;
    int val = [ap badgeValue];
    if(val <= 0 && self.badge)
        [self.badge removeFromSuperview];
    else if(val != 0){
        if(self.badge)
            [self.badge removeFromSuperview];
        self.badge = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,14)];
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,10,60,14)];
        badgeLabel.font = [UIFont boldSystemFontOfSize:13];
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.textAlignment = NSTextAlignmentRight;
        badgeLabel.text = [NSString stringWithFormat:@"%d", val];
        badgeLabel.backgroundColor = [UIColor clearColor];
        badgeLabel.opaque = NO;
        UIImageView *stretch = [[UIImageView alloc] initWithFrame:CGRectMake(60-(badgeLabel.text.length*5+15),5,badgeLabel.text.length*5+25,30)];
        stretch.image = [self.badgeImage stretchableImageWithLeftCapWidth:14 topCapHeight:0];
        [self.badge addSubview:stretch];
        [self.badge addSubview:badgeLabel];
        [self addSubview:self.badge];
    }
}

-(void)updateFrame{
    [self setFrame:theFrame];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    theFrame = frame;
    if(self.hasCache){
        self.iconImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        return;
    }
    if(self.shadowImageView)
        self.shadowImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    if(self.editImageView)
        self.editImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    float width, height;
    if(self.dict[@"IconWidth"] && self.dict[@"IconHeight"]){
        width = [self.dict[@"IconWidth"] floatValue];
        height = [self.dict[@"IconHeight"] floatValue];
    }else{
        width = 59; height = 59;
    }
    self.iconImageView.frame = CGRectMake((frame.size.width-width)/2, (frame.size.height-height)/2, width, height);
    if(self.overlayImageView)
        self.overlayImageView.frame = CGRectMake((frame.size.width-width)/2, (frame.size.height-height)/2, width, height);
}

-(void)launch{
    if(self.editImageView){
        CGRect bounds = [[UIScreen mainScreen] bounds];
        DBAppSelectionTable *table = [DBAppSelectionTable sharedTable];
        table.frame = CGRectMake(bounds.origin.x, bounds.origin.y+20, bounds.size.width, bounds.size.height-20);
        table.tableData = [DreamBoard sharedInstance].appsArray;
        table.delegate = self;
        [table setTitle:(self.application==nil?@"No Icon":[self.application displayName])];
        
        [[DreamBoard sharedInstance].window addSubview:table];
    }
    else{
        if(self.grid)
            [self.grid doActions];
        [[DreamBoard sharedInstance] launch:self.application];
    }
}

-(void)addTo:(NSString *)bundle{
    if(self.dict)
        self.dict[@"BundleID"] = bundle;
    self.application = [DBGrid find:bundle];
    if(self.loaded){
        [self unloadIcon];
        [self loadIcon:[DreamBoard sharedInstance].dbtheme.isEditing shouldCache:NO];
    }
    if(self.grid)
        [self.grid addTo:bundle sender:self];
}

-(void)removeFromSuperview{
    //TODO: fix this dealloc check
    if([DreamBoard sharedInstance].dbtheme && ![DreamBoard sharedInstance].dbtheme->isDealloc && [[DreamBoard sharedInstance].dbtheme allAppIcons])
        [[[DreamBoard sharedInstance].dbtheme allAppIcons] removeObject:self];
}

+(UIImage *) maskImage:(UIImage *)image withMask:(UIImage *)maskImage2{
	CGImageRef imageRef = image.CGImage; 
	CGContextRef mainViewContentContext;
	CGColorSpaceRef colorSpace;
	colorSpace = CGColorSpaceCreateDeviceRGB();
	mainViewContentContext = CGBitmapContextCreate (NULL, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef), 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	CGColorSpaceRelease(colorSpace);    
	if (mainViewContentContext==NULL)
        return NULL;
	CGImageRef maskImage = [maskImage2 CGImage];
	CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, CGImageGetWidth(imageRef),CGImageGetHeight(imageRef)), maskImage);
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetWidth(imageRef)), imageRef);
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
	CGImageRelease(mainViewContentBitmapContext);
	return theImage;
}

+(void)cacheIconForBundle:(NSString*)bundle view:(UIView *)view{
    if(![[NSFileManager defaultManager] fileExistsAtPath:cache])
        [[NSFileManager defaultManager] createDirectoryAtPath:cache withIntermediateDirectories:YES attributes:nil error:nil];
    for(int i = 1; i<=2; i++){
        UIGraphicsBeginImageContext( CGSizeMake( view.bounds.size.width*i, view.bounds.size.height*i ) );
        CGContextScaleCTM( UIGraphicsGetCurrentContext(), i, i);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [UIImagePNGRepresentation(viewImage) writeToFile:[NSString stringWithFormat:@"%@/%@-%dx%d%@.png", cache, bundle, ((DBAppIcon*)view).cacheWidth, ((DBAppIcon*)view).cacheHeight, i==1?@"":@"@2x"] atomically:YES]; 
    }
}
@end
