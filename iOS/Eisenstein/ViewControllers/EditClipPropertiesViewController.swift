//
//  EditClipPropertiesViewController.swift
//  Eisenstein
//
//  Created by Sean Hickey on 2/28/18.
//  Copyright © 2018 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class EditClipPropertiesViewController: UIViewController {
    
    var clip : Clip?

    @IBOutlet weak var titleField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(EditClipPropertiesViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleField.text = clip!.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        requestDismissal()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        clip!.title = titleField.text!
        try! clip?.managedObjectContext!.save()
        requestDismissal()
    }
    
    func requestDismissal() {
        self.presentingViewController!.dismiss(animated: true, completion: nil)
    }
    
}
