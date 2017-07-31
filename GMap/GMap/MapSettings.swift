//
//  MapSettings.swift
//  GMap
//
//  Created by Alex on 23/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation


// синглтон для передачи данных
class MapSettings {
    

    // для установки при возврате в VC карты
    var userLocation = CLLocation(latitude: 60, longitude: 50)
    var userZoom: Float = 3
    
    var userLocations: [CLLocation] = []
    var archiveCoordinates: [CLLocationCoordinate2D] = []
    
    // для defaults
    var trackStrokeColor = UIColor.blue.withAlphaComponent(0.1)
    var circleFillColor = UIColor.blue.withAlphaComponent(0.1)
    var locationManagerAccuracy = kCLLocationAccuracyBest
    var mapViewType = kGMSTypeNormal
    
    
    // для компаса
    var direction: CGFloat? = nil                 // направление устройства
    var speed: Double = -1                        // текущая скорость (для передачи в VC compass)
    var currentHorizontalAccuracy: Double? = nil
    
    let userPath = GMSMutablePath()
  
    var isArchiveTrackFirstLook = false


    static let shared = MapSettings()
    private init () { }
}

let map = MapSettings.shared
