//
//  DFTDebugScreenshot.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "DFTDebugScreenshot.h"
#import "DFTDebugScreenshotHelper.h"
#import "DFTDebugScreenshotContext.h"
#import "DFTDebugScreenshotAdapter.h"
#import "DFTDebugScreenshotDebugImageAdapter.h"

@implementation DFTDebugScreenshot

static BOOL isForeground = YES;
static BOOL isTracking = NO;
static BOOL isEnableAlert = YES;
static NSMutableArray *adapters;

+ (void)initialize {
    isForeground = YES;
    isTracking = NO;
    isEnableAlert = YES;
    adapters = [NSMutableArray array];
}

+ (BOOL)isTracking {
    return isTracking;
}

+ (void)setTraking:(BOOL)value {
    if (isTracking == value) {
        return;
    }
    else if (value == YES) {
        isTracking = value;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handlingUserDidTakeScreenshotNotification:)
                                                     name:UIApplicationUserDidTakeScreenshotNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handlingWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handlingDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    else {
        isTracking = value;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationUserDidTakeScreenshotNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillResignActiveNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidBecomeActiveNotification
                                                      object:nil];
    }
}

+ (BOOL)getEnableAlert {
    return isEnableAlert;
}

+ (void)setEnableAlert:(BOOL)value {
    isEnableAlert = value;
}

+ (NSArray *)getAdapters {
    return [NSArray arrayWithArray:adapters];
}

+ (void)addAdapter:(DFTDebugScreenshotAdapter *)adapater {
    [adapters addObject:adapater];
}

+ (void)capture {
    DFTDebugScreenshotContext *context = [DFTDebugScreenshotContext new];
    context.message = [[self callerString] stringByAppendingString:@"manual capture"];
    [context searchViewController];
    [context captureCurrentScreen];
    [self invokeProcessWithContext:context];
}

+ (void)captureWithError:(NSError *)error {
    DFTDebugScreenshotContext *context = [DFTDebugScreenshotContext new];
    context.message = [[self callerString] stringByAppendingString:[error description]];
    [context searchViewController];
    [context captureCurrentScreen];
    [self invokeProcessWithContext:context];
}

+ (void)captureWithException:(NSException *)exception {
    DFTDebugScreenshotContext *context = [DFTDebugScreenshotContext new];
    context.message = [[self callerString] stringByAppendingString:[exception description]];
    [context searchViewController];
    [context captureCurrentScreen];
    [self invokeProcessWithContext:context];
}

+ (id)archiveWithObject:(id)object {
    return [[NSKeyedArchiver archivedDataWithRootObject:object] description];
}

+ (id)unarchiveWithObjectHex:(NSString *)hex {
    hex = [hex lowercaseString];
    NSMutableData *data = [NSMutableData new];
    unsigned char whole_byte;
    char byte_chars[3] = { '\0','\0','\0' };
    int i = 0;
    NSUInteger length = hex.length;
    while (i < length - 1) {
        char c = [hex characterAtIndex:i++];
        if (c < '0' || (c > '9' && c < 'a') || c > 'f') continue;

        byte_chars[0] = c;
        byte_chars[1] = [hex characterAtIndex:i++];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

#pragma mark -
#pragma mark observer

+ (void)handlingUserDidTakeScreenshotNotification:(NSNotification *)notification {
    DFTDebugScreenshotContext *context = [DFTDebugScreenshotContext new];
    context.message = @"screenshot";
    [context searchViewController];
    UIImage *screenshot = [self loadScreenshot];
    if (screenshot) {
        context.screenshot = screenshot;
    }
    else {
        [context captureCurrentScreen];
    }
    [self invokeProcessWithContext:context];
}

+ (void)handlingWillResignActiveNotification:(NSNotification *)notification {
    isForeground = NO;
}

+ (void)handlingDidBecomeActiveNotification:(NSNotification *)notification {
    isForeground = YES;
}

#pragma mark -
#pragma mark AssetsLibrary

+ (UIImage *)loadScreenshot {
    if (![DFTDebugScreenshotHelper isEnablePhotosAccess]) return nil;

    // wait for saved the screenshot.
    sleep(1);

    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:3.f];
    ALAssetsLibrary *library = [ALAssetsLibrary new];
    UIImage __block *captureImage;
    BOOL __block loading = YES;
    while (loading) {
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                               usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                                   NSInteger lastPhotoIndex = [group numberOfAssets];
                                   if (lastPhotoIndex > 0) {
                                       [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:lastPhotoIndex -1]
                                                               options:NSEnumerationConcurrent
                                                            usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                                ALAssetRepresentation *representation = [result defaultRepresentation];
                                                                UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]
                                                                                                     scale:[representation scale]
                                                                                               orientation:(UIImageOrientation)[representation orientation]];
                                                                if (!captureImage && image) {
                                                                    captureImage = image;
                                                                    *stop = YES;
                                                                    loading = NO;
                                                                }
                                                            }];
                                   }
                               }
                             failureBlock:^(NSError *error) {
                                 loading = NO;
                             }];
        if ([[NSDate date] compare:timeout] == NSOrderedDescending) {
            loading = NO;
        }
        else {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return captureImage;
}

#pragma mark -
#pragma mark private

+ (void) invokeProcessWithContext:(DFTDebugScreenshotContext *)context {
    if (!isForeground) return;

    NSArray *_adapters = [adapters count] > 0 ? adapters : @[ [DFTDebugScreenshotDebugImageAdapter new] ];
    for (id<DFTDebugScreenshotAdapterProtocol> adapter in _adapters) {
        [adapter processWithContext:context];
    }
}

+ (NSString *)callerString {
    NSString *callerString = [[NSThread callStackSymbols] objectAtIndex:2];
    NSCharacterSet *separators = [NSCharacterSet characterSetWithCharactersInString:@" +?.,"];
    NSMutableArray *caller = [NSMutableArray arrayWithArray:[callerString componentsSeparatedByCharactersInSet:separators]];
    [caller removeObject:@""];
    return [NSString stringWithFormat:@"%@ %@ L%@\n", caller[3], caller[4], caller[5]];
}

@end
