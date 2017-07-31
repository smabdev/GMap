//
//  Settings_class.swift
//  GMap
//
//  Created by Alex on 09/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//
import UIKit
import Foundation
import CloudrailSI
import GoogleMaps

// Для хранения настроек
class Settings {

    enum Compass {
        case trueMap
        case magnetic
    }
    enum Coordinates {
        case dd_dddd
        case dd_mm_ss
    }
    

    // что сохраняется
    var circleFillColor = UIColor.blue.withAlphaComponent(0.1)
    var compassType: Compass = .trueMap
    var coordinatesType: Coordinates = .dd_dddd
    var locationManagerAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    var mapViewType = kGMSTypeNormal
    var trackStrokeColor = UIColor.blue
    var isCenterPosition = false
    var frequencyIndex: Int = 1

    //--------------------------------
    // числа из segment
    var frequencyTypes = [5, 10, 15, 20, 25, 30]

    
    
    
    // данные сохраняются в DEFAULTS при первом после установке приложения запуске
    func saveStartDataToDefaults () {
    
        if DEFAULTS.dictionaryRepresentation().keys.contains("frequencyIndex") {
            loadFromDefaults()
        } else {
            DEFAULTS.setValuesForKeys(["circleFillColor" : 2])
            DEFAULTS.setValuesForKeys(["compassType" : 0])
            DEFAULTS.setValuesForKeys(["coordinatesType" : 0])
            DEFAULTS.setValuesForKeys(["mapViewType" : 0])
            DEFAULTS.setValuesForKeys(["locationManagerAccuracy" : 1])
            DEFAULTS.setValuesForKeys(["trackStrokeColor" : 2])
            DEFAULTS.setValuesForKeys(["isCenterPosition" : 0])
            DEFAULTS.setValuesForKeys(["frequencyIndex" : 1])
            DEFAULTS.synchronize()
        }
    }

    
    // Загрузка из userDefaults в класс settings
    func loadFromDefaults() {
        switch DEFAULTS.integer(forKey: "circleFillColor") {
        case 0: circleFillColor = UIColor.red.withAlphaComponent(0.1)
        case 1: circleFillColor = UIColor.green.withAlphaComponent(0.1)
        case 2: circleFillColor = UIColor.blue.withAlphaComponent(0.1)
        case 3: circleFillColor = UIColor.black.withAlphaComponent(0.1)
        case 4: circleFillColor = UIColor.clear
        default: break
        }

        switch DEFAULTS.integer(forKey: "compassType"){
        case 0: compassType = .trueMap
        case 1: compassType = .magnetic
        default: break
        }
        
        switch DEFAULTS.integer(forKey: "coordinatesType"){
        case 0: coordinatesType = .dd_dddd
        case 1: coordinatesType = .dd_mm_ss
        default: break
        }
        
        switch DEFAULTS.integer(forKey: "mapViewType") {
        case 0: mapViewType = kGMSTypeNormal
        case 1: mapViewType = kGMSTypeSatellite
        case 2: mapViewType = kGMSTypeTerrain
        case 3: mapViewType = kGMSTypeHybrid
        default: break
        }
        
        switch DEFAULTS.integer(forKey: "locationManagerAccuracy") {
        case 0: locationManagerAccuracy = kCLLocationAccuracyBestForNavigation
        case 1: locationManagerAccuracy = kCLLocationAccuracyBest
        case 2: locationManagerAccuracy = kCLLocationAccuracyNearestTenMeters
        case 3: locationManagerAccuracy = kCLLocationAccuracyHundredMeters
        case 4: locationManagerAccuracy = kCLLocationAccuracyKilometer
        case 5: locationManagerAccuracy = kCLLocationAccuracyThreeKilometers
        default: break
        }
        
        switch DEFAULTS.integer(forKey: "trackStrokeColor") {
        case 0: trackStrokeColor = UIColor.red
        case 1: trackStrokeColor = UIColor.green
        case 2: trackStrokeColor = UIColor.blue
        case 3: trackStrokeColor = UIColor.black
        case 4: trackStrokeColor = UIColor.clear
        default: break
        }
        
        settings.isCenterPosition = DEFAULTS.bool(forKey: "isCenterPosition")
        settings.frequencyIndex =  DEFAULTS.integer(forKey: "frequencyIndex")
    }
    

    private init () { }
    static let shared = Settings()
    
}

     let settings = Settings.shared
 




