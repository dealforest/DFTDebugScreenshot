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
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

static NSString * const kDFTDebugScreenshotBunbleName = @"DFTDebugScreenshot";
static NSString * const kDFTDebugScreenshotStringTable = @"DFTDebugScreenshotLocalizable";
static float const kCompressionQuality = 0.7;

@interface DFTDebugScreenshot()

@property (nonatomic, assign, getter = isForeground) BOOL foreground;
@property (nonatomic, assign, getter = isTracking) BOOL tracking;
@property (nonatomic, assign) BOOL analyzeAutoLayout;
@property (nonatomic, assign) BOOL enableAlert;
@property (nonatomic, copy) DFTDebugScreenshotCompletionBlock completionBlock;

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
        self.analyzeAutoLayout = NO;
        self.enableAlert = YES;
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

+ (BOOL)getAnalyzeAutoLayout {
    return [DFTDebugScreenshot sharedInstance].analyzeAutoLayout;
}

+ (void)setAnalyzeAutoLayout:(BOOL)value {
    [DFTDebugScreenshot sharedInstance].analyzeAutoLayout = value;
}

+ (BOOL)getEnableAlert {
    return [DFTDebugScreenshot sharedInstance].enableAlert;
}

+ (void)setEnableAlert:(BOOL)value {
    [DFTDebugScreenshot sharedInstance].enableAlert = value;
}

+ (void)completionBlock:(DFTDebugScreenshotCompletionBlock)block {
    if (block) {
        [DFTDebugScreenshot sharedInstance].completionBlock = block;
    }
}

+ (void)capture {
    DFTDebugScreenshot *instance = [DFTDebugScreenshot sharedInstance];
    UIViewController *controller = [instance visibledViewController];
    if (instance.isForeground) {
        id debugObject = [controller respondsToSelector:@selector(dft_debugObjectForDebugScreenshot)]
            ? [controller performSelector:@selector(dft_debugObjectForDebugScreenshot)]
            : nil;

        UIImage *screenshot = [instance loadScreenshot];

        NSArray *views = [[instance bundle] loadNibNamed:@"DFTDebugScreenshotView" owner:self options:nil];
        DFTDebugScreenshotView *debugView = [views firstObject];
        [debugView setTitleText:NSStringFromClass([controller class])
                        message:[instance debugMessageWithDebugObject:debugObject]];
        UIImage *image = [debugView convertToImage];
        [instance saveImageToPhotosAlbum:image debugObject:debugObject];

        if (instance.completionBlock) {
            instance.completionBlock(controller, screenshot, debugObject, image);
        }
    }
}

+ (id)unarchiveObjectWithDebugObjectHex:(NSString *)hex {
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
    [DFTDebugScreenshot capture];
}

- (void)handlingWillResignActiveNotification:(NSNotification *)notification {
    [DFTDebugScreenshot sharedInstance].foreground = NO;
}

- (void)handlingDidBecomeActiveNotification:(NSNotification *)notification {
    [DFTDebugScreenshot sharedInstance].foreground = YES;
}

#pragma mark -
#pragma mark AssetsLibrary

- (BOOL)isEnablePhotosAccess {
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

- (void)saveImageToPhotosAlbum:(UIImage *)image {
    [self saveImageToPhotosAlbum:image debugObject:nil];
}

- (void)saveImageToPhotosAlbum:(UIImage *)image debugObject:(id)debugObject {
    if (![self isEnablePhotosAccess]) return;

    NSData *imageData = UIImageJPEGRepresentation(image, kCompressionQuality);
    CGImageSourceRef imageRef = CGImageSourceCreateWithData((CFDataRef)imageData, nil);

    NSMutableDictionary *meta = [(__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageRef, 0, nil) mutableCopy];
    NSMutableDictionary *exif = meta[(NSString *)kCGImagePropertyExifDictionary] ?: [@{} mutableCopy];
    exif[(NSString *)kCGImagePropertyExifUserComment] = [@[
                                                           [self debugMessageWithDebugObject:debugObject],
                                                           [NSKeyedArchiver archivedDataWithRootObject:debugObject]
                                                           ] componentsJoinedByString:@" "];
    meta[(NSString *)kCGImagePropertyExifDictionary] = exif;

    ALAssetsLibrary* library = [ALAssetsLibrary new];
    [library writeImageDataToSavedPhotosAlbum:imageData
                                     metadata:meta
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
                                  NSString *key = status == ALAuthorizationStatusDenied ? @"DENY_RESTRINCTIONS" : @"SAVED_PHOTO";
                                  [self showAlertWithLocalizedKey:key];
                                  }];
}

- (UIImage *)loadScreenshot {
    // wait for saved the screenshot.
    sleep(1);

    UIImage __block *captureImage;
    BOOL __block loding = YES;
    while (loding) {
        ALAssetsLibrary *library = [ALAssetsLibrary new];
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
                                                                    loding = NO;
                                                                }
                                                            }];
                                   }
                               }
                             failureBlock:^(NSError *error) {
                                 loding = NO;
                             }];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return captureImage;
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

- (void)showAlertWithLocalizedKey:(NSString *)key {
    if (!self.enableAlert) return;

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

- (NSString *)debugMessageWithDebugObject:(id)debugObject {
    NSMutableString *message = [@"" mutableCopy];
    [message appendString:[self debugMessageForDebugObject:debugObject]];
    if (self.analyzeAutoLayout) {
        UIViewController *controller = [self visibledViewController];
        [message appendString:[self debugMessageForConstraints:controller.view]];
    }
    return message;
}

- (NSString *)debugMessageForDebugObject:(id)debugObject {
    return [NSString stringWithFormat:@"[debug object]\n%@\n\n", [debugObject description]];
}

- (NSString *)debugMessageForConstraints:(UIView *)view {
    //TODO: support nest subviews
    NSString * (^formatView)(UIView *, NSUInteger) = ^(UIView *view, NSUInteger nestLevel) {
        //TODO: support UITabelView and UICollectionView
        NSString *prefix = [@"" stringByPaddingToLength:nestLevel * 4 withString:@" " startingAtIndex:0];
        NSMutableString *string = [@"" mutableCopy];
        [string appendFormat:@"%@- %@\n", prefix, [view description]];

        prefix = [@"" stringByPaddingToLength:(nestLevel + 1) * 4 withString:@" " startingAtIndex:0];
        if ([view.constraints count] > 0) {
            for (NSLayoutConstraint *constraint in view.constraints) {
                [string appendFormat:@"%@* %@\n", prefix, constraint];
            }
        }
        else {
            [string appendFormat:@"%@* none\n", prefix];
        }
        return string;
    };

    NSMutableString *string = [@"[constrains]\n" mutableCopy];
    [string appendString:formatView(view, 0)];
    for (UIView *subview in view.subviews) {
        [string appendString:formatView(subview, 1)];
    }
    return [string stringByAppendingString:@"\n"];
}

@end
