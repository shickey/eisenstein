//
//  EditorViewController.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/23/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import WebKit

class EditorViewController: UIViewController {

    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set view controller background color
        self.view.backgroundColor = UIColor(red: (0x33 / 255.0), green: (0x47 / 255.0), blue: (0x71 / 255.0), alpha: 1.0)
        
        // Create web view controller and bind to "ext" namespace (extensions)
        //        let webViewController = WKUserContentController()
        //        webViewController.add(self, name: "ext")
        
        // Create web view configuration
        let webViewConfig = WKWebViewConfiguration()
        //        webViewConfig.userContentController = webViewController
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
