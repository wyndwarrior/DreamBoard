#import "DBActionParser.h"

@implementation DBActionParser
+(BOOL)parseAction:(id)_action{
    DBTheme *dbtheme = [DreamBoard sharedInstance].dbtheme;
    //parse string
    if([_action isKindOfClass:[NSString class]]){
        
        NSString *action = (NSString*)_action;
        if([action isEqualToString:@"nothing"] || [action isEqualToString:@"stop"])return NO;
        
        //note to self: be sure to release this
        NSMutableArray *splitActions = [[action componentsSeparatedByString:@" "] mutableCopy];
        
        [DBActionParser preParse:splitActions];
        
        //@start
        //parse conditionals
        if ([splitActions containsObject:@"?"]) {
            NSString *cmd = [DBActionParser concatString:splitActions];
            NSString *cond = [[cmd componentsSeparatedByString:@" ? "] objectAtIndex:0];
            NSArray *split3 = [[[cmd componentsSeparatedByString:@" ? "] objectAtIndex:1] componentsSeparatedByString:@" : "];
            BOOL go = [DBActionParser parseBool:cond];
            if(go){
                BOOL b = [DBActionParser parseActionArray:[[split3 objectAtIndex:0] componentsSeparatedByString:@", "]];
                if(b){
                    return YES;
                }
            }
            else{ 
                BOOL b = [DBActionParser parseActionArray:[[split3 objectAtIndex:1] componentsSeparatedByString:@", "]];
                if(b){
                    return YES;
                }
            }
            return NO;
        }
        //@end
        
        //@start
        //parse actions
        if([[splitActions objectAtIndex:0] isEqualToString:@"launch"])
        {
            for(int i = 0; i<[[[DreamBoard sharedInstance] appsArray] count]; i++)
                if([[[[[DreamBoard sharedInstance] appsArray] objectAtIndex:i] leafIdentifier] isEqualToString:[splitActions objectAtIndex:1]]){
                    [[[[DreamBoard sharedInstance] appsArray] objectAtIndex:i] launch];
                    break;
                }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"hide"])
        {
            //hide view
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                UIView *temp = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.5];
                temp.alpha = 0;
                [UIView commitAnimations];
                temp.userInteractionEnabled = NO;
            }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"show"])
        {
            //show view
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                UIView *temp = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.5];
                temp.alpha = 1;
                [UIView commitAnimations];
                if([dbtheme->dictViewsInteraction objectForKey:[splitActions objectAtIndex:1]])
                    temp.userInteractionEnabled = [[dbtheme->dictViewsInteraction objectForKey:[splitActions objectAtIndex:1]] boolValue];
                else
                    temp.userInteractionEnabled = YES;
            }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"scrollxto"])
        {
            //scroll a scrollview to
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                UIScrollView *temp = (UIScrollView*)[dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                [temp setContentOffset:CGPointMake([[splitActions objectAtIndex:2] intValue], temp.contentOffset.y) animated:NO];
            }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"scrollyto"])
        {
            //scroll a scrollview to
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                UIScrollView *temp = (UIScrollView*)[dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                [temp setContentOffset:CGPointMake(temp.contentOffset.x, [[splitActions objectAtIndex:2] intValue]) animated:NO];
            }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"toggle"])
        {
            //toggle view
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                UIView *temp = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.5];
                if([[dbtheme->dictViewsToggled objectForKey:[splitActions objectAtIndex:1]] boolValue]){
                    temp.alpha = 0;
                }else{
                    temp.alpha = 1;
                }

                [UIView commitAnimations];

                if([[dbtheme->dictViewsToggled objectForKey:[splitActions objectAtIndex:1]] boolValue]){
                    temp.userInteractionEnabled = [[dbtheme->dictViewsInteraction objectForKey:[splitActions objectAtIndex:1]] boolValue];
                    [dbtheme->dictViewsToggled setObject:[NSNumber numberWithBool:NO] forKey:[splitActions objectAtIndex:1]];
                }else{
                    temp.userInteractionEnabled = [[dbtheme->dictViewsToggledInteraction objectForKey:[splitActions objectAtIndex:1]] boolValue];
                    [dbtheme->dictViewsToggled setObject:[NSNumber numberWithBool:YES] forKey:[splitActions objectAtIndex:1]];
                }
            }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"setx"])
        {
            //move x
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.5];
                UIView *temp = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                temp.frame = CGRectMake([[splitActions objectAtIndex:2] intValue], temp.frame.origin.y,
                                        temp.frame.size.width, temp.frame.size.height);
                [UIView commitAnimations];
            }
        }
        else if([[splitActions objectAtIndex:0] isEqualToString:@"sety"])
        {
            //move x
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]){
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:.5];
                UIView *temp = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
                temp.frame = CGRectMake(temp.frame.origin.x,[[splitActions objectAtIndex:2] intValue],
                                        temp.frame.size.width, temp.frame.size.height);
                [UIView commitAnimations];
            }
        }
        
        //new parser, setters
        
        else if([[splitActions objectAtIndex:0] isEqualToString:@"set"]){
            NSString *val = [splitActions objectAtIndex:1];
            UIView *view = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:3]];
            BOOL animated = NO;
            if(splitActions.count>5 && [[splitActions objectAtIndex:4] isEqualToString:@"YES"])
                animated = YES;
            if(animated){
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:[[splitActions objectAtIndex:5] floatValue]];
            }
            
            if([val isEqualToString:@"x"])
                view.frame = CGRectMake([[splitActions objectAtIndex:2] floatValue],
                                        view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            else if([val isEqualToString:@"y"])
                view.frame = CGRectMake(view.frame.origin.x,
                                        [[splitActions objectAtIndex:2] floatValue], view.frame.size.width, view.frame.size.height);
            else if([val isEqualToString:@"width"])
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, [[splitActions objectAtIndex:2] floatValue], view.frame.size.height);
            else if([val isEqualToString:@"height"])
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [[splitActions objectAtIndex:2] floatValue]);
            else if([val isEqualToString:@"alpha"])
                view.alpha = [[splitActions objectAtIndex:2] floatValue];
            else if([val isEqualToString:@"contentOffsetX"])
                [(UIScrollView *)view setContentOffset:CGPointMake([[splitActions objectAtIndex:2] floatValue], ((UIScrollView *)view).contentOffset.y)
                                              animated:animated];
            else if([val isEqualToString:@"contentOffsetY"])
                [(UIScrollView *)view setContentOffset:CGPointMake(((UIScrollView *)view).contentOffset.x,[[splitActions objectAtIndex:2] floatValue])
                                              animated:animated];
            else if([val isEqualToString:@"userInteraction"])
                view.userInteractionEnabled = [[splitActions objectAtIndex:2] isEqualToString:@"YES"];
            else if([val isEqualToString:@"rotation"])
                view.transform = CGAffineTransformMakeRotation([[splitActions objectAtIndex:2] floatValue]*M_PI/180.);
            else if([val isEqualToString:@"image"])
                ((UIImageView *) view).image = [UIImage imageWithContentsOfFile:
                                                [NSString stringWithFormat:@"%@/DreamBoard/%@/%@", MAINPATH,[[DreamBoard sharedInstance] currentTheme], [splitActions objectAtIndex:2]]];
            else if([val isEqualToString:@"URL"]){
                if([view isKindOfClass:[DBWebView class]])
                    [(DBWebView *)view loadRequest:
                     [NSURLRequest requestWithURL:
                      [NSURL fileURLWithPath:
                       [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",[splitActions objectAtIndex:2], MAINPATH]]]]];
                else
                    [(UIWebDocumentView *)view loadRequest:
                     [NSURLRequest requestWithURL:
                      [NSURL fileURLWithPath:
                       [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",[splitActions objectAtIndex:2], MAINPATH]]]]];
            }
            
            if(animated)
                [UIView commitAnimations];
        }else if([[splitActions objectAtIndex:0] isEqualToString:@"setanimations"]){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:[[splitActions objectAtIndex:1] floatValue]];
        }else if([[splitActions objectAtIndex:0] isEqualToString:@"startanimations"])
            [UIView commitAnimations];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"setvar"])
            [dbtheme->dictVars setObject:[splitActions objectAtIndex:1] forKey:[splitActions objectAtIndex:2]];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"savevar"])
            [dbtheme savePlist];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"function"])
            [DBActionParser parseActionArray:[dbtheme->functions objectForKey:[splitActions objectAtIndex:1]]];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"insertview"]){
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]!=nil || [dbtheme->dictDynViews objectForKey:[splitActions objectAtIndex:1]]==nil){ return NO;}
            NSMutableDictionary *tdict = [[dbtheme->dictDynViews objectForKey:[splitActions objectAtIndex:1]] mutableCopy];
            UIView *v = [dbtheme loadView:tdict];
            [dbtheme->dictDynViews setObject:tdict forKey:[splitActions objectAtIndex:1]];
            UIView *sup = [[splitActions objectAtIndex:3] isEqualToString:@"MainView"]?dbtheme->mainView:[dbtheme->dictViews objectForKey:[splitActions objectAtIndex:3]];
            if([[splitActions objectAtIndex:2] isEqualToString:@"to"])
                [sup addSubview:v];
            else if([[splitActions objectAtIndex:2] isEqualToString:@"above"])
                [[sup superview] insertSubview:v aboveSubview:sup];
            else
                [[sup superview] insertSubview:v belowSubview:sup];
            [dbtheme->dictViews setObject:v forKey:[splitActions objectAtIndex:1]];
        }
        
        else if([[splitActions objectAtIndex:0] isEqualToString:@"removeview"]){
            if([dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]]==nil || [dbtheme->dictDynViews objectForKey:[splitActions objectAtIndex:1]]==nil){return NO;}
            UIView *v = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:1]];
            [DBActionParser recurrm:[dbtheme->dictDynViews objectForKey:[splitActions objectAtIndex:1]]];
            [v removeFromSuperview];
        }else if([[splitActions objectAtIndex:0] isEqualToString:@"hidestatusbar"])
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"showstatusbar"])
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        
        else if([[splitActions objectAtIndex:0] hasPrefix:@"views."])
        {
            NSArray *tempArray = [[splitActions objectAtIndex:0] componentsSeparatedByString:@"."];
            
            if((int)tempArray.count<3){
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid setter, missing values: %@", action] shouldExit:NO];
                return NO;
            }
            
            NSString *viewName = [tempArray objectAtIndex:1];
            NSString *property = [tempArray objectAtIndex:2];
            
            if(![dbtheme->dictViews objectForKey:viewName]){
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"View not found: %@", action] shouldExit:NO];
                return NO;
            }
            
            if((int)splitActions.count==4 && [[splitActions objectAtIndex:3] hasPrefix:@"animated:"]){
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:[[[splitActions objectAtIndex:3] substringFromIndex:9] floatValue]];
            }
            
            UIView *view = [dbtheme->dictViews objectForKey:viewName];
            
            if([property isEqualToString:@"x"])
                view.frame = CGRectMake([[splitActions objectAtIndex:2] floatValue],
                                        view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            else if([property isEqualToString:@"y"])
                view.frame = CGRectMake(view.frame.origin.x,
                                        [[splitActions objectAtIndex:2] floatValue], view.frame.size.width, view.frame.size.height);
            else if([property isEqualToString:@"width"])
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, [[splitActions objectAtIndex:2] floatValue], view.frame.size.height);
            else if([property isEqualToString:@"height"])
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, [[splitActions objectAtIndex:2] floatValue]);
            else if([property isEqualToString:@"alpha"])
                view.alpha = [[splitActions objectAtIndex:2] floatValue];
            else if([property isEqualToString:@"contentOffsetX"])
                [(UIScrollView *)view setContentOffset:CGPointMake([[splitActions objectAtIndex:2] floatValue], ((UIScrollView *)view).contentOffset.y)
                                              animated:(int)tempArray.count==4 && [[tempArray objectAtIndex:3] hasPrefix:@"animated:"]];
            else if([property isEqualToString:@"contentOffsetY"])
                [(UIScrollView *)view setContentOffset:CGPointMake(((UIScrollView *)view).contentOffset.x,[[splitActions objectAtIndex:2] floatValue])
                                              animated:(int)tempArray.count==4 && [[tempArray objectAtIndex:3] hasPrefix:@"animated:"]];
            else if([property isEqualToString:@"userInteraction"])
                view.userInteractionEnabled = [[splitActions objectAtIndex:2] isEqualToString:@"YES"];
            else if([property isEqualToString:@"rotation"])
                view.transform = CGAffineTransformMakeRotation([[splitActions objectAtIndex:2] floatValue]*M_PI/180.);
            else if([property isEqualToString:@"image"])
                ((UIImageView *) view).image = [UIImage imageWithContentsOfFile:
                                                [NSString stringWithFormat:@"%@/DreamBoard/%@/%@", MAINPATH,[[DreamBoard sharedInstance] currentTheme], [splitActions objectAtIndex:2]]];
            else if([property isEqualToString:@"URL"]){
                if([view isKindOfClass:[DBWebView class]])
                    [(DBWebView *)view loadRequest:
                     [NSURLRequest requestWithURL:
                      [NSURL fileURLWithPath:
                       [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",[splitActions objectAtIndex:2], MAINPATH]]]]];
                else
                    [(UIWebDocumentView *)view loadRequest:
                     [NSURLRequest requestWithURL:
                      [NSURL fileURLWithPath:
                       [DreamBoard replaceRootDir:[NSString stringWithFormat:@"%@%@",[splitActions objectAtIndex:2], MAINPATH]]]]];
            }else{
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Property not found: %@", action] shouldExit:NO];
                return NO;
            }
            
            if((int)splitActions.count==4 && [[splitActions objectAtIndex:3] hasPrefix:@"animated:"])
                [UIView commitAnimations];
            
        }else if([[splitActions objectAtIndex:0] hasPrefix:@"vars."]){
            NSArray *tempArray = [[splitActions objectAtIndex:0] componentsSeparatedByString:@"."];
            [dbtheme->dictVars setObject:[splitActions objectAtIndex:2] forKey:[tempArray objectAtIndex:1]];
        }else if([[splitActions objectAtIndex:0] isEqualToString:@"log"])
            system([[NSString stringWithFormat:@"echo \"%@\" >> /DreamBoard/dreamboard.log", [self concatString:splitActions]] UTF8String]);
        else if([[splitActions objectAtIndex:0] isEqualToString:@"startediting"] && ![[DreamBoard sharedInstance] isEditing])
            [[DreamBoard sharedInstance] startEditing];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"stopediting"] && [[DreamBoard sharedInstance] isEditing])
            [[DreamBoard sharedInstance] stopEditing];
        else if([[splitActions objectAtIndex:0] isEqualToString:@"unlock"]){
            id ac =[objc_getClass("SBAwayController") sharedAwayController];
            if([ac respondsToSelector:@selector(unlockWithSound:isAutoUnlock:)])
                [ac unlockWithSound:YES isAutoUnlock:NO];
            else if( [ac respondsToSelector:@selector(_unlockWithSound:isAutoUnlock:)] )
                [ac _unlockWithSound:YES isAutoUnlock:NO];
            else if( [ac respondsToSelector:@selector(unlockWithSound:)] )
                [ac unlockWithSound:YES];
        }
        
        //@end
        
    }
    
    
    //parse dictionary
    else if([_action isKindOfClass:[NSDictionary class]]){
        NSDictionary *action = (NSDictionary*)_action;
        BOOL good = YES;
        for(NSString *b in [action objectForKey:@"if"]){
            NSMutableArray *splitActions = [[b componentsSeparatedByString:@" "] mutableCopy];
            [DBActionParser preParse:splitActions];
            good &= [DBActionParser parseBool:[DBActionParser concatString:splitActions]];
        }
        
        if(good)[DBActionParser parseActionArray:[action objectForKey:@"then"]];
        else if([action objectForKey:@"else"])
            [DBActionParser parseActionArray:[action objectForKey:@"else"]];
    }
    return NO;
}


