//
//  DFTDebugScreenshot.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFTDebugScreenshotAdapter;

@interface UIViewController(DFTDebugScreenshotAdditions)

- (id)dft_debugObjectForDebugScreenshot;

@end

@interface DFTDebugScreenshot : NSObject

- (id)init UNAVAILABLE_ATTRIBUTE;

+ (BOOL)isTracking;

+ (void)setTraking:(BOOL)value;

+ (BOOL)getEnableAlert;

+ (void)setEnableAlert:(BOOL)value;

+ (NSArray *)getAdapters;

+ (void)addAdapter:(DFTDebugScreenshotAdapter *)adapater;

+ (NSString *)getUserIdentifier;

+ (void)setUserIdentifier:(NSString *)identifier;

+ (void)capture;

+ (void)captureWithError:(NSError *)error;

+ (void)captureWithException:(NSException *)exception;

+ (id)unarchiveWithObjectHex:(NSString *)hex;

+ (id)archiveWithObject:(id)object;

@end

@interface DFTDebugScreenshot(DFTDebugScreenshotDeprecated)

+ (BOOL)getAnalyzeAutoLayout __deprecated_msg("Method deprecated.");

+ (void)setAnalyzeAutoLayout:(BOOL)value __deprecated_msg("Method deprecated.");

+ (void)completionBlock:(void (^)(UIViewController *, UIImage *, id, UIImage *))block __deprecated_msg("Method deprecated.");

+ (id)unarchiveObjectWithHex:(NSString *)hex __deprecated_msg("Method deprecated. Use `unarchiveWithObjectHex:`");

@end
