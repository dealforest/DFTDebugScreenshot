//
//  DFTDebugScreenshotAdapterSlack.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import "DFTDebugScreenshotSlackAdapter.h"
#import "DFTDebugScreenshot.h"
#import "DFTDebugScreenshotContext.h"
#import "DFTDebugScreenshotHelper.h"

#define DEFAULT_ICON_EMOJI @":iphone:"

@implementation DFTDebugScreenshotSlackAdapter

#pragma mark -
#pragma mark initializer

- (instancetype)initWithIncomingWebHookURL:(NSURL *)requestURL {
    self = [super init];
    if (self) {
        _requestURL = requestURL;
        _text = @"";
        _username = @"screenshot-bot";
        _iconEmoji = DEFAULT_ICON_EMOJI;
    }
    return self;
}

#pragma mark -
#pragma mark accessor

- (void)setIconURL:(NSURL *)iconURL {
    _iconEmoji = iconURL ? nil : DEFAULT_ICON_EMOJI;
    _iconURL = iconURL;
}

#pragma mark -
#pragma mark DFTDebugScreenshotAdapterProtocol

- (void)processWithContext:(DFTDebugScreenshotContext *)context {
    UIViewController *controller = context.controller;
    NSMutableDictionary *payload = [self createDefaultPayload];
    payload[@"text"] = payload[@"text"] ? [context.message stringByAppendingFormat:@"\n%@", payload[@"text"]] : context.message;

    NSMutableArray *attachments = [payload[@"attachments"] mutableCopy];
    [attachments addObject:[self createAttachmentWithTitle:@"VIEW HIERARCHY"
                                                      text:[self inquiryViewHierarhyOfController:controller]
                                                     value:NSStringFromClass([controller class])]];
    id debugObject = [self inquiryDebugObjectOfController:controller];
    if (debugObject) {
        [attachments addObject:[self createAttachmentWithTitle:@"DEBUG OBJECT"
                                                          text:[debugObject description]]];
        [attachments addObject:[self createAttachmentWithTitle:@"SERIALIZE"
                                                          text:[DFTDebugScreenshot archiveWithObject:debugObject]]];
    }
    payload[@"attachments"] = attachments;

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if (!error) {
                                                    [DFTDebugScreenshotHelper showAlertWithLocalizedKey:@"SUCCESS_REQUEST"];
                                                }
                                                else {
                                                    NSLog(@"%@", error);
                                                }
                                                [session invalidateAndCancel];
                                            }];
    [task resume];
}

#pragma mark -
#pragma mark private

- (NSMutableDictionary *)createDefaultPayload {
    NSMutableDictionary *payload = [@{
                                      @"attachments": @[
                                              @{
                                                  @"fallback": @"APP INFORMATION",
                                                  @"color": @"#D00000",
                                                  @"fields": @[
                                                          @{
                                                              @"title": @"NAME",
                                                              @"value": [self appName],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"BUNDLE IDENTIFIER",
                                                              @"value": [self appBundleIdentifier],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"VERSION",
                                                              @"value": [self appVersion],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"BUILD",
                                                              @"value": [self appBuildlVersion],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"OPERATING SYSTEM",
                                                              @"value": [self operatingSystem],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"DEVICE",
                                                              @"value": [self device],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"FREE RAM",
                                                              @"value": [self freeRAM],
                                                              @"short": @YES,
                                                              },
                                                          @{
                                                              @"title": @"FREE SPACE",
                                                              @"value": [self freeSpace],
                                                              @"short": @YES,
                                                              },
                                                          ]
                                                  }
                                              ]
                                      } mutableCopy];
    if (self.text) {
        payload[@"text"] = self.text;
    }
    if (self.channel) {
        payload[@"channel"] = self.channel;
    }
    if (self.username) {
        payload[@"username"] = self.username;
    }
    if (self.iconEmoji) {
        payload[@"icon_emoji"] = self.iconEmoji;
    }
    else if (self.iconURL) {
        payload[@"icon_url"] = [self.iconURL absoluteString];
    }
    return payload;
}

- (NSDictionary *)createAttachmentWithTitle:(NSString *)title text:(NSString *)text {
    return [self createAttachmentWithTitle:title text:text value:@"" color:@""];
}

- (NSDictionary *)createAttachmentWithTitle:(NSString *)title text:(NSString *)text value:(NSString *)value {
    return [self createAttachmentWithTitle:title text:text value:value color:@""];
}

- (NSDictionary *)createAttachmentWithTitle:(NSString *)title text:(NSString *)text value:(NSString *)value color:(NSString *)color {
    return @{
             @"fallback": title,
             @"text": text,
             @"color": color,
             @"fields": @[
                     @{
                         @"title": title,
                         @"value": value ?: @"",
                         @"short": @YES,
                         }
                     ]
             };
}

@end