+(void)recurrm:(NSDictionary *)dict{
    DBTheme *dbtheme =[DreamBoard sharedInstance].dbtheme;
    if([dict objectForKey:@"Subviews"])
        for(NSDictionary *view in [dict objectForKey:@"Subviews"])
            [DBActionParser recurrm:view];
    if([dict objectForKey:@"id"])
        [dbtheme->dictViews removeObjectForKey:[dict objectForKey:@"id"]];
}

+(BOOL)parseBool:(NSString*)b{
    NSArray *split2 = [b componentsSeparatedByString:@" "];
    if([[split2 objectAtIndex:1] isEqualToString:@"="] && [[split2 objectAtIndex:0] floatValue]==[[split2 objectAtIndex:2] floatValue]){
        return YES;
    }else if([[split2 objectAtIndex:1] isEqualToString:@"lt="] && [[split2 objectAtIndex:0] floatValue]<=[[split2 objectAtIndex:2] floatValue])
        return YES;
    else if([[split2 objectAtIndex:1] isEqualToString:@"gt="] && [[split2 objectAtIndex:0] floatValue]>=[[split2 objectAtIndex:2] floatValue])
        return YES;
    else if([[split2 objectAtIndex:1] isEqualToString:@"lt"] && [[split2 objectAtIndex:0] floatValue]<[[split2 objectAtIndex:2] floatValue])
        return YES;
    else if([[split2 objectAtIndex:1] isEqualToString:@"gt"] && [[split2 objectAtIndex:0] floatValue]>[[split2 objectAtIndex:2] floatValue])
        return YES;
    else if([[split2 objectAtIndex:1] isEqualToString:@"!="] && [[split2 objectAtIndex:0] floatValue]!=[[split2 objectAtIndex:2] floatValue])
        return YES;
    return NO;
}

