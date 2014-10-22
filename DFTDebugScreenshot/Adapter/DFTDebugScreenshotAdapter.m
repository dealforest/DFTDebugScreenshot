//
//  DFTDebugScreenshotAdapter.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/16/14.
//
//

#import <mach/mach.h>
#import <mach/mach_host.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "DFTDebugScreenshotAdapter.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation DFTDebugScreenshotAdapter

#pragma clang diagnostic pop

- (NSString *)inquiryViewHierarhyOfController:(UIViewController *)controller {
    NSString * (^inquiry)(UIView *, NSUInteger);
    __block __weak NSString * (^weakInquiry)(UIView *, NSUInteger) = inquiry = ^(UIView *view, NSUInteger depth) {
        NSMutableString *string = [@"" mutableCopy];
        for (UIView *subview in view.subviews) {
            [string appendFormat:@"%@%@\n", [@"" stringByPaddingToLength:depth withString:@"  " startingAtIndex:0], [view description]];
            if ([subview.constraints count] > 0) {
                for (NSLayoutConstraint *constraint in view.constraints) {
                    [string appendFormat:@"%@* %@\n", [@"" stringByPaddingToLength:depth + 2 withString:@"  " startingAtIndex:0], [constraint description]];
                }
            }
            if ([subview.subviews count] > 0) {
                [string appendString:weakInquiry(subview, (depth + 2))];
            }
        }
        return [NSString stringWithString:string];
    };
    NSString *hierarchy = inquiry(controller.view, 0);
    return hierarchy.length > 0 ? hierarchy : @"unknown";
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (id)inquiryDebugObjectOfController:(UIViewController *)controller {
    if ([controller respondsToSelector:@selector(dft_debugObjectForDebugScreenshot)]) {
        return [controller performSelector:@selector(dft_debugObjectForDebugScreenshot)];
    }
    else {
        return nil;
    }
}

#pragma clang diagnostic pop

- (NSDateFormatter *)defaultDateFormatter {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    return formatter;
}

- (NSString *)appName {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

- (NSString *)appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (NSString *)appBundleIdentifier {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
}

- (NSString *)appBuildlVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

- (NSString *)freeRAM {
    vm_statistics_data_t vm_stats;
    mach_msg_type_number_t info_count = HOST_VM_INFO_COUNT;
    kern_return_t kern_return = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vm_stats, &info_count);
    if (kern_return == KERN_SUCCESS) {
        unsigned long mem_free = vm_stats.free_count * vm_page_size;
        return [NSByteCountFormatter stringFromByteCount:mem_free countStyle:NSByteCountFormatterCountStyleMemory];
    }
    else {
        return @"-";
    }
}

- (NSString *)freeSpace {
    long long freeSpace = 0;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    if (attributes) {
        freeSpace = [attributes[NSFileSystemFreeSize] longLongValue];
        return [NSByteCountFormatter stringFromByteCount:freeSpace countStyle:NSByteCountFormatterCountStyleFile];
    }
    else {
        return @"-";
    }
}

- (NSString *)device {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

- (NSString *)operatingSystem {
    UIDevice *device = [UIDevice currentDevice];
    return [@[device.systemName, device.systemVersion] componentsJoinedByString:@" "];
}

@end
