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

    NSMutableArray *messages = [@[
                                  context.message,
                                  @"",
                                  @"[USER IDENTIFIER]",
                                  context.userIdentifier,
                                  @"",
                                  @"[DEBUG OBJECT]",
                                  [debugObject description] ?: @"none",
                                  @"",
                                  @"[VIEW HIERARCHY]",
                                  [self inquiryViewHierarhyOfController:controller],
                                  ] mutableCopy];
    if (context.userDefineContents.count > 0) {
        for (NSDictionary *userDefineContent in context.userDefineContents) {
            [messages addObjectsFromArray:@[
                                            [NSString stringWithFormat:@"[%@]", userDefineContent[@"title"]],
                                            userDefineContent[@"content"],
                                            @"",
                                            ]];
        }
    }

    NSArray *views = [[DFTDebugScreenshotHelper bundle] loadNibNamed:@"DFTDebugScreenshotView" owner:self options:nil];
    DFTDebugScreenshotView *debugView = [views firstObject];
    [debugView setTitleText:NSStringFromClass([controller class])
                    message:[messages componentsJoinedByString:@"\n"]];

    UIImage *image = [debugView convertToImage];
    NSData *imageData = UIImageJPEGRepresentation(image, kCompressionQuality);
    CGImageSourceRef imageRef = CGImageSourceCreateWithData((CFDataRef)imageData, nil);

    NSMutableDictionary *meta = [(__bridge NSDictionary*)CGImageSourceCopyPropertiesAtIndex(imageRef, 0, nil) mutableCopy];
    NSMutableDictionary *exif = meta[(NSString *)kCGImagePropertyExifDictionary] ?: [@{} mutableCopy];
    NSMutableString *comment = [exif[(NSString *)kCGImagePropertyExifUserComment] ?: @"" mutableCopy];
    if (debugObject) {
        [comment appendString:[@[
                                 @"[DEBUG OBJECT]",
                                 [debugObject description],
                                 @"[SERIALIZE]",
                                 [NSKeyedArchiver archivedDataWithRootObject:debugObject]
                                 ]
                               componentsJoinedByString:@" "]];
    }
    if (context.userDefineContents.count > 0) {
        for (NSDictionary *userDefineContent in context.userDefineContents) {
            [comment appendString:[@[
                                     [NSString stringWithFormat:@"[%@]", userDefineContent[@"title"]],
                                     userDefineContent[@"content"],
                                     ]
                                   componentsJoinedByString:@" "]];
        }
    }
    exif[(NSString *)kCGImagePropertyExifUserComment] = comment;
    meta[(NSString *)kCGImagePropertyExifDictionary] = exif;

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
