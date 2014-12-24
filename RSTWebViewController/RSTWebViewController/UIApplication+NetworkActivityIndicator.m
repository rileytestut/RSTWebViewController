//
//  UIApplication+NetworkActivityIndicator.m
//  RSTWebViewController
//
//  Created by Riley Testut on 12/23/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

#import "UIApplication+NetworkActivityIndicator.h"

@implementation UIApplication (NetworkActivityIndicator)

+ (void)startAnimatingNetworkActivityIndicator
{
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    [application setNetworkActivityIndicatorVisible:YES];
}

+ (void)stopAnimatingNetworkActivityIndicator
{
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    [application setNetworkActivityIndicatorVisible:NO];
}

@end
