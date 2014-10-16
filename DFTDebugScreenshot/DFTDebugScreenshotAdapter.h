//
//  DFTDebugScreenshotAdapter.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import <Foundation/Foundation.h>

@protocol DFTDebugScreenshotAdapterProtocol

- (void)process:(UIViewController *)controller screenshot:(UIImage *)screenshot;

@end


@interface DFTDebugScreenshotAdapter : NSObject<DFTDebugScreenshotAdapterProtocol>

- (NSString *)inquiryViewHierarhy:(UIViewController *)controller;

- (id)inquiryDebugObject:(UIViewController *)controller;

- (NSDateFormatter *)defaultDateFormatter;

- (NSString *)freeRAM;

- (NSString *)freeSpace;

- (NSString *)device;

- (NSString *)operatingSystem;

@end
