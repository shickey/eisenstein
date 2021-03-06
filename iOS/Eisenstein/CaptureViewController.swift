//
//  CaptureViewController.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/27/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController {
    
    static var clipNumber = 1;

    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var videoPreviewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButtonImageView: UIImageView!
    
    var project : Project?
    
    var pressToRecordGestureRecognizer : UILongPressGestureRecognizer?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextLevel.shared.previewLayer.frame = videoPreviewView!.bounds
        videoPreviewView!.layer.addSublayer(NextLevel.shared.previewLayer)
        
        let nextLevel = NextLevel.shared
        nextLevel.delegate = self
        nextLevel.deviceDelegate = self
        
        // @TODO: Update video config (square aspect, etc.)
        nextLevel.videoConfiguration.bitRate = 2000000
        nextLevel.videoConfiguration.aspectRatio = .square
        
        // Record Button
        self.pressToRecordGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        let gestureRecognizer = self.pressToRecordGestureRecognizer!
        gestureRecognizer.delegate = self
        gestureRecognizer.minimumPressDuration = 0.05
        gestureRecognizer.allowableMovement = 10.0
        self.recordButtonImageView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nextLevel = NextLevel.shared
        if nextLevel.authorizationStatus(forMediaType: .video) == .authorized && nextLevel.authorizationStatus(forMediaType: .audio) == .authorized {
            do {
                try nextLevel.start()
            }
            catch {
                // TODO: Handle error properly
                print("Could not load camera")
            }
        }
        else {
            nextLevel.requestAuthorization(forMediaType: .video)
            nextLevel.requestAuthorization(forMediaType: .audio)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NextLevel.shared.stop()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let clipsVC = segue.destination as? ClipsViewController {
            clipsVC.project = project
        }
    }
    
}

/****************************
 * Video Capture and Saving
 ****************************/
extension CaptureViewController {
    
    func startCapture() {
        NextLevel.shared.record()
    }
    
    func endCapture() {
        NextLevel.shared.pause { 
            // Completion Handler
            if let lastClip = NextLevel.shared.session?.clips.last {
                let moc = self.project!.managedObjectContext!
                let clip = self.project!.createClip(context: moc)
                clip.url = lastClip.url!
                clip.title = "Clip \(CaptureViewController.clipNumber)"
                CaptureViewController.clipNumber += 1
                
                let thumb = lastClip.thumbnailImage!
                let png = UIImagePNGRepresentation(thumb)!
                
                clip.thumbnail = png
                
                // @TODO: Handle save errors appropriately
                try! moc.save()
                
                print("created clip")
                let alert = UIAlertController(title: "Clip saved!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Video not saved!", message: "Uh oh! Try again!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

extension CaptureViewController: UIGestureRecognizerDelegate {
    
    @objc internal func handleLongPressGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            self.recordButtonImageView.isHighlighted = true
            UIView.animate(withDuration: 0.25) { 
                self.view.backgroundColor = UIColor(red: 0.15, green: 0.03, blue: 0.0, alpha: 1.0)
            }
            self.startCapture()
            break
        case .changed:
            break
        case .ended:
            fallthrough
        case .cancelled:
            fallthrough
        case .failed:
            self.recordButtonImageView.isHighlighted = false
            UIView.animate(withDuration: 0.25) { 
                self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            }
            self.endCapture()
            fallthrough
        default:
            break
        }
    }
}

extension CaptureViewController : NextLevelDelegate {
    
    // permission
    func nextLevel(_ nextLevel: NextLevel, didUpdateAuthorizationStatus status: NextLevelAuthorizationStatus, forMediaType mediaType: AVMediaType) {
        print("NextLevel, authorization updated for media \(mediaType) status \(status)")
        if nextLevel.authorizationStatus(forMediaType: AVMediaType.video) == .authorized &&
            nextLevel.authorizationStatus(forMediaType: AVMediaType.audio) == .authorized {
            do {
                try nextLevel.start()
            } catch {
                print("NextLevel, failed to start camera session")
            }
        } else if status == .notAuthorized {
            // gracefully handle when audio/video is not authorized
            print("NextLevel doesn't have authorization for audio or video")
        }
    }
    
    // configuration
    func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {
    }
    
    // session
    func nextLevelSessionWillStart(_ nextLevel: NextLevel) {
        nextLevel.session!.outputDirectory = project!.mediaDirectory.path
    }
    
    func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
        print("nextLevelSessionDidStart")
    }
    
    func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
        print("nextLevelSessionDidStop")
    }
    
    // interruption
    func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {
    }
    
    func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {
    }
    
    // mode
    func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {
    }
    
}

extension CaptureViewController: NextLevelDeviceDelegate {
    
    // position, orientation
    func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
    }
    
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
//        if self.view.bounds.width > self.view.bounds.height {
//            self.videoPreviewWidthConstraint!.constant = self.view.bounds.height
//        }
//        else {
//            self.videoPreviewWidthConstraint!.constant = self.view.bounds.width
//        }
//        
    }
    
    // format
    func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
    }
    
    // aperture
    func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
    }
    
    // focus, exposure, white balance
    func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidStopFocus(_  nextLevel: NextLevel) {
    }
    
    func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
    }
    
    func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
    }
    
    func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
    }
    
}
