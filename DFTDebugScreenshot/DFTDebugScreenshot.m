//
//  DFTDebugScreenshot.m
//  DFTDebugScreenshotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTDebugScreenshot.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define DEFAULT_FONT_SIZE 12.f

@interface DFTDebugScreenshot()

@property (nonatomic, strong) NSMutableDictionary *drawAttributes;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
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

- (instancetype)init {
    self = [super init];
    if (self) {
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
    }
    return self;
}

#pragma mark -
#pragma mark class method

+ (void)enableAutoCapture {
    [[NSNotificationCenter defaultCenter] addObserver:[DFTDebugScreenshot sharedInstance]
                                             selector:@selector(handlingScreenShot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

+ (void)disableAutoCapture {
    [[NSNotificationCenter defaultCenter] removeObserver:[DFTDebugScreenshot sharedInstance]
                                                    name:UIApplicationUserDidTakeScreenshotNotification
                                                  object:nil];
}

+ (NSDateFormatter *)getDateFormatter {
    return [DFTDebugScreenshot sharedInstance].dateFormatter;
}

+ (void)setDateFomatter:(NSDateFormatter *)formatter {
    [DFTDebugScreenshot sharedInstance].dateFormatter = formatter;
}

+ (void)configureDrawAttributes:(void (^)(NSMutableDictionary *))block {
    if (block) {
        block([DFTDebugScreenshot sharedInstance].drawAttributes);
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
    if ([controller respondsToSelector:@selector(outputDataOfScreenShoot)]) {
        id outputData = [controller performSelector:@selector(outputDataOfScreenShoot)];
        NSString *text = [outputData debugDescription];
        UIImage *image = [instance imageFromDebugText:text];
        [instance saveImageToPhotosAlbum:image];
        if (instance.completionBlock) {
            instance.completionBlock(text, image);
        }
    }
}


#pragma mark -
#pragma mark observer

- (void)handlingScreenShot:(NSNotification *)notification {
    [DFTDebugScreenshot capture];
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
