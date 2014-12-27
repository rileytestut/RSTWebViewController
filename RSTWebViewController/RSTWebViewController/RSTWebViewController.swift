//
//  RSTWebViewController.swift
//  RSTWebViewController
//
//  Created by Riley Testut on 12/23/14.
//  Copyright (c) 2014 Riley Testut. All rights reserved.
//

import UIKit
import WebKit

public extension RSTWebViewController {
    
    //MARK: Update UI
    
    func updateToolbarItems()
    {
        if self.webView.loading
        {
            self.refreshButton = self.stopLoadingButton
        }
        else
        {
            self.refreshButton = self.reloadButton
        }
        
        self.backButton.enabled = self.webView.canGoBack
        self.forwardButton.enabled = self.webView.canGoForward
        
        self.toolbarItems = [self.backButton, self.flexibleSpaceItem, self.forwardButton, self.flexibleSpaceItem, self.refreshButton, self.flexibleSpaceItem, self.shareButton]
    }
    
}

public class RSTWebViewController: UIViewController {
    
    //MARK: Public Properties
    
    // WKWebView used to display webpages
    public private(set) var webView: WKWebView
    
    public private(set) var refreshButton: UIBarButtonItem
    public let backButton: UIBarButtonItem = UIBarButtonItem(image: nil, style: .Plain, target: nil, action: "goBack:")
    public let forwardButton: UIBarButtonItem = UIBarButtonItem(image: nil, style: .Plain, target: nil, action: "goForward:")
    public let shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: nil, action: "shareLink:")
    public let flexibleSpaceItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    
    // Set to true when presenting modally to show a Done button that'll dismiss itself. Must be set before presentation.
    public var showsDoneButton: Bool = false
    
    
    //MARK: Private Properties
    
    private let initialReqest: NSURLRequest?
    private let progressView = UIProgressView()
    private var ignoreUpdateProgress: Bool = false
    
    private let reloadButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: nil, action: "refresh:")
    private let stopLoadingButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: nil, action: "refresh:")
    
    
    //MARK: Initializers
    
    public required init(request: NSURLRequest?)
    {
        self.initialReqest = request
        
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        self.refreshButton = self.reloadButton
        
        super.init(nibName: nil, bundle: nil)
        
        self.initialize()
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
        let configuration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: CGRectZero, configuration: configuration)
        
        self.refreshButton = self.reloadButton
        
        super.init(coder: coder)
        
        self.initialize()
    }
    
    private func initialize()
    {
        self.progressView.progressViewStyle = .Bar
        self.progressView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.progressView.progress = 0.5
        self.progressView.alpha = 0.0
        self.progressView.hidden = true
        
        self.backButton.target = self
        self.forwardButton.target = self
        self.reloadButton.target = self
        self.stopLoadingButton.target = self
        self.shareButton.target = self
        
        let bundle = NSBundle(forClass: RSTWebViewController.self)
        self.backButton.image = UIImage(named: "back_button", inBundle: bundle, compatibleWithTraitCollection: nil)
        self.forwardButton.image = UIImage(named: "forward_button", inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
    deinit
    {
        self.stopKeyValueObserving()
    }
    
    
    //MARK: UIViewController
    
    public override func loadView()
    {
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
        
        self.updateToolbarItems()
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if self.webView.estimatedProgress < 1.0
        {
            self.transitionCoordinator()?.animateAlongsideTransition( { (context) in
                
                self.showProgressBar(animated: true)
                
                }) { (context) in
                    
                    if context.isCancelled()
                    {
                        self.hideProgressBar(animated: false)
                    }
            }
        }
        
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    public override func viewWillDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        var shouldHideToolbarItems = true
        
        if let toolbarItems = self.navigationController?.topViewController.toolbarItems
        {
            if toolbarItems.count > 0
            {
                shouldHideToolbarItems = false
            }
        }
        
        if shouldHideToolbarItems
        {
            self.navigationController?.setToolbarHidden(true, animated: false)
        }
        
        self.transitionCoordinator()?.animateAlongsideTransition( { (context) in
            
            self.hideProgressBar(animated: true)
            
            }) { (context) in
                
                if context.isCancelled() && self.webView.estimatedProgress < 1.0
                {
                    self.showProgressBar(animated: false)
                }
        }
    }
    
    public override func didMoveToParentViewController(parent: UIViewController?)
    {
        if parent == nil
        {
            self.webView.stopLoading()
        }
    }

    public override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: KVO
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>)
    {
        if context == RSTWebViewControllerContext
        {
            let webView = (object as WKWebView)
            
            switch keyPath
            {
            case "title":
                self.updateTitle(webView.title)
                
            case "estimatedProgress":
                self.updateProgress(Float(webView.estimatedProgress))
                
            case "loading":
                self.updateLoadingStatus(status: webView.loading)
                
            case "canGoBack", "canGoForward":
                self.updateToolbarItems()
                
            default:
                println("Unknown KVO keypath")
            }
        }
        else
        {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

}

// Cannot be private or else they will crash upon being called ಠ_ಠ
internal extension RSTWebViewController {
    
    //MARK: Dismissal
    
    func dismissWebViewController(sender: UIBarButtonItem)
    {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Toolbar Items
    
    func goBack(button: UIBarButtonItem)
    {
        self.webView.goBack()
    }
    
    func goForward(button: UIBarButtonItem)
    {
        self.webView.goForward()
    }
    
    func refresh(button: UIBarButtonItem)
    {
        if self.webView.loading
        {
            self.ignoreUpdateProgress = true
            self.webView.stopLoading()
        }
        else
        {
            if self.webView.URL == nil && self.webView.backForwardList.backList.count == 0 && self.initialReqest != nil
            {
                self.webView.loadRequest(self.initialReqest!)
            }
            else
            {
                self.webView.reload()
            }
        }
    }
    
    func shareLink(button: UIBarButtonItem)
    {
        let reloadButtonTintColor = self.reloadButton.tintColor
        let stopLoadingButtonTintColor = self.stopLoadingButton.tintColor
                
        let activityItem = RSTURLActivityItem(URL: self.webView.URL ?? NSURL())
        activityItem.title = self.webView.title
        
        let safariActivity = RSTSafariActivity()
        let chromeActivity = RSTChromeActivity()
        
        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: [safariActivity, chromeActivity])
        activityViewController.completionWithItemsHandler = { activityType, success, items, error in
            
            // Because tint colors aren't properly updated when views aren't in a view hierarchy, we manually fix any erroneous tint colors
            self.progressView.tintColorDidChange()
            
            let systemTintColor = UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1)
            
            // If previous tint color is nil, we need to temporarily set the tint color to something else or it won't visually update the tint color
            if reloadButtonTintColor == nil
            {
                self.reloadButton.tintColor = systemTintColor
            }
            
            if stopLoadingButtonTintColor == nil
            {
                self.stopLoadingButton.tintColor = systemTintColor
            }
            
            self.reloadButton.tintColor = reloadButtonTintColor
            self.stopLoadingButton.tintColor = stopLoadingButtonTintColor
            
        }
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}

private let RSTWebViewControllerContext = UnsafeMutablePointer<()>()

private extension RSTWebViewController {
    
    //MARK: KVO
    
    func startKeyValueObserving()
    {
        self.webView.addObserver(self, forKeyPath: "title", options:nil, context: RSTWebViewControllerContext)
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: nil, context: RSTWebViewControllerContext)
        self.webView.addObserver(self, forKeyPath: "loading", options: nil, context: RSTWebViewControllerContext)
        self.webView.addObserver(self, forKeyPath: "canGoBack", options: nil, context: RSTWebViewControllerContext)
        self.webView.addObserver(self, forKeyPath: "canGoForward", options: nil, context: RSTWebViewControllerContext)
    }
    
    func stopKeyValueObserving()
    {
        self.webView.removeObserver(self, forKeyPath: "title", context: RSTWebViewControllerContext)
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress", context: RSTWebViewControllerContext)
        self.webView.removeObserver(self, forKeyPath: "loading", context: RSTWebViewControllerContext)
        self.webView.removeObserver(self, forKeyPath: "canGoBack", context: RSTWebViewControllerContext)
        self.webView.removeObserver(self, forKeyPath: "canGoForward", context: RSTWebViewControllerContext)
    }
    
    //MARK: Update UI
    
    func updateTitle(title: String?)
    {
        self.title = title
    }
    
    func updateLoadingStatus(status loading: Bool)
    {
        self.updateToolbarItems()
        
        if let application = UIApplication.rst_sharedApplication()
        {
            if loading
            {
                application.networkActivityIndicatorVisible = true
            }
            else
            {
                application.networkActivityIndicatorVisible = false
            }
        }
        
    }
    
    func updateProgress(progress: Float)
    {
        if self.progressView.hidden
        {
            self.showProgressBar(animated: true)
        }
        
        if self.ignoreUpdateProgress
        {
            self.ignoreUpdateProgress = false
            self.hideProgressBar(animated: true)
        }
        else if progress < self.progressView.progress
        {
            // If progress is less than self.progressView.progress, another webpage began to load before the first one completed
            // In this case, we set the progress back to 0.0, and then wait until the next updateProgress, because it results in a much better animation
            
            self.progressView.setProgress(0.0, animated: false)
        }
        else
        {
            UIView.animateWithDuration(0.4, animations: {
                
                self.progressView.setProgress(progress, animated: true)
                
                }, completion: { (finished) in
                    
                    if progress == 1.0
                    {
                        // This delay serves two purposes. One, it keeps the progress bar on screen just a bit longer so it doesn't appear to disappear too quickly.
                        // Two, it allows us to prevent the progress bar from disappearing if the user actually started loading another webpage before the current one finished loading.
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((0.2 * Float(NSEC_PER_SEC)))), dispatch_get_main_queue(), {
                            
                            if self.webView.estimatedProgress == 1.0
                            {
                                self.hideProgressBar(animated: true)
                            }
                            
                        })
                    }
                    
            });
        }
    }
    
    func showProgressBar(#animated: Bool)
    {
        let navigationBarBounds = self.navigationController?.navigationBar.bounds ?? CGRectZero
        self.progressView.frame = CGRect(x: 0, y: navigationBarBounds.height - self.progressView.bounds.height, width: navigationBarBounds.width, height: self.progressView.bounds.height)
        
        self.navigationController?.navigationBar.addSubview(self.progressView)
        
        self.progressView.setProgress(Float(self.webView.estimatedProgress), animated: false)
        self.progressView.hidden = false
        
        if animated
        {
            UIView.animateWithDuration(0.4) {
                self.progressView.alpha = 1.0
            }
        }
        else
        {
            self.progressView.alpha = 1.0
        }
    }
    
    func hideProgressBar(#animated: Bool)
    {
        if animated
        {
            UIView.animateWithDuration(0.4, animations: {
                self.progressView.alpha = 0.0
                }, completion: { (finished) in
                    
                    self.progressView.setProgress(0.0, animated: false)
                    self.progressView.hidden = true
                    self.progressView.removeFromSuperview()
            })
        }
        else
        {
            self.progressView.alpha = 0.0
            
            // Completion
            self.progressView.setProgress(0.0, animated: false)
            self.progressView.hidden = true
            self.progressView.removeFromSuperview()
        }
    }

}