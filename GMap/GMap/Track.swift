//
//  Track.swift
//  GMap
//
//  Created by Alex on 11.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

class Track {
        
    // состояние
     enum Actions {
        case record
        case stop
        case none
    }
    static var status: Actions = .none
    
    // делает GPX из zx.userLocations
    static func makeGPX(forName: String, userLocations: [CLLocation]) -> String {
        
        let GPX_HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?><gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:gpxx=\"http://www.garmin.com/xmlschemas/GpxExtensions/v3\" xmlns:wptx1=\"http://www.garmin.com/xmlschemas/WaypointExtension/v1\" xmlns:gpxtpx=\"http://www.garmin.com/xmlschemas/TrackPointExtension/v1\" creator=\"%@\" version=\"1.1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www8.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/WaypointExtension/v1 http://www8.garmin.com/xmlschemas/WaypointExtensionv1.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd\"><metadata><link href=\"http://www.garmin.com\"><text>Garmin International</text></link><time>%@T%@Z</time></metadata><trk><name>%@</name><extensions><gpxx:TrackExtension><gpxx:DisplayColor>Red</gpxx:DisplayColor></gpxx:TrackExtension></extensions><trkseg>"
        
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        timeFormatter.dateFormat = "HH:mm:ss"
        
        var date = dateFormatter.string(from: Date())
        var time = timeFormatter.string(from: Date())
        
        
        var str = String(format: GPX_HEADER, BUNDLE, date, time, forName)
        
        for location in userLocations {
            
            let lat = String(format: "%.10f", location.coordinate.latitude)
            let lon = String(format: "%.10f", location.coordinate.longitude)
            let ele = String(format: "%.2f", location.altitude)
            
            let locationTimestamp = location.timestamp
            date = dateFormatter.string(from: locationTimestamp)
            time = timeFormatter.string(from: locationTimestamp)
            
            str = str + String(format: "<trkpt lat=\"%@\" lon=\"%@\"><ele>%@</ele><time>%@T%@Z</time></trkpt>", lat, lon, ele, date, time)
        }
        
        str = str + "</trkseg></trk></gpx>"
        return str
    }
    
    
    
    
    // возвращает рамку в которую вписан архивного трека
    static func getBoundsForArchiveCoordinates (coordinates: [CLLocationCoordinate2D]) -> GMSCoordinateBounds {
        
        var maxLat: Double = -360
        var minLat: Double = 360
        var maxLon: Double = -360
        var minLon: Double = 360
        
        for i in 0 ..< coordinates.count {
            
            // поиск крайних значений для Latitude
            if maxLat < coordinates[i].latitude {
                maxLat = coordinates[i].latitude
            }
            if minLat > coordinates[i].latitude {
                minLat = coordinates[i].latitude
            }
            
            // поиск крайних значений для Longitude
            if maxLon < coordinates[i].longitude {
                maxLon = coordinates[i].longitude
            }
            if minLon > coordinates[i].longitude {
                minLon = coordinates[i].longitude
            }
        }
        let coordinate1 = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
        let coordinate2 = CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
        
        return GMSCoordinateBounds(coordinate: coordinate1, coordinate: coordinate2)
}
}

    

