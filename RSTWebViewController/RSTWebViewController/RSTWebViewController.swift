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
    public private(set) var webView: WKWebView!
    
    // Set to true when presenting modally to show a Done button that'll dismiss itself. Must be set before presentation.
    public var showsDoneButton: Bool = false
    
    
    //MARK: Private Properties
    
    private let initialReqest: NSURLRequest?
    private let progressView: UIProgressView
    
    
    //MARK: Initializers
    
    public required init(request: NSURLRequest?)
    {
        self.initialReqest = request
        
        self.progressView = UIProgressView()
        
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
        self.progressView = UIProgressView()
        
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
    }
    
    public override func viewWillDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
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
            
            switch keyPath
            {
            case "title":
                self.updateTitle(webView.title)
                
            case "estimatedProgress":
                self.updateProgress(Float(webView.estimatedProgress))
                
            case "loading":
                self.updateLoadingStatus(status: webView.loading)
                
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

private let RSTWebViewControllerContext = UnsafeMutablePointer<()>()

private extension RSTWebViewController {
    
    //MARK: KVO
    
    func startKeyValueObserving()
    {
        if let webView = self.webView
        {
            webView.addObserver(self, forKeyPath: "title", options:nil, context: RSTWebViewControllerContext)
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: nil, context: RSTWebViewControllerContext)
            webView.addObserver(self, forKeyPath: "loading", options: nil, context: RSTWebViewControllerContext)
        }
    }
    
    func stopKeyValueObserving()
    {
        if let webView = self.webView
        {
            webView.removeObserver(self, forKeyPath: "title", context: RSTWebViewControllerContext)
            webView.removeObserver(self, forKeyPath: "estimatedProgress", context: RSTWebViewControllerContext)
            webView.removeObserver(self, forKeyPath: "loading", context: RSTWebViewControllerContext)
        }
    }
    
    //MARK: Update UI
    
    func updateTitle(title: String?)
    {
        self.title = title
    }
    
    func updateLoadingStatus(status loading: Bool)
    {
        if loading
        {
            UIApplication.startAnimatingNetworkActivityIndicator()
        }
        else
        {
            UIApplication.stopAnimatingNetworkActivityIndicator()
        }
    }
    
    func updateProgress(progress: Float)
    {
        if self.progressView.hidden
        {
            self.showProgressBar(animated: true)
        }
        
        // If progress is less than self.progressView.progress, another webpage began to load before the first one completed
        // In this case, we set the progress back to 0.0, and then wait until the next updateProgress, because it results in a much better animation
        if progress < self.progressView.progress
        {
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
