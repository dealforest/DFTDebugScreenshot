//
//  DFTModalViewController.m
//  DFTDebugScreenShotDemo
//
//  Created by Toshihiro Morimoto on 8/19/14.
//  Copyright (c) 2014 Toshihiro Morimoto. All rights reserved.
//

#import "DFTModalViewController.h"

@interface DFTModalViewController ()

@end

@implementation DFTModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark DFTDebugScreenshot

- (id)dft_debugObjectForDebugScreenshot {
    return [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark IBAction

- (IBAction)touchedCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchedCaptureButton:(id)sender {
    [DFTDebugScreenshot capture];
}

@end
