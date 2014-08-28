//
//  DFTViewController.m
//  DFTDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/14/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTTableViewController.h"
#import "DFTViewController.h"

@interface DFTTableViewController ()

@property NSIndexPath *selectedIndexPath;
@property NSArray *data;

@end

@implementation DFTTableViewController

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

#pragma mark -
#pragma mark DFTDebugScreenshot

- (id)dft_debugObjectForDebugScreenshot {
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
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"detailView" sender:nil];
}

#pragma mark -
#pragma mark storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailView"]) {
        DFTViewController *controller = segue.destinationViewController;
        controller.data = self.data[self.selectedIndexPath.row];
    }
}

#pragma mark -
#pragma mark IBAction

- (IBAction)touchedCaptureButton:(id)sender {
    [DFTDebugScreenshot capture];
}

@end
