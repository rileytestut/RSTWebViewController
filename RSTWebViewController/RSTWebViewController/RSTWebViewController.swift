//
//  RSTWebViewController.swift
//  RSTWebViewController
//
//  Created by Riley Testut on 12/23/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

import UIKit
import WebKit

public class RSTWebViewController: UIViewController {
    
    //MARK: Public Properties
    
    // WKWebView used to display webpages
    public var webView: WKWebView!
    
    // Set to true when presenting modally to show a Done button that'll dismiss itself. Must be set before presentation.
    public var showsDoneButton: Bool = false
    
    
    //MARK: Private Properties
    
    private var initialReqest: NSURLRequest?
    
    
    //MARK: Initializers
    
    public required init(request: NSURLRequest?)
    {
        self.initialReqest = request
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init (URL: NSURL?)
    {
        if let URL = URL
        {
            self.init(request: NSURLRequest(URL: URL))
        }
        else
        {
            self.init(request: nil)
        }
    }
    
    public convenience init (address: String?)
    {
        if let address = address
        {
            self.init(URL: NSURL(string: address))
        }
        else
        {
            self.init(URL: nil)
        }
    }
    
    public required init(coder: NSCoder)
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit
    {
        self.stopKeyValueObserving()
    }
    
    
    //MARK: UIViewController
    
    public override func loadView()
    {
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        self.startKeyValueObserving()
        
        if let request = self.initialReqest
        {
            self.webView.loadRequest(request)
        }
        
        self.view = self.webView
    }

    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if self.showsDoneButton
        {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissWebViewController:")
            self.navigationItem.setRightBarButtonItem(doneButton, animated: false)
        }
        
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
    }

    public override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Dismissal
    
    // Cannot be private or else it will crash upon being called ಠ_ಠ
    internal func dismissWebViewController(sender: UIBarButtonItem)
    {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: KVO
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>)
    {
        if context == RSTWebViewControllerContext
        {
            let webView = (object as WKWebView)
            
            if keyPath == "title"
            {
                self.updateTitle(webView.title)
            }
        }
        else
        {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

}

private let RSTWebViewControllerContext = UnsafeMutablePointer<()>()

private extension RSTWebViewController {
    
    //MARK: KVO
    
    func startKeyValueObserving()
    {
        if let webView = self.webView
        {
            webView.addObserver(self, forKeyPath: "title", options:nil, context: RSTWebViewControllerContext)
        }
    }
    
    func stopKeyValueObserving()
    {
        if let webView = self.webView
        {
            webView.removeObserver(self, forKeyPath: "title", context: RSTWebViewControllerContext)
        }
    }
    
    //MARK: Update UI
    
    func updateTitle(title: String?)
    {
        self.title = title
    }    

}
