//
//  EditorViewController.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/23/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import WebKit

class EditorViewController: UIViewController, WKScriptMessageHandler {

    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set view controller background color
        self.view.backgroundColor = UIColor(red: (0x33 / 255.0), green: (0x47 / 255.0), blue: (0x71 / 255.0), alpha: 1.0)
        
        // Create web view controller and bind to "ext" namespace (extensions)
        let webViewController = WKUserContentController()
        webViewController.add(self, name: "ext")
        
        // Create web view configuration
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = webViewController
        
        // Init webview and load editor
        webView = WKWebView(frame: self.view.frame, configuration: webViewConfig)
        webView.scrollView.isScrollEnabled = false;
        webView.scrollView.panGestureRecognizer.isEnabled = false;
        webView.scrollView.bounces = false;
        
        // Load editor and add as subview
        let topurl = Bundle.main.url(forResource: "web", withExtension: nil)!
        let starturl = Bundle.main.url(forResource: "web/index", withExtension: "html")!
        webView!.loadFileURL(starturl, allowingReadAccessTo: topurl)
        
        // Bind extensions
        //        extSound = SoundExtension(webView)
        //        extWedo = WedoExtension(webView)
        
        // Add subview
        self.view.addSubview(webView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // Validate
        if (message.name != "ext") { return }
        
        // Map message payloads to extensions
        if let body = message.body as? NSDictionary {
            let ext = body.object(forKey: "extension") as? String
            let method = body.object(forKey: "method") as? String
            let args = body.object(forKey: "args") as! [AnyObject]
            let resolveId = body.object(forKey: "resolveId") as? String
            
            // @todo Guard
            // @todo The validation for each of these should be much more strict
            // @todo Each of these should be bound in a more generic way (not in the View Contoller)
            
            // Video
            if (ext == "video") {
                if (method == "startPlayback") { 
                    
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (Timer) in
                        self.resolvePromise(resolveId!)
                    })
                }
                else if (method == "stopPlayback") { print("stop") }
            }
        }
    }
    
    func resolvePromise(_ promiseId: String) {
        print("stopping video: \(promiseId)")
        webView!.evaluateJavaScript("resolveVideoPromise(\"\(promiseId)\")", completionHandler: nil)
    }

}
