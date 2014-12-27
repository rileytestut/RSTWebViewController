//
//  UIApplication+ExtensionSafe.h
//  RSTWebViewController
//
//  Created by Riley Testut on 12/26/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

@import UIKit;

@interface UIApplication (ExtensionSafe)

+ (instancetype)rst_sharedApplication;

- (BOOL)rst_openURL:(NSURL *)URL;

@end
