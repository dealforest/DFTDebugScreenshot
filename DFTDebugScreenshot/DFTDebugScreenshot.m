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

#define DEFAULT_FONT_SIZE 12.f

@interface DFTDebugScreenshot()

@property (nonatomic, assign, getter = isForeground) BOOL foreground;
@property (nonatomic, assign, getter = isTracking) BOOL tracking;
@property (nonatomic, copy) void (^completionBlock)(NSString *, UIImage *);

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

+ (void)completionBlock:(void (^)(NSString *, UIImage *))block {
    if (block) {
        [DFTDebugScreenshot sharedInstance].completionBlock = block;
    }
}

+ (void)capture {
    DFTDebugScreenshot *instance = [DFTDebugScreenshot sharedInstance];
    UIViewController *controller = [instance visibledViewController];
    if (instance.isForeground && [controller respondsToSelector:@selector(outputDataOfScreenShoot)]) {
        id outputData = [controller performSelector:@selector(outputDataOfScreenShoot)];

        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"DFTDebugScreenshotView" owner:self options:nil];
        DFTDebugScreenshotView *debugView = [views firstObject];
        [debugView setTitleText:NSStringFromClass([controller class])
                        message:[outputData debugDescription]];

        UIImage *image = [debugView convertToImage];
        [instance saveImageToPhotosAlbum:image];
        if (instance.completionBlock) {
            instance.completionBlock([outputData debugDescription], image);
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
                 [self showAlertWithMessage:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"];
             }
             else {
                 [self showAlertWithMessage:@"フォトアルバムへ保存しました。"];
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
            // 写真へのアクセスを許可するか選択されていない。許可されるかわからないがYESにしておく
            return YES;
        }
        case ALAuthorizationStatusRestricted: {
            // 設定 > 一般 > 機能制限で利用が制限されている
            [self showAlertWithMessage:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"];
            return NO;
        }
        case ALAuthorizationStatusDenied: {
            // 設定 > プライバシー > 写真で利用が制限されている
            [self showAlertWithMessage:@"写真へのアクセスが許可されていません。\n設定 > プライバシー > 写真で許可してください。"];
            return NO;
        }
        default: {
            return NO;
        }
    }
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSStringFromClass([self class])
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end
