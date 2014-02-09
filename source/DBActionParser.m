#import "DBActionParser.h"

@interface DBActionParser ()
//private methods


+(BOOL)parseStringAction:(NSString *)action;
+(BOOL)parseBlockAction:(NSDictionary *)action;
+(BOOL)parseConditional:(NSString *)cmd;
+(BOOL)parseBool:(NSString*)b;

+(void)parseGetters:(NSMutableArray*)splitActions;
+(void)parseArithmetic:(NSMutableArray*)splitActions;
+(NSString*)concatString:(NSArray*)splitActions;

+(void)recurrm:(NSDictionary *)dict;

@end

@implementation DBActionParser

+(BOOL)parseAction:(id)_action{
    if([_action isKindOfClass:[NSString class]])
        return [DBActionParser parseStringAction:(NSString*)_action];
    else if([_action isKindOfClass:[NSDictionary class]])
        return [DBActionParser parseBlockAction:(NSDictionary*)_action];
    return NO;
}

+(BOOL)parseBlockAction:(NSDictionary *)action{
    BOOL good = YES;
    for(NSString *b in action[@"if"]){
        NSMutableArray *splitActions = [[b componentsSeparatedByString:@" "] mutableCopy];
        [DBActionParser parseGetters:splitActions];
        good &= [DBActionParser parseBool:[DBActionParser concatString:splitActions]];
    }
    if(good)
        return [DBActionParser parseActionArray:action[@"then"]];
    else if(action[@"else"])
        return [DBActionParser parseActionArray:action[@"else"]];
    return NO;
}

+(BOOL)parseConditional:(NSString *)cmd{
    NSString *cond = [cmd componentsSeparatedByString:@" ? "][0];
    NSArray *split3 = [[cmd componentsSeparatedByString:@" ? "][1] componentsSeparatedByString:@" : "];
    BOOL go = [DBActionParser parseBool:cond];
    if(go) return [DBActionParser parseActionArray:[split3[0] componentsSeparatedByString:@", "]];
    else return [DBActionParser parseActionArray:[split3[1] componentsSeparatedByString:@", "]];
}

