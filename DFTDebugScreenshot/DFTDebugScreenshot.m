//
//  DFTDebugScreenshot.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTDebugScreenshot.h"
#import "DFTDebugScreenshotHelper.h"
#import "DFTDebugScreenshotAdapter.h"
#import "DFTDebugScreenshotDebugImageAdapter.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DFTDebugScreenshot()

@property (nonatomic, assign, getter = isForeground) BOOL foreground;
@property (nonatomic, assign, getter = isTracking) BOOL tracking;
@property (nonatomic, assign) BOOL enableAlert;
@property (nonatomic) NSMutableArray *adapters;

+ (instancetype)sharedInstance;

@end

@implementation DFTDebugScreenshot

+ (instancetype)sharedInstance {
    static DFTDebugScreenshot *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DFTDebugScreenshot new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.foreground = YES;
        self.tracking = NO;
        self.enableAlert = YES;
        self.adapters = [@[] mutableCopy];
    }
    return self;
}

#pragma mark -
#pragma mark class method

+ (BOOL)isTracking {
    return [DFTDebugScreenshot sharedInstance].isTracking;
}

+ (void)setTraking:(BOOL)value {
    DFTDebugScreenshot *instance = [DFTDebugScreenshot sharedInstance];
    if (instance.tracking == value) {
        return;
    }
    else if (value == YES) {
        instance.tracking = value;
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(handlingUserDidTakeScreenshotNotification:)
                                                     name:UIApplicationUserDidTakeScreenshotNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(handlingWillResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:instance
                                                 selector:@selector(handlingDidBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    else {
        instance.tracking = value;
        [[NSNotificationCenter defaultCenter] removeObserver:instance
                                                        name:UIApplicationUserDidTakeScreenshotNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:instance
                                                        name:UIApplicationWillResignActiveNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:instance
                                                        name:UIApplicationDidBecomeActiveNotification
                                                      object:nil];
    }
}

+ (BOOL)getEnableAlert {
    return [DFTDebugScreenshot sharedInstance].enableAlert;
}

+ (void)setEnableAlert:(BOOL)value {
    [DFTDebugScreenshot sharedInstance].enableAlert = value;
}

+ (NSArray *)getAdapters {
    return [NSArray arrayWithArray:[DFTDebugScreenshot sharedInstance].adapters];
}

+ (void)addAdapter:(DFTDebugScreenshotAdapter *)adapater {
    [[DFTDebugScreenshot sharedInstance].adapters addObject:adapater];
}

+ (void)capture {
    DFTDebugScreenshot *instance = [DFTDebugScreenshot sharedInstance];
    UIImage *screenshot = [instance captureCurrentScreen];
    [instance process:screenshot];
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
    int length = hex.length;
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

- (void)handlingUserDidTakeScreenshotNotification:(NSNotification *)notification {
    UIImage *screenshot = [self loadScreenshot] ?: [self captureCurrentScreen];
    [self process:screenshot];
}

- (void)handlingWillResignActiveNotification:(NSNotification *)notification {
    [DFTDebugScreenshot sharedInstance].foreground = NO;
}

- (void)handlingDidBecomeActiveNotification:(NSNotification *)notification {
    [DFTDebugScreenshot sharedInstance].foreground = YES;
}

#pragma mark -
#pragma mark AssetsLibrary

- (UIImage *)loadScreenshot {
    if (![DFTDebugScreenshotHelper isEnablePhotosAccess])
        return nil;

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

- (void)process:(UIImage *)screenshot {
    if (!self.isForeground) return;

    UIViewController *controller = [self visibledViewController];
    NSArray *adapters = [self.adapters count] > 0 ? self.adapters : @[ [DFTDebugScreenshotDebugImageAdapter new] ];
    for (DFTDebugScreenshotAdapter *adapter in adapters) {
        [adapter process:controller screenshot:screenshot];
    }
}

- (UIViewController *)visibledViewController {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [(UINavigationController *)controller visibleViewController];
    }
    return controller;
}

- (UIImage *)captureCurrentScreen {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect frame = controller.view.frame;

    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -CGRectGetMinX(frame), -CGRectGetMinY(frame));
    [controller.view drawViewHierarchyInRect:frame afterScreenUpdates:NO];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return screenshot;
}

@end
