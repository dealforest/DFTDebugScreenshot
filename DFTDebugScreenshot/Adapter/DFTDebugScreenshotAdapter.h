//
//  DFTDebugScreenshotAdapter.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import <Foundation/Foundation.h>

@class DFTDebugScreenshotContext;

@protocol DFTDebugScreenshotAdapterProtocol

- (void)processWithContext:(DFTDebugScreenshotContext *)context;

@end

@interface DFTDebugScreenshotAdapter : NSObject

- (NSString *)inquiryViewHierarhyOfController:(UIViewController *)controller;

- (id)inquiryDebugObjectOfController:(UIViewController *)controller;

- (NSDateFormatter *)defaultDateFormatter;

- (NSString *)appName;

- (NSString *)appVersion;

- (NSString *)appBundleIdentifier;

- (NSString *)appBuildlVersion;

- (NSString *)freeRAM;

- (NSString *)freeSpace;

- (NSString *)device;

- (NSString *)operatingSystem;

@end
