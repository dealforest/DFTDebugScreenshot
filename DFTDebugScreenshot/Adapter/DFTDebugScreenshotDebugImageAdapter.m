//
//  DFTDebugScreenshotDebugImageAdapter.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/21/14.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "DFTDebugScreenshotDebugImageAdapter.h"
#import "DFTDebugScreenshotHelper.h"
#import "DFTDebugScreenshotContext.h"
#import "DFTDebugScreenshotView.h"

static float const kCompressionQuality = 0.7;

@implementation DFTDebugScreenshotDebugImageAdapter

#pragma mark -
#pragma mark DFTDebugScreenshotAdapterProtocol

- (void)processWithContext:(DFTDebugScreenshotContext *)context {
    if (![DFTDebugScreenshotHelper isEnablePhotosAccess]) return;

    UIViewController *controller = context.controller;
    id debugObject = [self inquiryDebugObjectOfController:controller];

    NSArray *views = [[DFTDebugScreenshotHelper bundle] loadNibNamed:@"DFTDebugScreenshotView" owner:self options:nil];
    DFTDebugScreenshotView *debugView = [views firstObject];
    [debugView setTitleText:NSStringFromClass([controller class])
                    message:[@[
                               context.message,
                               @"",
                               @"[DEBUG OBJECT]",
                               [debugObject description] ?: @"none",
                               @"",
                               @"[VIEW HIERARCHY]",
                               [self inquiryViewHierarhyOfController:controller],
                               ] componentsJoinedByString:@"\n"]];

    UIImage *image = [debugView convertToImage];
    NSData *imageData = UIImageJPEGRepresentation(image, kCompressionQuality);
    CGImageSourceRef imageRef = CGImageSourceCreateWithData((CFDataRef)imageData, nil);

    NSMutableDictionary *meta = [(__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageRef, 0, nil) mutableCopy];
    if (debugObject) {
        NSMutableDictionary *exif = meta[(NSString *)kCGImagePropertyExifDictionary] ?: [@{} mutableCopy];
        exif[(NSString *)kCGImagePropertyExifUserComment] = [@[
                                                               @"[DEBUG OBJECT]",
                                                               [debugObject description],
                                                               @"[SERIALIZE]",
                                                               [NSKeyedArchiver archivedDataWithRootObject:debugObject]
                                                               ]
                                                             componentsJoinedByString:@" "];
        meta[(NSString *)kCGImagePropertyExifDictionary] = exif;
    }

    ALAssetsLibrary* library = [ALAssetsLibrary new];
    [library writeImageDataToSavedPhotosAlbum:imageData
                                     metadata:meta
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
                                  NSString *key = status == ALAuthorizationStatusDenied ? @"DENY_RESTRINCTIONS" : @"SAVED_PHOTO";
                                  [DFTDebugScreenshotHelper showAlertWithLocalizedKey:key];
                              }];
}

@end
