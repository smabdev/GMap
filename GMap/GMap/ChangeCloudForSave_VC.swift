//
//  Popover_VC.swift
//  GMap
//
//  Created by Alex on 11.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import Foundation
import CloudrailSI
import CoreLocation
import GoogleMaps

class ChangeCloudForSave_VC: UIViewController {

    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var maskButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var maskView1: UIView!
    @IBOutlet weak var maskView2: UIView!
    
    @IBOutlet weak var oneDriveView: UIView!
    
    
    
    
    var bottomConstraint = NSLayoutConstraint()
    var animationTimeout = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        for constraint in view.constraints {
            if constraint.identifier == "bottomConstraint" {
                bottomConstraint = constraint
                bottomConstraint.constant = -320
                
                maskButton.layer.opacity = 0
                maskView1.layer.cornerRadius = 5
                maskView2.layer.cornerRadius = 5
                cancelButton.layer.cornerRadius = 5
                return
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        trackNameLabel.text = Archive.currentName
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
            UIView.animate(withDuration: self.animationTimeout) {
                self.navigationController?.navigationBar.frame.origin.y = -(self.navigationController?.navigationBar.frame.height)!
                self.bottomConstraint.constant = 2
                self.maskButton.layer.opacity = 1
                self.view.layoutIfNeeded()
            }
        })
    }
    
    
    @IBAction func onMaskButtonClick(_ sender: Any) {
        animateAndCloseVC ()
    }
    
    
    @IBAction func onCancelClick(_ sender: Any) {
        animateAndCloseVC ()
    }
    
    
    func animateAndCloseVC () {
        
        UIView.animate(withDuration: animationTimeout) {
            self.navigationController?.navigationBar.frame.origin.y = 0
            self.bottomConstraint.constant = -320
            self.maskButton.layer.opacity = 0
            self.view.layoutIfNeeded()
        }
        
         DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int (animationTimeout*1000)), execute: {
            self.view.removeFromSuperview()
        })
    }
    



    
    // показать архивный трек на экране
    @IBAction func onScreenClick(_ sender: Any) {
         
        map.archiveCoordinates = Archive.getGpxCoorditates(forName: Archive.currentName)
        map.isArchiveTrackFirstLook = true

        animateAndCloseVC ()

        let viewControllers = self.navigationController!.viewControllers
        self.navigationController!.popToViewController(viewControllers[0], animated: true)
        //
        self.view.removeFromSuperview()
 
    }
    
    
    
    
    // сохранить на Дропбокс
    @IBAction func onDropboxClick(_ sender: Any) {
        cloudDrive.storageType = "dropBox"
        save ()
    }
    

    @IBAction func onGoogleDriveClick(_ sender: Any) {
        cloudDrive.storageType = "googleDrive"
        save ()
    }

    @IBAction func onOneDriveClick(_ sender: Any) {
        cloudDrive.storageType = "oneDrive"
        save ()
    }
    

        
        
    func save () {
 
        let gpx = Archive.getGpxString(forName: Archive.currentName)
        let data = gpx.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let inputStream: InputStream = InputStream.init(data: data)
        
        var names = [String]()
        var isFolder = [Int]()
        
        cloudDrive.setupService()
        cloudDrive.path = "/"
        let folderItems = cloudDrive.retriveFilesFoldersData(path: cloudDrive.path)

        
        for item in folderItems {
            names.append(item.fileName)
            isFolder.append(item.isFolder)
        }
        
        let index = names.index(of: APP_NAME)
        if index == nil || isFolder[index!] == 0 {
            cloudDrive.createFolder(withPath: "/" + APP_NAME)
        }
        
        if cloudDrive.saveFile(toPath: "/" + APP_NAME + "/", fileName: Archive.currentName, inputStream: inputStream, size: data.count) {
        
            self.showAllertYes(title: nil, message: "Трек сохранен на " + cloudDrive.storageType + " в папку /" + APP_NAME)
        } else {
             self.showAllertYes(title: "Ошибка!", message: "Файл не сохранен")
        }
        
        animateAndCloseVC ()
      
    }
    
    

        

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
