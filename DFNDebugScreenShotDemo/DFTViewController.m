//
//  DFTViewController.m
//  DFNDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTViewController.h"
#import "DFTDebugScreenShot.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(capture) withObject:nil afterDelay:1.f];
}

#pragma mark -
#pragma mark DFTDebugScreenShot

- (id)outputDataOfScreenShoot {
    NSMutableArray *outputData = [@[] mutableCopy];
    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows])
    {
        [outputData addObject:self.data[indexPath.row]];
    }
    return outputData;
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

- (void)capture {
    [DFTDebugScreenShot capture];
}

@end
