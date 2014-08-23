//
//  DFTDebugScreenshotView.h
//  DFTDebugScreenshotDemo
//
//  Created by Toshihiro Morimoto on 8/22/14.
//
//

#import <UIKit/UIKit.h>

@interface DFTDebugScreenshotView : UIView

- (void)setTitleText:(NSString *)title message:(NSString *)message;

- (UIImage *)convertToImage;

@end