+(BOOL)parseStringAction:(NSString *)action{
    DBTheme *dbtheme = [DreamBoard sharedInstance].dbtheme;
    if([action isEqualToString:@"nothing"])
        return NO;
    if([action isEqualToString:@"stop"])
        return YES;
    
    NSMutableArray *splitActions = [[action componentsSeparatedByString:@" "] mutableCopy];
    [DBActionParser parseGetters:splitActions];
    
    if ([splitActions containsObject:@"?"])
        return [DBActionParser parseConditional:[DBActionParser concatString:splitActions]];
    
    NSString *cmd = splitActions[0];
    NSString *arg1 = nil;
    if( splitActions.count > 1)
        arg1 = splitActions[1];
    NSString *arg2 = nil;
    if( splitActions.count > 2)
        arg2 = splitActions[2];
    
    if([cmd isEqualToString:@"launch"]){
        [[DreamBoard sharedInstance] launchBundleId:arg1];
    }
    else if([cmd isEqualToString:@"hide"]){
        UIView *temp = [dbtheme getView:arg1];
        if(temp){
            [UIView animateWithDuration:0.5 animations:^{ temp.alpha = 0; }];
            temp.userInteractionEnabled = NO;
        }
    }
    else if([cmd isEqualToString:@"show"]){
        UIView *temp = [dbtheme getView:arg1];
        if(temp){
            [UIView animateWithDuration:0.5 animations:^{ temp.alpha = 1; }];
            temp.userInteractionEnabled = [dbtheme viewIsInteractive:arg1];
        }
    }
    else if([cmd isEqualToString:@"scrollxto"]){
        UIScrollView *temp = [dbtheme getView:arg1];
        if(temp)
            [temp setContentOffset:CGPointMake([arg2 floatValue], temp.contentOffset.y) animated:NO];
    }
    else if([cmd isEqualToString:@"scrollyto"]){
        UIScrollView *temp = [dbtheme getView:arg1];
        if(temp)
            [temp setContentOffset:CGPointMake(temp.contentOffset.x, [arg2 floatValue]) animated:NO];
    }
    else if([cmd isEqualToString:@"toggle"]){
        UIView *temp = [dbtheme getView:arg1];
        if(temp){
            [UIView animateWithDuration:0.5 animations:^{
                if( [dbtheme toggle:arg1]){
                    temp.alpha = 0;
                    temp.userInteractionEnabled = NO;
                }else{
                    temp.alpha = 1;
                    temp.userInteractionEnabled = [dbtheme viewIsInteractive:arg1];
                }
            }];
        }
    }
    else if([cmd isEqualToString:@"setx"]){
        UIView *temp = [dbtheme getView:arg1];
        if(temp){
            [UIView animateWithDuration:0.5 animations:^{
                temp.frame = CGRectMake([arg2 floatValue], temp.frame.origin.y,
                                        temp.frame.size.width, temp.frame.size.height);
            }];
        }
    }
    else if([cmd isEqualToString:@"sety"]){
        UIView *temp = [dbtheme getView:arg1];
        if(temp){
            [UIView animateWithDuration:0.5 animations:^{
                temp.frame = CGRectMake(temp.frame.origin.x,[arg2 floatValue],
                                        temp.frame.size.width, temp.frame.size.height);
            }];
        }
    }else if([cmd isEqualToString:@"set"]){
        NSString *val = arg1;
        UIView *view = [dbtheme getView:splitActions[3]];
        BOOL animated = NO;
        if(splitActions.count>5 && [splitActions[4] isEqualToString:@"YES"])
            animated = YES;
        if(animated){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:[splitActions[5] floatValue]];
        }
        
        if([val isEqualToString:@"x"])
            view.frame = CGRectMake([arg2 floatValue],
                                    view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        else if([val isEqualToString:@"y"])
            view.frame = CGRectMake(view.frame.origin.x,
                                    [arg2 floatValue], view.frame.size.width, view.frame.size.height);
        else if([val isEqualToString:@"width"])
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, [arg2 floatValue], view.frame.size.height);
        else if([val isEqualToString:@"height"])
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [arg2 floatValue]);
        else if([val isEqualToString:@"alpha"])
            view.alpha = [arg2 floatValue];
        else if([val isEqualToString:@"contentOffsetX"])
            [(UIScrollView *)view setContentOffset:CGPointMake([arg2 floatValue], ((UIScrollView *)view).contentOffset.y)
                                          animated:animated];
        else if([val isEqualToString:@"contentOffsetY"])
            [(UIScrollView *)view setContentOffset:CGPointMake(((UIScrollView *)view).contentOffset.x,[arg2 floatValue])
                                          animated:animated];
        else if([val isEqualToString:@"userInteraction"])
            view.userInteractionEnabled = [arg2 isEqualToString:@"YES"];
        else if([val isEqualToString:@"rotation"])
            view.transform = CGAffineTransformMakeRotation([arg2 floatValue]*M_PI/180.);
        else if([val isEqualToString:@"image"])
            ((UIImageView *) view).image = [UIImage imageWithContentsOfFile:
                                            [NSString stringWithFormat:@"%@/DreamBoard/%@/%@", MAINPATH,[[DreamBoard sharedInstance] currentTheme], arg2]];
        else if([val isEqualToString:@"URL"]){
            if([view isKindOfClass:[DBWebView class]])
                [(DBWebView *)view loadRequest:
                 [NSURLRequest requestWithURL:
                  [NSURL fileURLWithPath:
                   [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",arg2, MAINPATH]]]]];
            else
                [(UIWebDocumentView *)view loadRequest:
                 [NSURLRequest requestWithURL:
                  [NSURL fileURLWithPath:
                   [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",arg2, MAINPATH]]]]];
        }
        
        if(animated)
            [UIView commitAnimations];
    }else if([cmd isEqualToString:@"setanimations"]){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[splitActions[1] floatValue]];
    }else if([cmd isEqualToString:@"startanimations"])
        [UIView commitAnimations];
    else if([cmd isEqualToString:@"setvar"])
        [dbtheme setVariable:arg2 value:arg1];
    else if([cmd isEqualToString:@"savevar"])
        [dbtheme savePlist];
    else if([cmd isEqualToString:@"function"])
        [DBActionParser parseActionArray:[dbtheme getFunction:arg1]];
    else if([cmd isEqualToString:@"insertview"]){
        if([dbtheme getView:arg1] || ![dbtheme getDynamicView:arg1] )
            return NO;
        NSMutableDictionary *tdict = [dbtheme getDynamicView:arg1];
        UIView *v = [dbtheme loadView:tdict];
        UIView *sup = [dbtheme getView:splitActions[3]];
        if([arg2 isEqualToString:@"to"])
            [sup addSubview:v];
        else if([arg2 isEqualToString:@"above"])
            [[sup superview] insertSubview:v aboveSubview:sup];
        else
            [[sup superview] insertSubview:v belowSubview:sup];
        [dbtheme addView:arg1 view:v];
    }else if([cmd isEqualToString:@"removeview"]){
        if( ![dbtheme getView:arg1] || ![dbtheme getDynamicView:arg1])
            return NO;
        UIView *v = [dbtheme getView:arg1];
        [DBActionParser recurrm:[dbtheme getDynamicView:arg1]];
        [v removeFromSuperview];
    }else if([cmd isEqualToString:@"hidestatusbar"])
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    else if([cmd isEqualToString:@"showstatusbar"])
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    else if([cmd hasPrefix:@"views."]){
        NSArray *tempArray = [cmd componentsSeparatedByString:@"."];
        
        if(tempArray.count<3){
            [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid setter, missing values: %@", action] shouldExit:NO];
            return NO;
        }
        
        NSString *viewName = tempArray[1];
        NSString *property = tempArray[2];
        
        UIView *view = [dbtheme getView:viewName];
        
        if(!view){
            [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"View not found: %@", action] shouldExit:NO];
            return NO;
        }
        
        BOOL animated = splitActions.count==4 && [splitActions[3] hasPrefix:@"animated:"];
        
        if(animated){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:[[splitActions[3] substringFromIndex:9] floatValue]];
        }
        
        if([property isEqualToString:@"x"])
            view.frame = CGRectMake([arg2 floatValue],
                                    view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        else if([property isEqualToString:@"y"])
            view.frame = CGRectMake(view.frame.origin.x,
                                    [arg2 floatValue], view.frame.size.width, view.frame.size.height);
        else if([property isEqualToString:@"width"])
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, [arg2 floatValue], view.frame.size.height);
        else if([property isEqualToString:@"height"])
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [arg2 floatValue]);
        else if([property isEqualToString:@"alpha"])
            view.alpha = [arg2 floatValue];
        else if([property isEqualToString:@"contentOffsetX"])
            [(UIScrollView *)view setContentOffset:CGPointMake([arg2 floatValue], ((UIScrollView *)view).contentOffset.y) animated:animated];
        else if([property isEqualToString:@"contentOffsetY"])
            [(UIScrollView *)view setContentOffset:CGPointMake(((UIScrollView *)view).contentOffset.x,[arg2 floatValue]) animated:animated];
        else if([property isEqualToString:@"userInteraction"])
            view.userInteractionEnabled = [arg2 isEqualToString:@"YES"];
        else if([property isEqualToString:@"rotation"])
            view.transform = CGAffineTransformMakeRotation([arg2 floatValue]*M_PI/180.);
        else if([property isEqualToString:@"image"])
            ((UIImageView *) view).image = [UIImage imageWithContentsOfFile:
                                            [NSString stringWithFormat:@"%@/DreamBoard/%@/%@", MAINPATH,[[DreamBoard sharedInstance] currentTheme], arg2]];
        else if([property isEqualToString:@"URL"]){
            if([view isKindOfClass:[DBWebView class]])
                [(DBWebView *)view loadRequest:
                 [NSURLRequest requestWithURL:
                  [NSURL fileURLWithPath:
                   [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",arg2, MAINPATH]]]]];
            else
                [(UIWebDocumentView *)view loadRequest:
                 [NSURLRequest requestWithURL:
                  [NSURL fileURLWithPath:
                   [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",arg2, MAINPATH]]]]];
        }else{
            [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Property not found: %@", action] shouldExit:NO];
            return NO;
        }
        if(animated)
            [UIView commitAnimations];
        
    }else if([cmd hasPrefix:@"vars."]){
        NSArray *tempArray = [cmd componentsSeparatedByString:@"."];
        [dbtheme setVariable:tempArray[1] value:arg2];
    }else if([cmd isEqualToString:@"log"]){
        NSLog(@"%@", [self concatString:splitActions]);
    }else if([cmd isEqualToString:@"startediting"] && ![[DreamBoard sharedInstance] isEditing])
        [[DreamBoard sharedInstance] startEditing];
    else if([cmd isEqualToString:@"stopediting"] && [[DreamBoard sharedInstance] isEditing])
        [[DreamBoard sharedInstance] stopEditing];
    else if([cmd isEqualToString:@"unlock"]){
        [[DreamBoard sharedInstance] unlockDevice];
    }
    return NO;
}


+(void)recurrm:(NSDictionary *)dict{
    DBTheme *dbtheme =[DreamBoard sharedInstance].dbtheme;
    if(dict[@"Subviews"])
        for(NSDictionary *view in dict[@"Subviews"])
            [DBActionParser recurrm:view];
    if(dict[@"id"])
        [dbtheme removeView:dict[@"id"]];
}

+(BOOL)parseBool:(NSString*)b{
    NSArray *split2 = [b componentsSeparatedByString:@" "];
    if([split2[1] isEqualToString:@"="] && [split2[0] floatValue]==[split2[2] floatValue])
        return YES;
    else if([split2[1] isEqualToString:@"lt="] && [split2[0] floatValue]<=[split2[2] floatValue])
        return YES;
    else if([split2[1] isEqualToString:@"gt="] && [split2[0] floatValue]>=[split2[2] floatValue])
        return YES;
    else if([split2[1] isEqualToString:@"lt"] && [split2[0] floatValue]<[split2[2] floatValue])
        return YES;
    else if([split2[1] isEqualToString:@"gt"] && [split2[0] floatValue]>[split2[2] floatValue])
        return YES;
    else if([split2[1] isEqualToString:@"!="] && [split2[0] floatValue]!=[split2[2] floatValue])
        return YES;
    return NO;
}


+(BOOL)parseActionArray:(NSArray *)actions{
    for(id action in actions)
        if([DBActionParser parseAction:action])
            return YES;
    return NO;
}


+(void)parseGetters:(NSMutableArray*)splitActions{
    DBTheme *dbtheme = [DreamBoard sharedInstance].dbtheme;

    for(int i = 0; i<splitActions.count; i++){
        NSString *temp = splitActions[i];
        if([temp hasPrefix:@"get."]){
            NSArray *tempArray = [temp componentsSeparatedByString:@"."];
            
            if(tempArray.count<2){
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, missing values: %@", temp] shouldExit:NO];
                return;
            }
            
            if(![tempArray[1] isEqualToString:@"vars"] && ![tempArray[1] isEqualToString:@"views"]){
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, missing vars or views: %@", temp] shouldExit:NO];
                return;
            }
            
            if([tempArray[1] isEqualToString:@"views"]){
                if(tempArray.count<4){
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, missing values: %@", temp] shouldExit:NO];
                    return;
                }
                NSString *viewName = tempArray[2];
                
                UIView *view = [dbtheme getView:viewName];
                
                if(!view){
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"View not found for getter: %@", temp] shouldExit:NO];
                    return;
                }
                
                
                float result = 0;
                NSString *val = tempArray[3];
                
                if([val isEqualToString:@"x"])
                    result = view.frame.origin.x;
                else if([val isEqualToString:@"y"])
                    result = view.frame.origin.y;
                else if([val isEqualToString:@"width"])
                    result = view.frame.size.width;
                else if([val isEqualToString:@"height"])
                    result = view.frame.size.height;
                else if([val isEqualToString:@"alpha"])
                    result = view.alpha;
                else if([val isEqualToString:@"contentOffsetX"])
                    result = [(UIScrollView *)view contentOffset].x;
                else if([val isEqualToString:@"contentOffsetY"])
                    result = [(UIScrollView *)view contentOffset].y;
                else{
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, no such value: %@", temp] shouldExit:NO];
                    return;
                }
                
                splitActions[i] = @(result);
                
            }else{
                if(![dbtheme getVariable:tempArray[2]]){
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Variable not found for getter: %@", temp] shouldExit:NO];
                    return;
                }
                splitActions[i] = [dbtheme getVariable:tempArray[2]];
            }
            
        }
    }
    
    while([splitActions containsObject:@"get"]){
        int index = [splitActions indexOfObject:@"get"];
        UIView *view = [dbtheme getView:splitActions[index+2]];
        NSString *val = splitActions[index+1];
        float result = 0;
        if([val isEqualToString:@"x"])
            result = view.frame.origin.x;
        else if([val isEqualToString:@"y"])
            result = view.frame.origin.y;
        else if([val isEqualToString:@"width"])
            result = view.frame.size.width;
        else if([val isEqualToString:@"height"])
            result = view.frame.size.height;
        else if([val isEqualToString:@"alpha"])
            result = view.alpha;
        else if([val isEqualToString:@"contentOffsetX"])
            result = [(UIScrollView *)view contentOffset].x;
        else if([val isEqualToString:@"contentOffsetY"])
            result = [(UIScrollView *)view contentOffset].y;
        else if([val isEqualToString:@"var"])
            result = [[dbtheme getVariable:splitActions[index+2]] floatValue];
        for(int i = 0; i<3; i++)
            [splitActions removeObjectAtIndex:index];
        [splitActions insertObject:@(result) atIndex:index];
    }
    
    [DBActionParser parseArithmetic:splitActions];
}

+(void)parseArithmetic:(NSMutableArray*)splitActions{
    while([splitActions containsObject:@"*"] || [splitActions containsObject:@"/"]){
        int index = [splitActions indexOfObject:@"*"]>[splitActions indexOfObject:@"/"]?[splitActions indexOfObject:@"/"]:[splitActions indexOfObject:@"*"];
        float one = [splitActions[index-1] floatValue];
        float two = [splitActions[index+1] floatValue];
        float result = 0;
        if([splitActions[index] isEqualToString:@"*"])
            result = one*two;
        else
            result = one/two;
        for(int i = 0; i<3; i++)[splitActions removeObjectAtIndex:index-1];
        [splitActions insertObject:@(result) atIndex:index-1];
    }
    while([splitActions containsObject:@"+"] || [splitActions containsObject:@"-"]){
        int index = [splitActions indexOfObject:@"+"]>[splitActions indexOfObject:@"-"]?[splitActions indexOfObject:@"-"]:[splitActions indexOfObject:@"+"];
        float one = [splitActions[index-1] floatValue];
        float two = [splitActions[index+1] floatValue];
        float result = 0;
        if([splitActions[index] isEqualToString:@"+"])
            result = one+two;
        else
            result = one-two;
        for(int i = 0; i<3; i++)[splitActions removeObjectAtIndex:index-1];
        [splitActions insertObject:@(result) atIndex:index-1];
    }
}

+(NSString*)concatString:(NSArray*)splitActions{
    NSString *cmd = @"";
    for(id tmp in splitActions){
        if([tmp isKindOfClass:[NSNumber class]])
            cmd = [NSString stringWithFormat:@"%@ %.2f", cmd, [tmp floatValue]];
        else
            cmd = [NSString stringWithFormat:@"%@ %@", cmd, tmp];
        
    }
    cmd = [cmd substringFromIndex:1];
    return cmd;
}

@end