+(void)preParse:(NSMutableArray*)splitActions{
    DBTheme *dbtheme = [DreamBoard sharedInstance].dbtheme;
    //@start
    //parse getters
    for(int i = 0; i<splitActions.count; i++){
        NSString *temp = [splitActions objectAtIndex:i];
        if([temp hasPrefix:@"get."]){
            NSArray *tempArray = [temp componentsSeparatedByString:@"."];
            
            if(tempArray.count<2){
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, missing values: %@", temp] shouldExit:NO];
                return;
            }
            
            if(![[tempArray objectAtIndex:1] isEqualToString:@"vars"] && ![[tempArray objectAtIndex:1] isEqualToString:@"views"]){
                [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, missing vars or views: %@", temp] shouldExit:NO];
                return;
            }
            
            if([[tempArray objectAtIndex:1] isEqualToString:@"views"]){
                if(tempArray.count<4){
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Invalid Getter, missing values: %@", temp] shouldExit:NO];
                    return;
                }
                NSString *viewName = [tempArray objectAtIndex:2];
                
                if(![dbtheme->dictViews objectForKey:viewName]){
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"View not found for getter: %@", temp] shouldExit:NO];
                    return;
                }
                
                UIView *view = [dbtheme->dictViews objectForKey:viewName];
                
                float result = 0;
                NSString *val = [tempArray objectAtIndex:3];
                
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
                
                [splitActions replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:result]];
                
            }else{
                if(![dbtheme->dictVars objectForKey:[tempArray objectAtIndex:2]]){
                    [DreamBoard throwRuntimeException:[NSString stringWithFormat:@"Variable not found for getter: %@", temp] shouldExit:NO];
                    return;
                }
                [splitActions replaceObjectAtIndex:i withObject:[dbtheme->dictVars objectForKey:[tempArray objectAtIndex:2]]];
            }
            
        }
    }
    
    while([splitActions containsObject:@"get"]){
        int index = [splitActions indexOfObject:@"get"];
        UIView *view = [dbtheme->dictViews objectForKey:[splitActions objectAtIndex:index+2]];
        NSString *val = [splitActions objectAtIndex:index+1];
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
            result = [[dbtheme->dictVars objectForKey:[splitActions objectAtIndex:index+2]] floatValue];
        for(int i = 0; i<3; i++)[splitActions removeObjectAtIndex:index];
        [splitActions insertObject:[NSNumber numberWithFloat:result] atIndex:index];
    }
    
    //@end
    
    //@start
    //parse arithmetic
    while([splitActions containsObject:@"*"] || [splitActions containsObject:@"/"]){
        int index = [splitActions indexOfObject:@"*"]>[splitActions indexOfObject:@"/"]?[splitActions indexOfObject:@"/"]:[splitActions indexOfObject:@"*"];
        float one = [[splitActions objectAtIndex:index-1] floatValue];
        float two = [[splitActions objectAtIndex:index+1] floatValue];
        float result = 0;
        if([[splitActions objectAtIndex:index] isEqualToString:@"*"])
            result = one*two;
        else
            result = one/two;
        for(int i = 0; i<3; i++)[splitActions removeObjectAtIndex:index-1];
        [splitActions insertObject:[NSNumber numberWithFloat:result] atIndex:index-1];
    }
    while([splitActions containsObject:@"+"] || [splitActions containsObject:@"-"]){
        int index = [splitActions indexOfObject:@"+"]>[splitActions indexOfObject:@"-"]?[splitActions indexOfObject:@"-"]:[splitActions indexOfObject:@"+"];
        float one = [[splitActions objectAtIndex:index-1] floatValue];
        float two = [[splitActions objectAtIndex:index+1] floatValue];
        float result = 0;
        if([[splitActions objectAtIndex:index] isEqualToString:@"+"])
            result = one+two;
        else
            result = one-two;
        for(int i = 0; i<3; i++)[splitActions removeObjectAtIndex:index-1];
        [splitActions insertObject:[NSNumber numberWithFloat:result] atIndex:index-1];
    }
    //@end
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

+(BOOL)parseActionArray:(NSArray *)actions{
    for(id action in actions){
        if([action isKindOfClass:[NSString class]] && [action isEqualToString:@"stop"])
            return YES;
        BOOL b = [DBActionParser parseAction:action];
        if(b)break;
    }
    return NO;
}


@end