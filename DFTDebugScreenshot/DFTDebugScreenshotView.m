//
//  DFTDebugScreenshotView.m
//  DFTDebugScreenshot
//
//  Created by Toshihiro Morimoto on 8/22/14.
//
//

#import "DFTDebugScreenshotView.h"

@interface DFTDebugScreenshotView()

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *messageLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation DFTDebugScreenshotView

- (void)awakeFromNib {
    CGRect frame = self.messageLabel.frame;
    frame.size.width = frame.size.height = 0.f;
    self.messageLabel.frame = frame;
    self.messageLabel.preferredMaxLayoutWidth = HUGE_VAL;

    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
    self.formatter = formatter;
}

- (void) setTitleText:(NSString *)title message:(NSString *)message
{
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    [self.messageLabel sizeToFit];
    [self resizeToFitSubviews];
}

- (UIImage *)convertToImage
{
    [self refreshDateLabel];

    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.f);
    }
    else {
        UIGraphicsBeginImageContext(self.frame.size);
    }
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

#pragma mark -
#pragma mark private

- (void)refreshDateLabel {
    NSDate *now = [NSDate date];
    self.dateLabel.text = [self.formatter stringFromDate:now];
}

- (void)resizeToFitSubviews
{
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.frame = CGRectUnion(self.frame, CGRectMake(0.f, 0.f, size.width, size.height));
    [self.subviews makeObjectsPerformSelector:@selector(layoutIfNeeded)];
}

@end
