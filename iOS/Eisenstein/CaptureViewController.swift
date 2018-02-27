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

    @IBOutlet weak var videoPreviewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NextLevel.shared.previewLayer.frame = videoPreviewView!.bounds
        videoPreviewView!.layer.addSublayer(NextLevel.shared.previewLayer)
        
        NextLevel.shared.delegate = self
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        print("nextLevelSessionWillStart")
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
