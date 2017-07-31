//
//  MapViewController.swift
//  GMap
//
//  Created by Alex on 21/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//



import UIKit
import GoogleMaps
import CoreLocation


class Map_VC: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var mapView: GMSMapView?
    var isFirstCoordinate = true

    let trackPolyline = GMSPolyline()
    var archiveTrackPolyline = GMSPolyline()
    
    let markerHeading = GMSMarker()
    let аccuracyCircle = GMSCircle()
    
    let markerStart = GMSMarker()
    let markerEnd = GMSMarker()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings.saveStartDataToDefaults()
        
        self.title = "Карта"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: ">", style: .plain, target: self, action: #selector(rightBarButtonClick) )
        

        // круглые маски под кнопками
        for btnView in view.subviews {
            if btnView is UIButton {
                btnView.layer.cornerRadius = btnView.frame.width/2
            }
        }
        
        markerStart.icon = #imageLiteral(resourceName: "markerA")
        markerStart.title = "Старт"
        markerEnd.icon = #imageLiteral(resourceName: "markerB")
        markerEnd.title = "Финиш"

        
        // инициализация менеджера координат
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        }
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
        let camera = GMSCameraPosition.camera(withLatitude: map.userLocation.coordinate.latitude, longitude: map.userLocation.coordinate.longitude, zoom: map.userZoom)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.insertSubview(mapView!, at: 0)
        
        archiveTrackPolyline.strokeWidth = 3
        
        trackPolyline.strokeWidth = 3
        trackPolyline.map = mapView
        

        markerHeading.isTappable = false
        markerHeading.icon = #imageLiteral(resourceName: "headingMarker")
        markerHeading.isFlat = true
        markerHeading.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        markerHeading.map = mapView
        
        аccuracyCircle.strokeWidth = 0
        
    }
    

    override func viewWillAppear(_ animated: Bool) {

        isFirstCoordinate = true
        navigationController?.navigationBar.isHidden = true
        
        // смена режимов карты из настроек
        locationManager.desiredAccuracy = settings.locationManagerAccuracy
        аccuracyCircle.fillColor = settings.circleFillColor
        trackPolyline.strokeColor = settings.trackStrokeColor
        mapView?.mapType = settings.mapViewType
        
        
        if settings.isCenterPosition {
            mapView?.settings.scrollGestures = false
        } else {
            mapView?.settings.scrollGestures = true
        }
        
        switch Track.status {
        case .record:
            trackPolyline.map = mapView
            
        case .stop:
            if map.userLocations.count > 1 {
                trackPolyline.map = mapView
            }   
        case .none:
            trackPolyline.map = nil
        }
        
        if map.userPath.count() == 0 {
            trackPolyline.path = map.userPath
        }


        if map.archiveCoordinates.count != 0 {
            
            markerStart.position = map.archiveCoordinates.first!
            markerStart.snippet = markerStart.position.latitude.description + "\n" + markerStart.position.longitude.description
            markerStart.map = mapView
            
            markerEnd.position = map.archiveCoordinates.last!
            markerEnd.snippet = markerEnd.position.latitude.description + "\n" + markerEnd.position.longitude.description
            markerEnd.map = mapView
            
            let archivePath = GMSMutablePath()
            for coordinate in map.archiveCoordinates {
                archivePath.add(coordinate)
            }
            archiveTrackPolyline.strokeColor = UIColor.magenta
            archiveTrackPolyline.path = archivePath
            archiveTrackPolyline.map = mapView!
        } else {
            markerStart.map = nil
            markerEnd.map = nil
            archiveTrackPolyline.map = nil
        }
        
        
   
        //  анимация перемещения к архивному треку при первом его просмотре
        if map.isArchiveTrackFirstLook {
            
            map.isArchiveTrackFirstLook = false
            let bounds = Track.getBoundsForArchiveCoordinates(coordinates: map.archiveCoordinates)
            let camera = mapView!.camera(for: bounds, insets:UIEdgeInsets.zero)
            
      
            mapView?.animate(toZoom: 3)

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                self.mapView!.animate(toLocation: (camera?.target)!)
                
                if (camera?.zoom)! > 17.0 {
                    self.mapView!.animate(toZoom: 17)
                } else {
                    self.mapView!.animate(toZoom: (camera?.zoom)! - 0.5)
                }
            })
            
        } else {
            animateToHeadMarker(self)
        }
    }
    

    
    
    @IBAction func animateToHeadMarker(_ sender: Any) {

        if map.userZoom != 3 {
            mapView!.animate(toLocation: map.userLocation.coordinate)
        }
    }
    
    
    //  програмное нажатие кнопки navigationItem.rightBarButtonItem
    @IBAction func menuButtonClick(_ sender: Any) {
       
      UIApplication.shared.sendAction( (navigationItem.rightBarButtonItem?.action)!, to: navigationItem.rightBarButtonItem?.target, from: self, for: nil)

    }
    
    func rightBarButtonClick () {
        map.userZoom = mapView!.camera.zoom
        performSegue(withIdentifier: "map-menu", sender: self)
    }
    
    
    
    @IBAction func plusButtonClick(_ sender: Any) {
        mapView!.animate(toZoom: mapView!.camera.zoom + 1)
   
    }

    @IBAction func minusButtonClick(_ sender: Any) {
        mapView!.animate(toZoom: mapView!.camera.zoom - 1)
    }
 
    

    // смена местоположения ( получение устройством новых координат )
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {


        map.currentHorizontalAccuracy = locations[0].horizontalAccuracy
        
        // перемещение камеры при получение первой позиции с начала входа на vc, без учета скорости и точности
        if isFirstCoordinate {
            map.userLocation = locations[0]
            mapView!.animate(toLocation: map.userLocation.coordinate)
            mapView!.animate(toBearing: 0)
            markerHeading.position = map.userLocation.coordinate
            showAccuracy(position: map.userLocation.coordinate, аccuracy: map.userLocation.horizontalAccuracy)
            isFirstCoordinate = false
            return
        }

        if mapView?.camera.zoom == 3 {
            mapView!.animate(toZoom: 17)
        }
        
        // ограничение скорости до 10 м/с
        if locations[0].speed > 10 {
            return
        }
        

            // плохая точность, центр круга старый, радиус новый
        if locations[0].horizontalAccuracy > 30 {
            showAccuracy(position: map.userLocation.coordinate, аccuracy: locations[0].horizontalAccuracy)
            return
        }

        // хорошая точность, центр круга новый, радиус новый
            map.userLocation = locations[0]
            showAccuracy(position: map.userLocation.coordinate, аccuracy: map.userLocation.horizontalAccuracy)

        markerHeading.position = map.userLocation.coordinate

        // перемещение камеры при статусе "центровка"
        if settings.isCenterPosition {
            animateToHeadMarker(self)
        }


        if Track.status == .record  {
            
            map.userPath.add(map.userLocation.coordinate)
            trackPolyline.path = map.userPath
            trackPolyline.map = mapView


            if map.userLocations.count > 0 {
                let timeNow: TimeInterval =  Date().timeIntervalSince1970
                let timeLastCoordinate: TimeInterval = (map.userLocations[map.userLocations.count-1].timestamp).timeIntervalSince1970
                let time = Int(timeNow - timeLastCoordinate)

            // запись точки с периодичностью
                if  time < settings.frequencyTypes[settings.frequencyIndex] {
                    return
                }
            }

                map.userLocations.append(map.userLocation)
        }   // .record
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        mapView?.frame.size = size
    }
    
    
    
    // поворот экрана экрана ( для компаса )
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
   
        var correction: Double = 0

        switch preferredInterfaceOrientationForPresentation {
        case .portrait:         correction = 0
        case .landscapeLeft:    correction = -90
        case .landscapeRight:   correction = 90
        case .portraitUpsideDown:   correction = 180
        default: return
        }
                
        switch settings.compassType  {
        case .trueMap: markerHeading.rotation = newHeading.trueHeading + correction
        case .magnetic: markerHeading.rotation = newHeading.magneticHeading + correction
        }
        
        map.direction = CGFloat(markerHeading.rotation)
        
    }
    
    

    func showAccuracy (position: CLLocationCoordinate2D, аccuracy: CLLocationDistance) {
            аccuracyCircle.radius = аccuracy
            аccuracyCircle.position = position
            аccuracyCircle.map = mapView
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



