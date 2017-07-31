//
//  TableViewController3.swift
//  GMap
//
//  Created by Alex on 14/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import GoogleMaps


class Settings_VC: UITableViewController {

    @IBOutlet weak var accuracySwitch: UISwitch!
    @IBOutlet weak var accuracyColorSegment: UISegmentedControl!

    @IBOutlet weak var compassSegment: UISegmentedControl!
    @IBOutlet weak var coordsSegment: UISegmentedControl!

    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
    @IBOutlet weak var signalQualitySegment: UISegmentedControl!
    @IBOutlet weak var trackColorSegment: UISegmentedControl!
    @IBOutlet weak var centerPositionSwitch: UISwitch!
    @IBOutlet weak var frequencySegment: UISegmentedControl!
    
    @IBOutlet weak var dropBoxLogin: UILabel!
    @IBOutlet weak var dropBoxLoginSwitch: UISwitch!
    
    @IBOutlet weak var googleDriveLogin: UILabel!
    @IBOutlet weak var googleDriveLoginSwitch: UISwitch!
    
    @IBOutlet weak var oneDriveLogin: UILabel!
    @IBOutlet weak var oneDriveLoginSwitch: UISwitch!

    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0 ..< frequencySegment.numberOfSegments {
            settings.frequencyTypes.append( Int(frequencySegment.titleForSegment(at: index)! )!)
        }
        settings.loadFromDefaults()
        loadViewsFromDefaults()
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        saveViewsToSettings()
        saveViewsToDefaults()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    @IBAction func accuracySwitchChanged(_ sender: Any) {
        accuracyColorSegment.isEnabled = accuracySwitch.isOn
    }
    
    

