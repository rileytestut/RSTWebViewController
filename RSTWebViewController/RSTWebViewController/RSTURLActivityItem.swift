//
//  RSTURLActivityItem.swift
//  RSTWebViewController
//
//  Created by Riley Testut on 12/26/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

import Foundation
import MobileCoreServices

internal extension RSTURLActivityItem
{
    // Set an item to be provided for the given activityType
    func setItem(item: AnyObject?, forActivityType activityType: String)
    {
        if let item: AnyObject = item
        {
            if self.itemDictionary == nil
            {
                self.itemDictionary = [String: NSExtensionItem]()
            }
            
            self.itemDictionary![activityType] = item
        }
        else
        {
            self.itemDictionary?[activityType] = nil
            
            if self.itemDictionary?.count == 0
            {
                self.itemDictionary = nil
            }
        }
    }
    
    // Returns item that will be provided for the given activityType
    func itemForActivityType(activityType: String) -> AnyObject?
    {
        return self.itemDictionary?[activityType]
    }
}

internal class RSTURLActivityItem: NSObject, UIActivityItemSource
{
    internal var title: String?
    internal var URL: NSURL
    internal var typeIdentifier = kUTTypeURL
    
    private var itemDictionary: [String: AnyObject]?
    
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
        if let item: AnyObject = self.itemDictionary?[activityType]
        {
            return item
        }
        
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
            
            item.attachments = [NSItemProvider(item: self.URL, typeIdentifier: kUTTypeURL as String)]
            
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
        return self.typeIdentifier as String
    }
}
