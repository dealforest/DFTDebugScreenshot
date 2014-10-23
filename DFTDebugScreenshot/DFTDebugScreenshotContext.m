//
//  DFTDebugScreenshotContext.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/23/14.
//
//

#import "DFTDebugScreenshotContext.h"

@implementation DFTDebugScreenshotContext

#pragma mark -
#pragma mark accessor

- (NSString *)message {
    return _message ?: @"";
}

#pragma mark -
#pragma mark instance method

- (void)searchViewController {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [(UINavigationController *)controller visibleViewController];
    }
    self.controller = controller;
}

- (void)captureCurrentScreen {
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect frame = controller.view.frame;

    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -CGRectGetMinX(frame), -CGRectGetMinY(frame));
    [controller.view drawViewHierarchyInRect:frame afterScreenUpdates:NO];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.screenshot = screenshot;
}


@end
