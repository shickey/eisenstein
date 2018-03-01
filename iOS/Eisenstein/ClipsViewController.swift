//
//  ClipsViewController.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/27/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ClipCell"

class ClipCell : UICollectionViewCell {}

class ClipsViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var project : Project?
    let player = Player()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .landscape
        }
    }
    
    deinit {
        self.player.willMove(toParentViewController: self)
        self.player.view.removeFromSuperview()
        self.player.removeFromParentViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.addChildViewController(self.player)
        self.player.didMove(toParentViewController: self)
        
        self.player.autoplay = false
        self.player.playbackResumesWhenBecameActive = false
        self.player.playbackResumesWhenEnteringForeground = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let p = project {
            print("Found a project with \(p.clips!.count) clips")
            return p.clips!.count
        }
        else {
            print("No project found!")
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let clip = project!.clips![indexPath.item] as! Clip
    
        let titleButton = cell.viewWithTag(1) as! UIButton
        titleButton.setTitle(clip.title, for: .normal)
        
        let thumb = UIImage(data: clip.thumbnail!)
        let thumbView = cell.viewWithTag(2) as! UIImageView
        thumbView.image = thumb
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Start playing video preview in cell
        let clip = project!.clips![indexPath.item] as! Clip
        
        let cell = collectionView.cellForItem(at: indexPath)!
        let previewView = cell.viewWithTag(3)!
        previewView.alpha = 1
        
        self.player.view.frame = previewView.bounds
        previewView.addSubview(self.player.view)
        
        self.player.url = clip.url!
        
        self.player.playFromBeginning()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // Stop playing video preview in cell
        self.player.stop()
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            let previewView = cell.viewWithTag(3)!
            previewView.alpha = 0
        }
        
        self.player.view.removeFromSuperview()
        
    }

    // @TODO: This is an ugly hack. Find a better way to send the tap events
    //        from the cell to the view controller
    @IBAction func clipCellTitleButtonTapped(_ sender: Any) {
        // Disabled temporarily
        let cell = (sender as! UIButton).superview!.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let clip = project!.clips![indexPath.item] as! Clip
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editPropsVC = storyboard.instantiateViewController(withIdentifier: "editClipProperties") as! EditClipPropertiesViewController
        
        editPropsVC.clip = clip
        
        self.present(editPropsVC, animated: true, completion: nil)
    }
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
