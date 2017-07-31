//
//  extensions.swift
//  GMap
//
//  Created by Alex on 15.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation
import UIKit


extension Double {
    var withCoordinatesType: String  {
        switch settings.coordinatesType {
            
        case .dd_dddd :
            return String(format: "%.6f", self)
            
        case .dd_mm_ss:
            let deg: Float
            var min: Float
            var sec: Float
            (deg, min) = modf( abs( Float(self)) )
            (min, sec) = modf(min*60)
            sec = floor(sec * 60)
            
            
            return Int(deg).description + "°" + Int(min).description + "'" + Int(sec).description + "\""
            
        }
    }
}

// километры либо метры
extension Double {
    var inMetersOrKm: String  {
        
        if map.userLocations.last!
            .altitude < 1000 {
            return String(format: "%.1f", self) + " м"
        } else {
            return String(format: "%.2f", self / 1000) + " км"
        }
        
    }
}

// метры
extension Double {
    var inMeters: String  {
        return String(format: "%.1f", self) + " м"
    }
}

// Speed is provided in m/s so multiply by 3.6 for kmph or 2.23693629 for mph.
extension Double {
    var InKm: String  {
        return String(format: "%.1f", self * 3.6) + " км/ч"
    }
    
    
}

extension UIViewController {
    func showAllertYes (title: String?, message: String ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Да", style: .default) { (_) in }
        
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
}



