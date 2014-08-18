//
//  DFTDebugScreenShot.m
//  DFNDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTDebugScreenShot.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define DEFAULT_FONT_SIZE 12.f

@interface DFTDebugScreenShot()

@property (nonatomic, assign) BOOL autoCapture;
@property (nonatomic, strong) NSMutableDictionary *drawAttributes;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) void (^completionBlock)(NSString *, UIImage *);

+ (instancetype)sharedInstance;

@end

@implementation DFTDebugScreenShot

+ (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserver:[DFTDebugScreenShot sharedInstance]
                                             selector:@selector(handleScreenShot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

+ (instancetype)sharedInstance {
    static DFTDebugScreenShot *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DFTDebugScreenShot new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.autoCapture = YES;

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        self.drawAttributes = [@{
                                NSFontAttributeName: [UIFont systemFontOfSize:DEFAULT_FONT_SIZE],
                                NSParagraphStyleAttributeName: paragraphStyle,
                                } mutableCopy];

        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setLocale:[NSLocale systemLocale]];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
        self.dateFormatter = formatter;

        __weak typeof(self) wself = self;
        self.completionBlock = ^(NSString * text, UIImage *image) {
            [wself saveImageToPhotosAlbum:image];
        };
    }
    return self;
}

#pragma mark -
#pragma mark accessor

+ (BOOL)getAutoCapture {
    return [DFTDebugScreenShot sharedInstance].autoCapture;
}

+ (void)setAutoCapture:(BOOL)value {
    [DFTDebugScreenShot sharedInstance].autoCapture = value;
}

+ (NSDateFormatter *)getDateFormatter {
    return [DFTDebugScreenShot sharedInstance].dateFormatter;
}

+ (void)setDateFomatter:(NSDateFormatter *)formatter {
    [DFTDebugScreenShot sharedInstance].dateFormatter = formatter;
}

+ (void)configureDrawAttributes:(void (^)(NSMutableDictionary *))block {
    if (block) {
        block([DFTDebugScreenShot sharedInstance].drawAttributes);
    }
}

+ (void)completionHandler:(void (^)(NSString *, UIImage *))block {
}

#pragma mark -
#pragma mark capture

+ (void)capture {
    DFTDebugScreenShot *instance = [DFTDebugScreenShot sharedInstance];
    UIViewController *controller = [instance visibledViewController];
    if ([controller respondsToSelector:@selector(outputDataOfScreenShoot)]) {
        id outputData = [controller performSelector:@selector(outputDataOfScreenShoot)];
        NSString *text = [outputData debugDescription];
        UIImage *image = [instance imageFromDebugText:text];
        instance.completionBlock(text, image);
    }
}

- (void)handleScreenShot:(NSNotification *)notification {
    if (self.autoCapture) {
        [DFTDebugScreenShot capture];
    }
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

- (UIImage *)imageFromDebugText:(NSObject *)object {
    NSString *text = [object debugDescription];
    CGSize size = [text sizeWithAttributes:self.drawAttributes];

    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }

    [text drawInRect:CGRectMake(0.f, 0.f, size.width, size.height)
      withAttributes:self.drawAttributes];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
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
