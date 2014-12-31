# RSTWebViewController

![RSTWebViewController](https://cloud.githubusercontent.com/assets/705880/5564786/3ea66d44-8e9a-11e4-932c-2940225754f5.png)

RSTWebViewController is a simple, yet powerful, in-app web browser for your iOS application. Unlike countless other in-app web browsers you can find, RSTWebViewController has been designed from the ground-up to take full advantage of iOS 8 features, notably the vastly superior WebKit.framework, adaptability APIs, as well as full support for both Share and Action Extensions, including the incredibly useful [1Password Extension](https://github.com/AgileBits/onepassword-app-extension).

## Features

• Uses brand new WKWebView class to ensure blazingly fast performance. (**Exclusive**!)  
• Built-in support for 1Password, integrated directly into the share sheet without the need to display a separate button. (**Exclusive**!)  
• Beautiful, full color Share icons to open the current link in either Safari or Chrome (if installed). (**Exclusive**!)  
• Customizable share sheet allowing you to disable any existing UIActivities, or to add your own application-specific UIActivities. (**Exclusive**!)  
• Adaptable UI, ensuring the layout is optimized for the device you’re on, and dynamically adjusting the layout should certain size classes change (looking at you, iPhone 6 Plus). (**Exclusive**!)  
• Fully App-Extension-Safe API compliant, dynamically enabling and disabling features depending on whether RSTWebViewController is being used in an Application or an Application Extension. (**Exclusive**!)  
• Displays progress bar to give a better indication of when web pages will finish loading.  
• Written (almost) entirely in Swift (because why not), yet fully supports being called by both Objective-C and Swift code.  

## Requirements

• iOS 8.0+  
• Xcode 6.1

## Installation

I am a huge fan of [CocoaPods](http://cocoapods.org), and I strongly recommend you trying it out for yourself as a better way to use open source code. That being said, while the upcoming CocoaPods 0.36 [will bring full support for Swift code](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/), it is not yet ready for everyone to use (reliably). Because of this, for the time being I recommend dragging the RSTWebViewController Xcode project into your project/workspace, and linking against the built framework.

### Installing as Sub-Project

1. Drag `RSTWebViewController.xcodeproj` into a subfolder of your Xcode project in the Files pane.
![Drag .xcodeproj](https://cloud.githubusercontent.com/assets/705880/5563568/9fed5018-8e45-11e4-8403-6ccc8b598ced.png)
2. Navigate to the Target Configuration Window by clicking the blue project icon, then select your app target in the “Targets” section of the sidebar.
3. Select the “General” tab at the top.
4. In the “Embedded Binaries” section, click the “+”, and select `RSTWebViewController.framework` from within your app project section. Afterwards, you should see this:
![Embedded RSTWebViewController.framework](https://cloud.githubusercontent.com/assets/705880/5563577/4fbdc158-8e46-11e4-8b43-e0d87189de0b.png)
5. Click the "Build Settings" tab at the top.
6. Ensure "Embedded Content Contains Swift Code" is set to YES for your target.

### Installing as Top-Level Workspace Project
(Note: this is _slightly_ more complicated than installing as a sub-project, and it provides practically no benefit. I only do this because for whatever reason I much prefer having all dependencies as top-level projects in my workspace as opposed to them being contained within another project’s file hierarchy.)

1. Drag `RSTWebViewController.xcodeproj` into the Files pane _above_ your Xcode project.
![Drag .xcodeproj](https://cloud.githubusercontent.com/assets/705880/5563572/d13c24e6-8e45-11e4-86eb-fc0220df6bdd.png)
2. If you are not currently working in a Workspace, Xcode will ask you if you would like to save the project in a new workspace. Click “Save”, and name your new workspace (typically I use the same name as my app .xcodeproj).
3. Navigate to the Target Configuration Window of your app project by clicking your app project’s blue icon, then select your app target in the “Targets” section of the sidebar.
4. Select the “General” tab at the top.
5. In the “Embedded Binaries” section, click the “+”, and select `RSTWebViewController.framework` from within the RSTWebViewController section. Afterwards, you should see something like this:
![Embedded RSTWebViewController.framework](https://cloud.githubusercontent.com/assets/705880/5563578/5128f4f4-8e46-11e4-9e6d-a312c9d52303.png)
5. Select `RSTWebViewController.framework` in your app project in the Files pane.
6. Open the right “File Inspector” pane if it is not already open, and change “Location” from “Absolute Path” to “Relative to Build Products” like so:  
![Change Location](https://cloud.githubusercontent.com/assets/705880/5563745/e4ee8246-8e53-11e4-9d81-8480745bec95.png)  
This ensures the correct build of the framework will be included with your application. Once you've done that, you should see the grayed out path of `RSTWebViewController.framework` has changed to this (you may need to select another file then return to the project file for it to update):
![Embedded RSTWebViewController.framework](https://cloud.githubusercontent.com/assets/705880/5563577/4fbdc158-8e46-11e4-8b43-e0d87189de0b.png)
7. Click the "Build Settings" tab at the top.
8. Ensure "Embedded Content Contains Swift Code" is set to YES for your target.

## Usage

### General

First, ensure you import the framework into your current file:  

	// Objective-C
	@import RSTWebViewController;

	// Swift
	import RSTWebViewController

Once you’ve imported the framework, actually using it is rather straightforward. However, one thing to note is that RSTWebViewController _must_ be contained within a UINavigationController. If you’re pushing it onto a navigation stack, it will work perfectly fine, but if presenting modally, make sure to first initialize a UINavigationController with RSTWebViewController as the rootViewController, and then present the UINavigationController.

    // Objective-C
    - (IBAction)presentWebViewController:(UIButton *)sender
    {
        RSTWebViewController *webViewController = [[RSTWebViewController alloc] initWithAddress:@"http://rileytestut.com"];
        webViewController.showsDoneButton = YES;
    
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
        [self presentViewController:navigationController animated:YES completion:nil];
    }

	// Swift
	@IBAction func presentWebViewController(sender: UIButton) {
        let webViewController = RSTWebViewController(address: "http://rileytestut.com")
        webViewController.showsDoneButton = true
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
	}
	
### Share Sheet

RSTWebViewController presents a standard UIActivityViewController when the user taps the Share button, allowing the user to select from a multitude of sharing options, including 3rd-party Share and Action Extensions. However, you're not limited to just these options, as you can supply RSTWebViewController with your own application-specific UIActivities. To do so, simply set `applicationActivities` to a non-nil NSArray of custom UIActivity subclasses.

    // Objective-C
    webViewController.applicationActivities = @[[RSTCustomActivity new], [GBADownloadActivity new]];
    
    // Swift
    webViewController.applicationActivities = [RSTCustomActivity(), GBADownloadActivity()]
    
Additionally, you can choose to exclude certain built-in activities from the share sheet. To do so, simply set `excludedActivityTypes` to a non-nil NSArray of UIActivity types you wish to prevent from appearing in the share sheet (currently, there is no way to exclude 3rd-party App Extensions).

    // Objective-C
    webViewController.excludedActivityTypes = @[UIActivityTypePostToTwitter, UIActivityTypeMail, RSTActivityTypeChrome];
    
    // Swift
    webViewController.excludedActivityTypes = [UIActivityTypePostToTwitter, UIActivityTypeMail, RSTActivityTypeChrome]

### 1Password

Unfortunately, even the new WKWebView class doesn't provide the user access to any of their iCloud Saved Passwords, so whenever the user comes to a login page, they need to manually enter their credentials themself. However, the amazing folks at 1Password have put together an Action Extension that helps with this very problem. Included in the share sheet is said Action Extension which allows the user to pick from their stored 1Password logins and automatically fill their credentials into whatever web page they're on. 

Unlike other implementations of this 1Password extension, RSTWebViewController is unique in that it can display the extension in the _same_ share sheet as the other sharing options, _without_ accidentally disabling certain share activities such as posting to Twitter and Facebook. However, for this to work, you have to modify your app project file ever so slightly:

1. Click your app project's blue icon in the Files pane, then select your app target from the "Targets" section.
2. Click the "Info" tab at the top.
3. Expand the "Imported UTIs" section.
4. Click the "+" twice, and fill the sections out exactly like this screenshot: ![1Password UTI](https://cloud.githubusercontent.com/assets/705880/5585026/3c88e890-9064-11e4-8911-bd1cf25f1e67.png)

Once you've done this, the 1Password extension will automatically show up in the share sheet if 1Password is installed, and the rest will be handled for you automatically by RSTWebViewController.

## License

RSTWebViewController is licensed under the MIT License, which is reproduced in full in the LICENSE file. While not required, any attribution in your project is much appreciated, since I love to see how my code is being used in all of your projects!

## Contact

I'm [@rileytestut on Twitter](http://twitter.com/rileytestut), and I tend to handle simple questions there. However, you may also choose to email me at [riley@rileytestut.com](mailto:riley@rileytestut.com) if you have any questions that might be harder to answer in just 140 characters.
