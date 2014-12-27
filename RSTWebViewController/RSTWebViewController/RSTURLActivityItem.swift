//
//  RSTURLActivityItem.swift
//  RSTWebViewController
//
//  Created by Riley Testut on 12/26/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

import Foundation
import MobileCoreServices

internal class RSTURLActivityItem: NSObject, UIActivityItemSource
{
    internal var title: String?
    internal var URL: NSURL
    
    init(URL: NSURL)
    {
        self.URL = URL
        
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject
    {
        return self.URL
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject?
    {
        let extensionActivityTypes: [String] = [UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypePostToWeibo, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo]
        let applicationActivityTypes: [String] = [RSTActivityTypeSafari, RSTActivityTypeChrome]
        
        if self.title != nil && !contains(applicationActivityTypes, activityType) && (!activityType.lowercaseString.hasPrefix("com.apple") || contains(extensionActivityTypes, activityType))
        {
            let item = NSExtensionItem()
            
            // Theoretically, attributedTitle would be most appropriate for a URL title, but Apple supplies URL titles as attributedContentText from Safari
            // In addition, Apple's own share extensions (Twitter, Facebook, etc.) only use the attributedContentText property to fill in their compose view
            // So, to ensure all share/action extensions can access the URL title, we set it for both attributedTitle and attributedContentText
            item.attributedTitle = NSAttributedString(string: self.title!)
            item.attributedContentText = item.attributedTitle
            
            item.attachments = [NSItemProvider(item: self.URL, typeIdentifier: kUTTypeURL)]
            
            return item
        }
        
        return self.URL
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String
    {
        return self.title ?? ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: String?) -> String
    {
        return kUTTypeURL
    }
}
