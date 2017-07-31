//
//  Compass_VC.swift
//  GMap
//
//  Created by Alex on 12/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import GoogleMaps


class Compass_VC: UIViewController {

    @IBOutlet var label: [UILabel]!
    @IBOutlet weak var compassImage: UIImageView!
    
    var timer       = Timer()
    let timeInterval = 0.1
    var userLocation = CLLocation()
    

    override var prefersStatusBarHidden: Bool {
        return true
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0 ..< label.count {
            label[index].layer.cornerRadius = 10
            label[index].clipsToBounds = true
        }
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(Compass_VC.timerTick), userInfo: nil, repeats: true)
    }

    
    func timerTick () {
        if map.currentHorizontalAccuracy != nil  {
            label[0].text = map.userLocation.coordinate.latitude.withCoordinatesType
            label[1].text = map.userLocation.coordinate.longitude.withCoordinatesType
            label[2].text = map.userLocation.altitude.inMeters
            label[3].text = map.currentHorizontalAccuracy?.inMeters
        }
        
        
        if  map.userLocation.speed >= 0.0 {
            label[4].text = map.userLocation.speed.InKm
        } else {
            label[4].text = 0.InKm
        }
        
        if map.userLocations.count > 1  {
            let timeStart: TimeInterval = (map.userLocations[0].timestamp).timeIntervalSince1970 // v
            let timeNow: TimeInterval =  Date().timeIntervalSince1970
            let timeZone: TimeInterval = TimeInterval(NSTimeZone.local.secondsFromGMT())
            let time: Date = Date(timeIntervalSince1970: timeNow - timeStart - timeZone)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            label[5].text = dateFormatter.string(from: time)
            
            let distance = map.userPath.length(of: kGMSLengthGeodesic)
            label[6].text = distance.inMetersOrKm
        }

        
        if map.direction != nil {
            label[7].text = String(format: "%.1f", map.direction!) + "°"
        
            let rad = CGFloat.pi / 180.0
            var transform = CATransform3DIdentity
            transform = CATransform3DRotate(transform, map.direction! * rad, 0, 0, 1)
            compassImage.layer.transform = transform
        }
    
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
