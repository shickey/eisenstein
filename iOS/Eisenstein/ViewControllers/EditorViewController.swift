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

//let videoUrl = URL(string: "https://v.cdn.vine.co/r/videos_h264dash/C556231E881379309443162021888_50bad39a8a2.31.0.B933D152-281D-4FD4-A997-7B813C5F91E1.mp4")!

class EditorViewController: UIViewController, WKScriptMessageHandler {

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var playerContainerView: UIView!
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
        
        // Resize Preview Window
        let screenBounds = UIScreen.main.bounds
        self.playerContainerView.frame = CGRect(x: screenBounds.width - (screenBounds.height / 2), y: 0, width: screenBounds.height / 2, height: screenBounds.height / 2)
        
        // Create web view controller and bind to "ext" namespace (extensions)
        let webViewController = WKUserContentController()
        webViewController.add(self, name: "ext")
        webViewController.add(self, name: "cons")
        
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
        
//        self.player.url = videoUrl
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let clips = project!.clips!
        if clips.count > 0 {
            var clipsJsonString = "["
            for (idx, clip) in clips.enumerated() {
                let c = clip as! Clip
                clipsJsonString += "{title:\"\(c.title!)\"}"
                if idx != clips.count - 1 {
                    clipsJsonString += ","
                }
            }
            clipsJsonString += "]"
            
            print("Clips: \(clipsJsonString)")
            
            webView!.evaluateJavaScript("updateVideoMenus(\(clipsJsonString))", completionHandler: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Managed Object Context \(moc!)")
        print("Project \(project!)")
        print("Project ID \(project!.id!)")
        print("Project Media Directory \(project!.mediaDirectory)")
        
        webView!.evaluateJavaScript("console.log(\"Hello console!\")", completionHandler: nil)
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
//        if (message.name != "ext" || message.name != "cons") { return }
        
        if message.name == "cons" {
            print("Console message: ", message)
        }
        
        // Map message payloads to extensions
        if let body = message.body as? NSDictionary {
            print(body)
            let ext = body.object(forKey: "extension") as? String
            let method = body.object(forKey: "method") as? String
            
            // @todo Guard
            // @todo The validation for each of these should be much more strict
            // @todo Each of these should be bound in a more generic way (not in the View Contoller)
            
            // Video
            if (ext == "video") {
                if (method == "playUntilDone") {
                    let videoIndex = body.object(forKey: "videoIndex") as! NSNumber
                    let clip = project!.clips![videoIndex.intValue] as! Clip
                    let resolveId = body.object(forKey: "resolveId") as! String
                    
                    self.playingPromiseId = resolveId
                    self.player.url = clip.url! 
                    self.player.playFromBeginning()
                }
                else if (method == "startVideo") {
                    let videoIndex = body.object(forKey: "videoIndex") as! NSNumber
                    let clip = project!.clips![videoIndex.intValue] as! Clip
                    let resolveId = body.object(forKey: "resolveId") as! String
                    
                    if let storedId = self.playingPromiseId {
                        resolveVideoPromise(storedId)
                    }
                    
                    self.player.url = clip.url!
                    self.player.playFromBeginning()
                    
                    // resolve the promise immediately so the VM
                    // can keep executing blocks
                    resolveVideoPromise(resolveId)
                }
                else if (method == "rotateRightBy") {
                    let degrees = body.object(forKey: "degrees") as! NSNumber
                    let resolveId = body.object(forKey: "resolveId") as! String
                    rotateVideo(by: degrees.doubleValue, resolveId: resolveId)
                }
                else if (method == "rotateLeftBy") {
                    let degrees = body.object(forKey: "degrees") as! NSNumber
                    let resolveId = body.object(forKey: "resolveId") as! String
                    rotateVideo(by: -degrees.doubleValue, resolveId: resolveId)
                }
                else if (method == "setRotation") {
                    let degrees = body.object(forKey: "degrees") as! NSNumber
                    let resolveId = body.object(forKey: "resolveId") as! String
                    rotateVideo(to: degrees.doubleValue, resolveId: resolveId)
                }
                else if (method == "changeSizeBy") {
                    let percentage = body.object(forKey: "percentage") as! NSNumber
                    let resolveId = body.object(forKey: "resolveId") as! String
                    scaleVideo(by: percentage.doubleValue, resolveId: resolveId)
                }
                else if (method == "setSize") {
                    let percentage = body.object(forKey: "percentage") as! NSNumber
                    let resolveId = body.object(forKey: "resolveId") as! String
                    scaleVideo(to: percentage.doubleValue, resolveId: resolveId)
                }
                else if (method == "stopAll") {
                    self.player.stop()
                }
            }
        }
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * (Double.pi / 180.0)
    }
    
    func rotateVideo(by degrees: Double, resolveId: String) {
        UIView.animate(withDuration: 0, animations: { 
            self.playerView.transform = self.playerView.transform.rotated(by: CGFloat(self.degreesToRadians(degrees)))
        }) { (finished) in
            self.resolvePromise(resolveId)
        }
    }
    
    func rotateVideo(to degrees: Double, resolveId: String) {
        UIView.animate(withDuration: 0, animations: { 
            let transform = self.playerView.transform
            let currentRotation = atan2(transform.b, transform.a)
            self.playerView.transform = transform.rotated(by: -currentRotation).rotated(by: CGFloat(self.degreesToRadians(degrees)))
        }) { (finished) in
            self.resolvePromise(resolveId)
        }
    }
    
    func scaleVideo(by percentage: Double, resolveId: String) {
        UIView.animate(withDuration: 0, animations: { 
            let newScale = (percentage / 100.0) + 1.0
            self.playerView.transform = self.playerView.transform.scaledBy(x: CGFloat(newScale), y: CGFloat(newScale))
        }) { (finished) in
            self.resolvePromise(resolveId)
        }
    }
    
    func scaleVideo(to percentage: Double, resolveId: String) {
        UIView.animate(withDuration: 0, animations: { 
            let transform = self.playerView.transform
            let currentScale = sqrt(transform.a * transform.a + transform.c * transform.c)
            let newScale = percentage / 100.0
            self.playerView.transform = transform.scaledBy(x: 1.0 / currentScale, y: 1.0 / currentScale).scaledBy(x: CGFloat(newScale), y: CGFloat(newScale))
        }) { (finished) in
            self.resolvePromise(resolveId)
        }
    }
    
    func resolvePromise(_ promiseId: String) {
        webView!.evaluateJavaScript("resolveVideoPromise(\"\(promiseId)\")", completionHandler: nil)
    }
    
    func resolveVideoPromise(_ promiseId: String) {
        resolvePromise(promiseId)
        self.playingPromiseId = nil
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
            self.resolveVideoPromise(resolve)
        }
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
    }
    
}
