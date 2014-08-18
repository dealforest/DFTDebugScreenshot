//
//  DFTViewController.m
//  DFNDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface DFTViewController ()

@property NSArray *data;

@end

@implementation DFTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *array = [@[] mutableCopy];
    for (int i = 1; i <= 200; i++)
    {
        [array addObject:@{
                           @"id": @(i),
                           @"name": [NSString stringWithFormat:@"name: %d", i],
                           @"important": @"The information is required for debug...",
                           }];
    }
    self.data = array;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleScreenCapture:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(handleScreenCapture:) withObject:nil afterDelay:1.f];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.data[indexPath.row][@"name"];
    return cell;
}

#pragma mark -
#pragma mark UITAbleViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.data[indexPath.row];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"click"
                                                        message:data[@"name"]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}


#pragma mark -
#pragma mark private

- (void)handleScreenCapture:(NSNotification *)notification {
    NSMutableArray *outputData = [@[] mutableCopy];
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows])
    {
        [outputData addObject:self.data[indexPath.row]];
    }
    [self saveDebugImage:[outputData description]];
}

- (void)saveDebugImage:(NSString *)text {
    CGFloat fontSize = 12.f;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize size = [text sizeWithAttributes:@{ NSFontAttributeName: font }];

    if (UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    }
    else {
        UIGraphicsBeginImageContext(size);
    }

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    [text drawInRect:CGRectMake(0.f, 0.f, size.width, size.height)
      withAttributes:@{
                       NSFontAttributeName: font,
                       NSParagraphStyleAttributeName: paragraphStyle,
                       }];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self saveImageToPhotosAlbum:image];
}

#pragma mark -
#pragma mark AssetsLibrary
// http://qiita.com/ux_design_tokyo/items/cb0cb6b5e42989569de5

- (void)saveImageToPhotosAlbum:(UIImage*)_image {
    if ([self isPhotoAccessEnableWithIsShowAlert:YES]) {
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:_image.CGImage
                                  orientation:(ALAssetOrientation)_image.imageOrientation
                              completionBlock:
         ^(NSURL *assetURL, NSError *error){
             ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
             if (status == ALAuthorizationStatusDenied) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                                     message:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }
             else {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:@"フォトアルバムへ保存しました。"
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }];
    }
}


// 写真へのアクセスが許可されている場合はYESを返す。まだ許可するか選択されていない場合はYESを返す。
- (BOOL)isPhotoAccessEnableWithIsShowAlert:(BOOL)_isShowAlert {
    // このアプリの写真への認証状態を取得する
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];

    BOOL isAuthorization = NO;

    switch (status) {
        case ALAuthorizationStatusAuthorized: {
            // 写真へのアクセスが許可されている
            isAuthorization = YES;
            break;
        }
        case ALAuthorizationStatusNotDetermined: {
            // 写真へのアクセスを許可するか選択されていない
            isAuthorization = YES; // 許可されるかわからないがYESにしておく
            break;
        }
        case ALAuthorizationStatusRestricted:
        {
            // 設定 > 一般 > 機能制限で利用が制限されている
            isAuthorization = NO;
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                                    message:@"写真へのアクセスが許可されていません。\n設定 > 一般 > 機能制限で許可してください。"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            break;
        }
        case ALAuthorizationStatusDenied: {
            // 設定 > プライバシー > 写真で利用が制限されている
            isAuthorization = NO;
            if (_isShowAlert) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー"
                                                                    message:@"写真へのアクセスが許可されていません。\n設定 > プライバシー > 写真で許可してください。"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }
            break;
        }
        default: {
            break;
        }
    }
    return isAuthorization;
}


@end
