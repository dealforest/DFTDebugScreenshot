//
//  DFTDebugScreenshotContext.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/23/14.
//
//

#import <Foundation/Foundation.h>

@interface DFTDebugScreenshotContext : NSObject

@property (nonatomic) UIViewController *controller;
@property (nonatomic) NSString *userIdentifier;
@property (nonatomic) NSString *message;
@property (nonatomic) UIImage *screenshot;

- (void)searchViewController;

- (void)captureCurrentScreen;

@end
