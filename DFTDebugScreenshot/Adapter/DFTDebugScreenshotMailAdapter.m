//
//  DFTDebugScreenshotMailAdapter.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/21/14.
//
//

#import <MessageUI/MFMailComposeViewController.h>
#import "DFTDebugScreenshotMailAdapter.h"
#import "DFTDebugScreenshot.h"
#import "DFTDebugScreenshotHelper.h"

#pragma mark -
#pragma mark initializer

@implementation DFTDebugScreenshotMailAdapter

- (instancetype)initWithToRecipients:(NSArray *)toRecipients {
    return [self initWithToRecipients:toRecipients subject:nil messageBody:nil];
}

- (instancetype)initWithToRecipients:(NSArray *)toRecipients subject:(NSString *)subject {
    return [self initWithToRecipients:toRecipients subject:subject messageBody:nil];
}

- (instancetype)initWithToRecipients:(NSArray *)toRecipients subject:(NSString *)subject messageBody:(NSString *)messageBody {
    self = [super init];
    if (self) {
        _toRecipients = toRecipients;
        _subject = subject;
        _messageBody = messageBody;
    }
    return self;
}

#pragma mark -
#pragma mark accessor

- (NSString *)subject {
    return _subject ?: [NSString stringWithFormat:@"[%@] screenshot debug", [self appName]];
}

- (NSString *)messageBody {
    return _messageBody ?: [NSString stringWithFormat:@"captured_at %@ via DFTDebugScreenshot v0.1.0", [[self defaultDateFormatter] stringFromDate:[NSDate date]]];
}

#pragma mark -
#pragma mark DFTDebugScreenshotAdapterProtocol

- (void)processWithController:(UIViewController *)controller screenshot:(UIImage *)screenshot {
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"%@", @"You need settings for Mail.");
        return;
    }

    id debugObject = [self inquiryDebugObjectOfController:controller];
    MFMailComposeViewController *picker = [MFMailComposeViewController new];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    [picker setToRecipients:self.toRecipients];
    [picker setSubject:self.subject];
    [picker addAttachmentData:UIImageJPEGRepresentation(screenshot, 1)
                     mimeType:@"image/jpeg"
                     fileName:@"screenshot.jpg"];
    [picker setMessageBody:[@[
                              self.messageBody,
                              @"\n---------------------\n",
                              [NSString stringWithFormat:@"NAME: %@", [self appName]],
                              [NSString stringWithFormat:@"BUNDLE IDENTIFIER: %@", [self appBundleIdentifier]],
                              [NSString stringWithFormat:@"VERSION: %@", [self appVersion]],
                              [NSString stringWithFormat:@"BUILD: %@", [self appBuildlVersion]],
                              [NSString stringWithFormat:@"OPERATING SYSTEM: %@", [self operatingSystem]],
                              [NSString stringWithFormat:@"DEVICE: %@", [self device]],
                              [NSString stringWithFormat:@"FREE RAM: %@", [self freeRAM]],
                              [NSString stringWithFormat:@"FREE SPACE: %@", [self freeSpace]],
                              @"\n---------------------\n",
                              @"[DEBUG OBJECT]",
                              [debugObject description],
                              @"[SERIALIZE]",
                              [DFTDebugScreenshot archiveWithObject:debugObject],
                              @"[VIEW HIERARCHY]",
                              [self inquiryViewHierarhyOfController:controller],
                              ] componentsJoinedByString:@"\n"]
                    isHTML:NO];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}



@end
