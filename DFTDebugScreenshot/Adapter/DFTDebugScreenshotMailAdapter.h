//
//  DFTDebugScreenshotMailAdapter.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/21/14.
//
//

#import "DFTDebugScreenshotAdapter.h"

@interface DFTDebugScreenshotMailAdapter : DFTDebugScreenshotAdapter<DFTDebugScreenshotAdapterProtocol>

@property(nonatomic, strong) NSArray *toRecipients;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *messageBody;

- (instancetype)initWithToRecipients:(NSArray *)toRecipients;

- (instancetype)initWithToRecipients:(NSArray *)toRecipients subject:(NSString *)subject;

- (instancetype)initWithToRecipients:(NSArray *)toRecipients subject:(NSString *)subject messageBody:(NSString *)messageBody;

@end