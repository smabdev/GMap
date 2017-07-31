//
//  CloudSource_VC.swift
//  GMap
//
//  Created by Alex on 13.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit

class ChangeCloudForLoad_VC: UIViewController {

    @IBOutlet weak var maskButton: UIView!
    @IBOutlet weak var rotatedView: UIView!
    
    var isCloudStorage = false
    let rad = CGFloat.pi / 180.0
    var transform = CATransform3DIdentity
    var animationTimeout = 0.5
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        maskButton.layer.opacity = 0
        view.sendSubview(toBack: maskButton)
        rotatedView.layer.transform = CATransform3DRotate(transform, -90 * rad, 0, 0, 1)

        for buttonView in rotatedView.subviews {
            buttonView.layer.borderWidth = 1
            buttonView.layer.borderColor =  UIColor.blue.cgColor
            buttonView.layer.cornerRadius = 50
            buttonView.clipsToBounds = true
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.maskButton.layer.opacity = 0
            self.rotatedView.layer.transform = CATransform3DRotate(self.transform, -90 * self.rad, 0, 0, 1)
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animationTimeout) {
                self.rotatedView.layer.transform = CATransform3DRotate(self.transform, 0 * self.rad , 0, 0, 1)
                self.maskButton.layer.opacity = 1
            
                self.navigationController?.navigationBar.frame.origin.y = -(self.navigationController?.navigationBar.frame.height)!
            
                self.view.layoutIfNeeded()
            }
        }
 
    }
    
    
    
    @IBAction func onMaskButtonClick(_ sender: Any) {
        isCloudStorage = false
        animateAndCloseVC ()
    }
    

    @IBAction func onCancelClick(_ sender: Any) {
        isCloudStorage = false
        animateAndCloseVC ()
    }

 
    @IBAction func onDropBoxClick(_ sender: Any) {
        cloudDrive.storageType = "dropBox"
        isCloudStorage = true
        animateAndCloseVC ()
    }
    
    
    @IBAction func onGoogleDriveClick(_ sender: Any) {
        cloudDrive.storageType = "googleDrive"
        isCloudStorage = true
        animateAndCloseVC ()
    }
    
    
    @IBAction func onOneDriveClick(_ sender: Any) {
        cloudDrive.storageType = "oneDrive"
        isCloudStorage = true
        animateAndCloseVC ()
    }
    

    
    func animateAndCloseVC () {
        
        UIView.animate(withDuration: self.animationTimeout) {
            self.rotatedView.layer.transform = CATransform3DRotate(self.transform, -90 * self.rad , 0, 0, 1)
            self.maskButton.layer.opacity = 0
            self.navigationController?.navigationBar.frame.origin.y = 0
            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int (animationTimeout*1000)), execute: {
 
            if self.isCloudStorage {
                self.performSegue(withIdentifier: "cloudFileSystem", sender: self)
                self.view.removeFromSuperview()
            } else {
                self.view.removeFromSuperview()
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }




}
