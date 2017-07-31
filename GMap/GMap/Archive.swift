//
//  Archive.swift
//  GMap
//
//  Created by Alex on 14.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//


import Foundation
import CoreLocation
import GoogleMaps


class Archive {
    
    // имя ключа для загрузки из user.defaults в виде com.GMtracker.Alex-2017-СЕН-10 10:10:10
    static var currentName = ""
    static var names = [String]()
    
    
    // после добавления трека/удаления в UserDefaults
    // формирует массив треков архива в виде [name.gpx]
    static func refreshNames()  {
        
        let keys = Array (UserDefaults.standard.dictionaryRepresentation().keys)
        var newNames = [String]()
        
        for key in keys {
            if key.hasPrefix(BUNDLE + "-") {
                let index = key.characters.index(after: key.characters.index(of: "-")!)
                newNames.append(key.substring(from: index))
            }
        }
        names = newNames.sorted()
    }
    
    
    
    static func getGpxString (forName: String) -> String {
        let gpx = DEFAULTS.string(forKey: BUNDLE + "-" + forName)
        return gpx!

    }
    
    
    // грузит GPX , декодирует
    static func getGpxCoorditates (forName: String) -> [CLLocationCoordinate2D] {
        
        var coordinate = CLLocationCoordinate2D()
        var coordinates = [CLLocationCoordinate2D]()
        
        let gpx = getGpxString(forName: forName).components(separatedBy: "trkseg")
        var dots = gpx[1].components(separatedBy: "trkpt")
        
        var i = 0
        
        repeat {
            if dots[i].contains("lat") == false {
                dots.remove(at: i)
            } else {
                let coords = dots[i].components(separatedBy: "\"")
                coordinate.latitude = Double(coords[1])!
                coordinate.longitude = Double(coords[3])!
                coordinates.append(coordinate)
                i = i + 1
            }
        } while i < dots.count
        return coordinates
    }
    
    
    
    
    static func saveTrack (forName: String, gpx: String)  {
        
        //  файл загруженый из облака
        if forName.hasSuffix(".gpx") {
            DEFAULTS.set(gpx, forKey: BUNDLE + "-" + forName)
        } else {
            //  файл сформированный приложением
            DEFAULTS.set(gpx, forKey: BUNDLE + "-" + forName + ".gpx")
        }
        
        DEFAULTS.synchronize()
        refreshNames()
        
    }
    

    static func deleteTrack (forName: String) {
        DEFAULTS.removeObject(forKey: BUNDLE + "-" + forName)
        DEFAULTS.synchronize()
        refreshNames()
    }
    
    
    
    
    
}



