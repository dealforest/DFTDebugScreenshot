//
//  DFTDebugScreenshotAdapterSlack.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import <UIKit/UIKit.h>
#import "DFTDebugScreenshotAdapter.h"

@interface DFTDebugScreenshotSlackAdapter : DFTDebugScreenshotAdapter

@property NSURL *requestURL;
@property NSString *channel;
@property NSString *username;
@property NSString *text;
@property NSString *iconEmoji;
@property NSURL *iconURL;

- (instancetype)initWithIncomingWebHookURL:(NSString *)requestURL;

@end
