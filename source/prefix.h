//
//  prefix.h
//  DreamBoard
//
//  Created by Andrew Liu on 8/1/13.
//  Copyright (c) 2013 Andrew Liu. All rights reserved.
//

#ifndef DreamBoard_prefix_h
#define DreamBoard_prefix_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define TARGET_THEOS 1

#define _alert(x) 

#define FMAN [NSFileManager defaultManager]
static inline bool dirExists(NSString * path){
    BOOL b;
    BOOL e = [FMAN fileExistsAtPath:path isDirectory:&b];
    return e && b;
}

static inline bool fileExists(NSString * path){
    BOOL b;
    BOOL e = [FMAN fileExistsAtPath:path isDirectory:&b];
    return e && !b;
}
#define createDir(path) ([FMAN createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil])
#define timeStamp(path) [[FMAN attributesOfItemAtPath:path error:nil] fileModificationDate]
#define getDir(path) [FMAN contentsOfDirectoryAtPath:path error:nil]
#define deleteFile(path) [FMAN removeItemAtPath:path error:nil]


#ifdef TARGET_THEOS
#import "Headers/SBAwayController.h"
#import "Headers/SBAwayView.h"
#import "Headers/SBApplicationIcon.h"
#import "Headers/SBUIController.h"
#import "Headers/UIWebDocumentView.h"
#import "Headers/SBUserAgent.h"
#import "Headers/SBCCQuickLaunchSectionController.h"
#import "Headers/UIKeyboard.h"
#define DBPATH @"/var/mobile/Library/DreamBoard"
#define MAINPATH @""
#define CACHEPATH [DBPATH stringByAppendingPathComponent:@"_library/Cache"]


#else
#import "Headers/SBAwayController.h"
#import "Headers/SBAwayView.h"
#import "SBApplicationIcon.h"
#import "Headers/UIWebDocumentView.h"
#import "Headers/UIKeyboard.h"
static inline NSString* documents(){
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

#define BUNDPATH [[NSBundle mainBundle] resourcePath]
#define DOCPATH documents()
#define MAINPATH DOCPATH
#define CACHEPATH [DOCPATH stringByAppendingPathComponent:@"Cache"]
#define DBPATH [DOCPATH stringByAppendingPathComponent:@"DreamBoard"]
#define COPYPATH [BUNDPATH stringByAppendingPathComponent:@"DBFiles"]
#define SBIcon SBApplicationIcon

#endif


#endif
