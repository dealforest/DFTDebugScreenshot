//
//  DFTDebugScreenshot.m
//  DFTDebugScreenshotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTDebugScreenshot.h"
#import "DFTDebugScreenshotView.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString * const kDFTDebugScreenshotBunbleName = @"DFTDebugScreenshot";
static NSString * const kDFTDebugScreenshotStringTable = @"DFTDebugScreenshotLocalizable";

@interface DFTDebugScreenshot()

@property (nonatomic, assign, getter = isForeground) BOOL foreground;
@property (nonatomic, assign, getter = isTracking) BOOL tracking;
@property (nonatomic, assign, getter = isAnalyzeAutoLayout) BOOL analyzeAutoLayout;
@property (nonatomic, copy) void (^completionBlock)(UIViewController *, id, UIImage *);

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

#pragma mark -
#pragma mark class method

+ (BOOL)getTracking {
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

+ (BOOL)getAnalyzeAutoLayout {
    [DFTDebugScreenshot sharedInstance].isAnalyzeAutoLayout;
}

+ (void)setAnalyzeAutoLayout:(BOOL)value {
    [DFTDebugScreenshot sharedInstance].analyzeAutoLayout = value;
}

+ (void)completionBlock:(void (^)(UIViewController *, id, UIImage *))block {
    if (block) {
        [DFTDebugScreenshot sharedInstance].completionBlock = block;
    }
}

+ (void)capture {
    DFTDebugScreenshot *instance = [DFTDebugScreenshot sharedInstance];
    UIViewController *controller = [instance visibledViewController];
    if (instance.isForeground) {
        id debugObject = [controller respondsToSelector:@selector(dft_debugObjectOfScreenshot)]
            ? [controller performSelector:@selector(dft_debugObjectOfScreenshot)]
            : nil;

        NSMutableString *message = [@"" mutableCopy];
        [message appendString:[instance formatStringOfDebugObject:debugObject]];
        if (instance.isAnalyzeAutoLayout) {
            [message appendString:[instance formatStringOfConstraints:controller.view]];
        }

        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DFTDebugScreenshotView" owner:self options:nil];
        DFTDebugScreenshotView *debugView = [views firstObject];
        [debugView setTitleText:NSStringFromClass([controller class]) message:message];
        UIImage *image = [debugView convertToImage];
        [instance saveImageToPhotosAlbum:image];

        if (instance.completionBlock) {
            instance.completionBlock(controller, debugObject, image);
        }
    }
}

#pragma mark -
#pragma mark observer

- (void)handlingUserDidTakeScreenshotNotification:(NSNotification *)notification {
    [DFTDebugScreenshot capture];
}

- (void)handlingWillResignActiveNotification:(NSNotification *)notification {
    [DFTDebugScreenshot sharedInstance].foreground = NO;
}

- (void)handlingDidBecomeActiveNotification:(NSNotification *)notification {
    [DFTDebugScreenshot sharedInstance].foreground = YES;
}

#pragma mark -
#pragma mark private

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

- (void)saveImageToPhotosAlbum:(UIImage *)image {
    if ([self isEnablePhotoAccess]) {
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:image.CGImage
                                  orientation:(ALAssetOrientation)image.imageOrientation
                              completionBlock:
         ^(NSURL *assetURL, NSError *error){
             ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
             if (status == ALAuthorizationStatusDenied) {
                 [self showAlertWithLocalizedKey:@"DENY_RESTRINCTIONS"];
             }
             else {
                 [self showAlertWithLocalizedKey:@"SAVED_PHOTO"];
             }
         }];
    }
}

- (BOOL)isEnablePhotoAccess {
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

- (NSString *)formatStringOfDebugObject:(id)debugObject {
    return [NSString stringWithFormat:@"[debug object]\n%@\n\n", [debugObject description]];
}

- (NSString *)formatStringOfConstraints:(UIView *)view {
    NSString * (^formatView)(UIView *, NSUInteger) = ^(UIView *view, NSUInteger nestLevel) {
        //TODO: support UITabelView and UICollectionView
        NSString *prefix = [@"" stringByPaddingToLength:nestLevel * 4 withString:@" " startingAtIndex:0];
        NSMutableString *string = [@"" mutableCopy];
        string = [string stringByAppendingFormat:@"%@- %@\n", prefix, [view description]];

        prefix = [@"" stringByPaddingToLength:(nestLevel + 1) * 4 withString:@" " startingAtIndex:0];
        if ([view.constraints count] > 0) {
            for (NSLayoutConstraint *constraint in view.constraints) {
                string = [string stringByAppendingFormat:@"%@* %@\n", prefix, constraint];
            }
        }
        else {
            string = [string stringByAppendingFormat:@"%@* none\n", prefix, prefix];
        }
        return string;
    };

    NSMutableString *string = [@"[constrains]\n" mutableCopy];
    string = [string stringByAppendingString:formatView(view, 0)];
    for (UIView *subview in view.subviews) {
        string = [string stringByAppendingString:formatView(subview, 1)];
    }
    return [string stringByAppendingString:@"\n"];
}

- (void)showAlertWithLocalizedKey:(NSString *)key {
    NSString *message = NSLocalizedStringFromTableInBundle(key, kDFTDebugScreenshotStringTable, [self bundle], nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSStringFromClass([self class])
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (NSBundle *)bundle {
    NSString *path = [[NSBundle mainBundle] pathForResource:kDFTDebugScreenshotBunbleName ofType:@"bundle"];
    return [NSBundle bundleWithPath:path];
}

@end
