//
//  ViewController.m
//  Demo
//
//  Created by Riley Testut on 12/23/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

#import "ViewController.h"

@import RSTWebViewController;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)presentWebViewController:(UIButton *)sender
{
    RSTWebViewController *webViewController = [[RSTWebViewController alloc] initWithAddress:@"http://rileytestut.com"];
    webViewController.showsDoneButton = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)pushWebViewController:(UIButton *)sender
{
    RSTWebViewController *webViewController = [[RSTWebViewController alloc] initWithAddress:@"http://nytimes.com"];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
