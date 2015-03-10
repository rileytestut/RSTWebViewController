//
//  RSTChromeActivity.swift
//  RSTWebViewController
//
//  Created by Riley Testut on 12/26/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

import UIKit

internal class RSTChromeActivity: UIActivity {
    
    private var URL: NSURL?
    
    override class func activityCategory() -> UIActivityCategory
    {
        return .Share
    }
    
    override func activityType() -> String?
    {
        return RSTActivityTypeChrome
    }
    
    override func activityTitle() -> String?
    {
        return NSLocalizedString("Chrome", comment: "")
    }
    
    override func activityImage() -> UIImage?
    {
        let bundle = NSBundle(forClass: RSTChromeActivity.self)
        return UIImage(named: "chrome_activity", inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool
    {
        if let application = UIApplication.rst_sharedApplication()
        {
            if let chromeURLScheme = NSURL(string: "googlechrome://")
            {
                let activityItem: AnyObject? = self.firstValidActivityItemInActivityItems(activityItems)
                
                if application.canOpenURL(chromeURLScheme) && activityItem != nil
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    override func prepareWithActivityItems(activityItems: [AnyObject])
    {
        if let activityItem: AnyObject = self.firstValidActivityItemInActivityItems(activityItems)
        {
            if activityItem is String
            {
                self.URL = NSURL(string: activityItem as! String)
            }
            else if activityItem is NSURL
            {
                self.URL = activityItem as? NSURL
            }
        }
    }
    
    override func performActivity()
    {
        let application = UIApplication.rst_sharedApplication()
        
        if self.URL == nil || application == nil
        {
            return self.activityDidFinish(false)
        }
        
        if let components = NSURLComponents(URL: self.URL!, resolvingAgainstBaseURL: false)
        {
            let scheme = components.scheme?.lowercaseString
            
            if scheme != nil && scheme == "https"
            {
                components.scheme = "googlechromes"
            }
            else
            {
                components.scheme = "googlechrome"
            }
            
            let finished = application.rst_openURL(components.URL)
            self.activityDidFinish(finished)
        }
        else
        {
            self.activityDidFinish(false)
        }
    }
    
    func firstValidActivityItemInActivityItems(activityItems: [AnyObject]) -> AnyObject?
    {
        if let application = UIApplication.rst_sharedApplication()
        {
            for activityItem in activityItems
            {
                var URL: NSURL?
                
                if activityItem is String
                {
                    URL = NSURL(string: activityItem as! String)
                }
                else if activityItem is NSURL
                {
                    URL = activityItem as? NSURL
                }
                
                if let URL = URL
                {
                    if application.canOpenURL(URL)
                    {
                        return activityItem
                    }
                }
            }
        }
        
        return nil
    }

}
