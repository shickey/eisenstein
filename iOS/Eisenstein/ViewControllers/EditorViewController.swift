//
//  EditorViewController.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/23/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import CoreData
import WebKit

let videoUrl = URL(string: "https://v.cdn.vine.co/r/videos_h264dash/C556231E881379309443162021888_50bad39a8a2.31.0.B933D152-281D-4FD4-A997-7B813C5F91E1.mp4")!

class EditorViewController: UIViewController, WKScriptMessageHandler {

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var playerView: UIView!
    
    var moc : NSManagedObjectContext?
    var project : Project?
    
    var webView: WKWebView!
    var player = Player()
    
    var playingPromiseId : String? = nil;
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    
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
        webView = WKWebView(frame: self.webViewContainer.frame, configuration: webViewConfig)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.panGestureRecognizer.isEnabled = false
        webView.scrollView.bounces = false
        
        // Load editor and add as subview
        let topurl = Bundle.main.url(forResource: "web", withExtension: nil)!
        let starturl = Bundle.main.url(forResource: "web/index", withExtension: "html")!
        webView!.loadFileURL(starturl, allowingReadAccessTo: topurl)
        
        // Bind extensions
        //        extSound = SoundExtension(webView)
        //        extWedo = WedoExtension(webView)
        
        // Add subview
        self.webViewContainer!.addSubview(webView)
        
        // Video player init
        self.player.playerDelegate = self
        self.player.playbackDelegate = self
        self.player.view.frame = self.playerView.bounds
        self.player.autoplay = false
        self.player.playbackResumesWhenBecameActive = false
        self.player.playbackResumesWhenEnteringForeground = false
        
        self.addChildViewController(self.player)
        self.playerView.addSubview(self.player.view)
        self.player.didMove(toParentViewController: self)
        
        self.player.url = videoUrl
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Managed Object Context \(moc!)")
        print("Project \(project!)")
        print("Project ID \(project!.id!)")
        print("Project Media Directory \(project!.mediaDirectory)")
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
                    self.playingPromiseId = resolveId!
                    self.player.playFromBeginning()
                }
            }
        }
    }
    
    func resolvePromise(_ promiseId: String) {
        webView!.evaluateJavaScript("resolveVideoPromise(\"\(promiseId)\")", completionHandler: nil)
    }
    
    // IBActions
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func videoReviewButtonTapped(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let captureVC = segue.destination as? CaptureViewController {
            captureVC.project = project
        }
        else if let clipsVC = segue.destination as? ClipsViewController {
            clipsVC.project = project
        }
    }

}


// MARK: - PlayerDelegate

extension EditorViewController : PlayerDelegate {
    
    func playerReady(_ player: Player) {
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
    }
    
}

// MARK: - PlayerPlaybackDelegate

extension EditorViewController : PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        if let resolve = self.playingPromiseId {
            self.resolvePromise(resolve)
        }
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }
    
}
