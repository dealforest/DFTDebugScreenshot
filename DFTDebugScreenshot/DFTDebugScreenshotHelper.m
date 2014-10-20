//
//  DFTDebugScreenshotHelper.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/21/14.
//
//

#import "DFTDebugScreenshotHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString * const kDFTDebugScreenshotBunbleName = @"DFTDebugScreenshot";
static NSString * const kDFTDebugScreenshotStringTable = @"DFTDebugScreenshotLocalizable";

@implementation DFTDebugScreenshotHelper

+ (NSBundle *)bundle {
    NSString *path = [[NSBundle mainBundle] pathForResource:kDFTDebugScreenshotBunbleName ofType:@"bundle"];
    return [NSBundle bundleWithPath:path];
}

+ (void)showAlertWithLocalizedKey:(NSString *)key {
    NSString *callerString = [[NSThread callStackSymbols] objectAtIndex:1];
    NSCharacterSet *separators = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *caller = [NSMutableArray arrayWithArray:[callerString componentsSeparatedByCharactersInSet:separators]];
    [caller removeObject:@""];

    NSString *message = NSLocalizedStringFromTableInBundle(key, kDFTDebugScreenshotStringTable, [self bundle], nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:caller[4]
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark AssetsLibrary

+ (BOOL)isEnablePhotosAccess {
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized: {
            return YES;
        }
        case ALAuthorizationStatusNotDetermined: {
            return YES;
        }
        case ALAuthorizationStatusRestricted: {
            [self showAlertWithLocalizedKey:@"DENY_RESTRINCTIONS"];
            return NO;
        }
        case ALAuthorizationStatusDenied: {
            [self showAlertWithLocalizedKey:@"DENY_PRIVACY"];
            return NO;
        }
        default: {
            return NO;
        }
    }
}

@end
