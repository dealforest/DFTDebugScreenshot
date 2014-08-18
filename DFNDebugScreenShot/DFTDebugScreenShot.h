//
//  DFTDebugScreenShot.h
//  DFNDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFTDebugScreenShot : NSObject

+ (BOOL)getAutoCapture;
+ (void)setAutoCapture:(BOOL)value;

+ (NSDateFormatter *)getDateFormatter;
+ (void)setDateFomatter:(NSDateFormatter *)formatter;

+ (void)configureDrawAttributes:(void (^)(NSMutableDictionary *))block;

+ (void)completionHandler:(void (^)(NSString *, UIImage *))block;

+ (void)capture;

@end
