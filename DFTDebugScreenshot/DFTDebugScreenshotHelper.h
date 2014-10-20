//
//  DFTDebugScreenshotHelper.h
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 10/21/14.
//
//

#import <UIKit/UIKit.h>

@interface DFTDebugScreenshotHelper : NSObject

+ (NSBundle *)bundle;

+ (void)showAlertWithLocalizedKey:(NSString *)key;

+ (BOOL)isEnablePhotosAccess;

@end
