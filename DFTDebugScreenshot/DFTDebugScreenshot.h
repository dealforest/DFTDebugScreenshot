//
//  DFTDebugScreenshot.h
//  DFTDebugScreenshotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DFTDebugScreenshotCompletionBlock)(UIViewController *, UIImage *, id, UIImage *);

@interface UIViewController (DFTDebugScreenshotAdditions)

- (id)dft_debugObjectForDebugScreenshot;

@end

@interface DFTDebugScreenshot : NSObject

+ (BOOL)isTracking;

+ (void)setTraking:(BOOL)value;

+ (BOOL)getAnalyzeAutoLayout;

+ (void)setAnalyzeAutoLayout:(BOOL)value;

+ (BOOL)getEnableAlert;

+ (void)setEnableAlert:(BOOL)value;

+ (void)completionBlock:(DFTDebugScreenshotCompletionBlock)block;

+ (void)capture;

@end
