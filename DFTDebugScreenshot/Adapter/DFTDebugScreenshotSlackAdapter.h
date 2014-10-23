//
//  DFTDebugScreenshotAdapterSlack.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import "DFTDebugScreenshotAdapter.h"

@interface DFTDebugScreenshotSlackAdapter : DFTDebugScreenshotAdapter<DFTDebugScreenshotAdapterProtocol>

@property(nonatomic) NSURL *requestURL;
@property(nonatomic) NSString *channel;
@property(nonatomic) NSString *username;
@property(nonatomic) NSString *text;
@property(nonatomic) NSString *iconEmoji;
@property(nonatomic) NSURL *iconURL;

- (instancetype)initWithIncomingWebHookURL:(NSURL *)requestURL;

@end
