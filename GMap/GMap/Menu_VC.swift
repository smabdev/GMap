//
//  Menu.swift
//  GMap
//
//  Created by Alex on 14/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//


import UIKit
import Foundation
import GoogleMaps

class Menu_VC: UITableViewController {

    var menu = [[   "start",
                    "stop",
                    "clear current track",
                    "clear archive track",
                    "save",], [
                    "tracks",
                    "compass",
                    "settings" ], [
                    "info" ]]
    
    @IBOutlet weak var stopRecordCell: UITableViewCell!
    @IBOutlet weak var clearCurrentTrackCell: UITableViewCell!
    @IBOutlet weak var clearArchiveTrackCell: UITableViewCell!
    @IBOutlet weak var saveCell: UITableViewCell!

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = false
        title = "Меню"
        setCellsMask ()
    }
    
    
    
    // установка масок для неактивных пунктов меню
    func setCellsMask () {
        DispatchQueue.main.async {
        
            for testedView in self.view.subviews {
                if testedView.layer.opacity == 0.8 {
                    testedView.removeFromSuperview()
                }
            }
            // остановить запись трека
            if Track.status != .record {
                self.view.addSubview(self.getMaskCellView(forCellFrame: self.stopRecordCell.frame))
            }
            // очистить текущий трек
            if map.userPath.length(of: kGMSLengthGeodesic) == 0 {
                self.view.addSubview(self.getMaskCellView(forCellFrame: self.clearCurrentTrackCell.frame))
            }
            // удалить архивный трек с экрана
            if map.archiveCoordinates.count == 0 {
                self.view.addSubview(self.getMaskCellView(forCellFrame: self.clearArchiveTrackCell.frame))
            }
            // сохранить трек в архив      
            if map.userPath.length(of: kGMSLengthGeodesic) == 0 {
                self.view.addSubview(self.getMaskCellView(forCellFrame: self.saveCell.frame))
            }
        }
    }
    
    func getMaskCellView (forCellFrame: CGRect) -> UIView {
        let maskView = UIView(frame: forCellFrame)
        maskView.frame.size.height -= 1
        maskView.backgroundColor = UIColor.white
        maskView.layer.opacity = 0.8
        return maskView
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    // выбор пункта меню
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    switch menu[indexPath.section][indexPath.row] {
        
    case "start", "stop", "clear current track", "clear archive track":
        showAllert(menuIndex: indexPath.row)

    case "save":
        // alert для ввода имени ключа
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let trackName = dateFormatter.string(from: Date())
        let alertController = UIAlertController(title: "Сохранение текущего трека", message: "Для имени трека не используйте символ '/' и '.' первым символом.", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = trackName
        }

        let confirmAction = UIAlertAction(title: "Сохранить", style: .default)  { (_) in
            if let field = alertController.textFields?[0] {
                
                if field.text?.characters.first == "." || field.text?.characters.first == "/" {
                    return
                }
                
                // Проверка на аналогичное им ключа или добавление времени к бандл
                if Archive.names.contains(field.text!) {
                    let alertController = UIAlertController(title: "Ошибка", message: "Трек с таким именем уже имеется в базе. Смените имя трека.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Да", style: .default)  { (_) in }
                    alertController.addAction(confirmAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    
                    let gpxString = Track.makeGPX(forName: trackName, userLocations: map.userLocations)
                    
                    Archive.saveTrack(forName: field.text!, gpx: gpxString)
                }
            } else {    // user did not fill field  
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    case "tracks":
        performSegue(withIdentifier: "menu-tracks", sender: nil)
        
    case "compass":
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        performSegue(withIdentifier: "menu-compass", sender: nil)
        
    case "settings":
        performSegue(withIdentifier: "menu-settings", sender: nil)
        
    case "info":
        performSegue(withIdentifier: "menu-info", sender: nil)
        
    default: return
    }
    
    }
   
    
    // аллерты да/нет и действия для первых 4х пунктов меню
    func showAllert (menuIndex: Int) {
        
        let allertMessages = [
        "Очистить текущий трек и начать запись заново?",
        "Остановить запись трека?",
        "Остановить запись трека и удалить все маршрутные точки?",
        "Удалить архивный трек с экрана карты?"
        ]
        
        let alertController = UIAlertController(title: "Подтвердите действие", message: allertMessages[menuIndex], preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Да", style: .default)  { (_) in
            
            
            switch menuIndex {
                
                //start
            case 0:
                Track.status = .record
                self.clearCurrentTrack()
                let viewControllers = self.navigationController!.viewControllers
                self.navigationController!.popToViewController(viewControllers[self.navigationController!.viewControllers.count - 2], animated: true)
            
                //stop
            case 1:
                Track.status = .stop
                
                //clear current track
            case 2:
                Track.status = .none
                self.clearCurrentTrack()
                
                //clear archive track
            case 3:
                map.archiveCoordinates.removeAll()
  
            default: return
            }
                self.setCellsMask()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
  
    }
    
    
    
    
      
    func clearCurrentTrack () {
        map.userLocations.removeAll()
        map.userPath.removeAllCoordinates()

    }
    

}