    // выключение логина dropbox
    @IBAction func dropBoxSwitchChanged(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "dropBox")
        dropBoxLogin.text = "none"
        dropBoxLoginSwitch.isEnabled = false
    }
    
    // выключение логина GoogleDrive
    @IBAction func googleDriveSwitchChanged(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "googleDrive")
        googleDriveLogin.text = "none"
        googleDriveLoginSwitch.isEnabled = false
    }
    
    // выключение логина oneDrive
    @IBAction func oneDriveSwitchChanged(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "oneDrive")
        oneDriveLogin.text = "none"
        oneDriveLoginSwitch.isEnabled = false
    }

    
    
    
    // 1. Сохранение состояния переключателей с экрана в settings при уходе из VC
    func saveViewsToSettings () {
        
        if accuracySwitch.isOn == false {
            settings.circleFillColor = UIColor.clear
        } else {
            switch accuracyColorSegment.selectedSegmentIndex {
            case 0: settings.circleFillColor = UIColor.red.withAlphaComponent(0.1)
            case 1: settings.circleFillColor = UIColor.green.withAlphaComponent(0.1)
            case 2: settings.circleFillColor = UIColor.blue.withAlphaComponent(0.1)
            case 3: settings.circleFillColor = UIColor.black.withAlphaComponent(0.1)
            default: break
            }
        }
        
        switch compassSegment.selectedSegmentIndex {
        case 0: settings.compassType = .trueMap
        case 1: settings.compassType = .magnetic
        default: break
        }
        
        switch coordsSegment.selectedSegmentIndex {
        case 0: settings.coordinatesType = .dd_dddd
        case 1: settings.coordinatesType = .dd_mm_ss
        default: break
        }
        
        switch mapTypeSegment.selectedSegmentIndex {
        case 0: settings.mapViewType = kGMSTypeNormal
        case 1: settings.mapViewType = kGMSTypeSatellite
        case 2: settings.mapViewType = kGMSTypeTerrain
        case 3: settings.mapViewType = kGMSTypeHybrid
        default: break
        }
        
        switch signalQualitySegment.selectedSegmentIndex {
        case 0: settings.locationManagerAccuracy = kCLLocationAccuracyBestForNavigation
        case 1: settings.locationManagerAccuracy = kCLLocationAccuracyBest
        case 2: settings.locationManagerAccuracy = kCLLocationAccuracyNearestTenMeters
        case 3: settings.locationManagerAccuracy = kCLLocationAccuracyHundredMeters
        case 4: settings.locationManagerAccuracy = kCLLocationAccuracyKilometer
        case 5: settings.locationManagerAccuracy = kCLLocationAccuracyThreeKilometers
        default: break
        }
        
        switch trackColorSegment.selectedSegmentIndex {
        case 0: settings.trackStrokeColor = UIColor.red
        case 1: settings.trackStrokeColor = UIColor.green
        case 2: settings.trackStrokeColor = UIColor.blue
        case 3: settings.trackStrokeColor = UIColor.black
        default: break
        }
        
        settings.isCenterPosition = centerPositionSwitch.isOn
        settings.frequencyIndex = frequencySegment.selectedSegmentIndex
    }
    
    
    
    // 2. Сохранение состояния переключателей с экрана в Defaults при уходе из VC
    func saveViewsToDefaults() {
        
        DEFAULTS.setValuesForKeys(["circleFillColor" : accuracyColorSegment.selectedSegmentIndex])
        DEFAULTS.setValuesForKeys(["compassType" : compassSegment.selectedSegmentIndex])
        DEFAULTS.setValuesForKeys(["coordinatesType" : coordsSegment.selectedSegmentIndex])
        DEFAULTS.setValuesForKeys(["mapViewType" : mapTypeSegment.selectedSegmentIndex])
        DEFAULTS.setValuesForKeys(["locationManagerAccuracy" : signalQualitySegment.selectedSegmentIndex])
        DEFAULTS.setValuesForKeys(["trackStrokeColor" : trackColorSegment.selectedSegmentIndex])
        DEFAULTS.setValuesForKeys(["isCenterPosition" : centerPositionSwitch.isOn])
        DEFAULTS.setValuesForKeys(["frequencyIndex" : frequencySegment.selectedSegmentIndex])
        DEFAULTS.synchronize()
    }

    
    
    
    // Загрузка из userDefaults в views
    func loadViewsFromDefaults() {
        
        if DEFAULTS.integer(forKey: "circleFillColor") > 4 {
            accuracySwitch.isOn = false
            accuracyColorSegment.isEnabled = false
            accuracyColorSegment.selectedSegmentIndex = DEFAULTS.integer(forKey: "circleFillColor") - 4
        } else {
            accuracySwitch.isOn = true
            accuracyColorSegment.isEnabled = true
            accuracyColorSegment.selectedSegmentIndex = DEFAULTS.integer(forKey: "circleFillColor")
        }
        
        compassSegment.selectedSegmentIndex  = DEFAULTS.integer(forKey: "compassType")
        coordsSegment.selectedSegmentIndex  = DEFAULTS.integer(forKey: "coordinatesType")
        mapTypeSegment.selectedSegmentIndex  = DEFAULTS.integer(forKey: "mapViewType")
        signalQualitySegment.selectedSegmentIndex  = DEFAULTS.integer(forKey: "locationManagerAccuracy")
        trackColorSegment.selectedSegmentIndex  = DEFAULTS.integer(forKey: "trackStrokeColor")
        centerPositionSwitch.isOn = DEFAULTS.bool(forKey: "isCenterPosition")
        frequencySegment.selectedSegmentIndex = DEFAULTS.integer(forKey: "frequencyIndex")
        

        let keys = DEFAULTS.dictionaryRepresentation().keys
        if keys.contains("dropBox") {
            dropBoxLogin.text = "autorized"
            dropBoxLoginSwitch.isEnabled = true
            dropBoxLoginSwitch.isOn = true
        } else {
            dropBoxLogin.text = "none"
            dropBoxLoginSwitch.isEnabled = false
            dropBoxLoginSwitch.isOn = false
        }
        
        if keys.contains("googleDrive") {
            googleDriveLogin.text = "autorized"
            googleDriveLoginSwitch.isEnabled = true
            googleDriveLoginSwitch.isOn = true
        } else {
            googleDriveLogin.text = "none"
            googleDriveLoginSwitch.isEnabled = false
            googleDriveLoginSwitch.isOn = false
        }
        
        if keys.contains("oneDrive") {
            oneDriveLogin.text = "autorized"
            oneDriveLoginSwitch.isEnabled = true
            oneDriveLoginSwitch.isOn = true
        } else {
            oneDriveLogin.text = "none"
            oneDriveLoginSwitch.isEnabled = false
            oneDriveLoginSwitch.isOn = false
        }
        
        
    }

}
