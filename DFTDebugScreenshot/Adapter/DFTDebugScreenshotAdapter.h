//
//  DFTDebugScreenshotAdapter.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import <Foundation/Foundation.h>

@protocol DFTDebugScreenshotAdapterProtocol

- (void)processWithController:(UIViewController *)controller screenshot:(UIImage *)screenshot;

@end

@interface DFTDebugScreenshotAdapter : NSObject<DFTDebugScreenshotAdapterProtocol>

- (NSString *)inquiryViewHierarhyOfController:(UIViewController *)controller;

- (id)inquiryDebugObjectOfController:(UIViewController *)controller;

- (NSDateFormatter *)defaultDateFormatter;

- (NSString *)freeRAM;

- (NSString *)freeSpace;

- (NSString *)device;

- (NSString *)operatingSystem;

@end
