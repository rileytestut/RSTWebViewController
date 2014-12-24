//
//  UIApplication+NetworkActivityIndicator.h
//  RSTWebViewController
//
//  Created by Riley Testut on 12/23/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

@import UIKit;

@interface UIApplication (NetworkActivityIndicator)

+ (void)startAnimatingNetworkActivityIndicator;
+ (void)stopAnimatingNetworkActivityIndicator;

@end
