//
//  ViewController.swift
//  CloudDrive_VC
//
//  Created by Alex on 16.06.17.
//  Copyright © 2017 Alex. All rights reserved.
//

// проект для чтения/записи в облачные хранилица для DropBox, GoogleDrive, OneDrive
// сделан на основе:
// https://github.com/CloudRail/cloudrail-si-ios-sdk



import UIKit
import CloudrailSI

class CloudDrive_VC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dirItems = Array(repeating: CloudDrive.DirItem(), count: 0)
    let backgroundQueue = DispatchQueue(label: "com.backgroundQueue.queue", qos: .background, target: nil)
    
    var errorLabelTopConstraint = NSLayoutConstraint()
    var errorLabelTimer = Timer()
 

    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudDrive.path = "/"
        title = cloudDrive.storageType
        
        for constraint in view.constraints {
            if constraint.identifier == "errorLabelTopConstraint" {
                errorLabelTopConstraint = constraint
                errorLabelTopConstraint.constant = 0            // - 44 = open
                view.bringSubview(toFront: errorLabel)
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            cloudDrive.setupService()
            self.getFilesFoldersData()
        })
    }
    
    
    func getFilesFoldersData () {
        
        DispatchQueue.main.async {
            self.tableView.isUserInteractionEnabled = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        backgroundQueue.async {
        
        self.dirItems = cloudDrive.retriveFilesFoldersData(path: cloudDrive.path)
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.isUserInteractionEnabled = true
                self.tableView.reloadData()
            }
        }
        
        
    }
    

    
    // установка размера таблицы (строк)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dirItems.count
    }
    
    // отрисовка таблицы с файловой системой облака
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = (indexPath as NSIndexPath).row
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as UITableViewCell
        cell.imageView?.image = dirItems[row].image
        cell.textLabel?.text = dirItems[row].fileName
        cell.textLabel?.textColor = UIColor.black
        cell.detailTextLabel?.textColor = UIColor.black
        cell.isUserInteractionEnabled = true
        
        switch dirItems[row].priority {
        case 0:
            // root
            cell.detailTextLabel?.text = nil
            cell.isUserInteractionEnabled = false
            
        case 1:
            // ..
            cell.detailTextLabel?.text = nil
            
        case 2:
            // folder
            cell.detailTextLabel?.text = ">"
            
        case 3:
            // *.gpx
            cell.detailTextLabel?.text = "  " + (dirItems[row].size!/1000 + 1).description + "k"
            
        case 4:
            // other files
            cell.textLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.textColor = UIColor.lightGray
            cell.detailTextLabel?.text = "  " + (dirItems[row].size!/1000 + 1).description + "k"
            cell.isUserInteractionEnabled = false
            
        default:
            break
        }
        return cell
    }
    
    
    
    
    
    // выбор ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellText = (tableView.cellForRow(at: indexPath)?.textLabel?.text)!
        let row = (indexPath as NSIndexPath).row
        
        
        switch dirItems[row].priority {
            
        //  ..
        case 1:
            cloudDrive.movePathToParentDirectory()
            getFilesFoldersData()
            
            
        //   folder
        case 2:
            if cloudDrive.path == "/" {
                cloudDrive.path += cellText
            } else {
                cloudDrive.path = cloudDrive.path + "/" + cellText
            }
            getFilesFoldersData()
            
            
        //   .GPX
        case 3:
            var message = ""
            switch Archive.names.contains((tableView.cellForRow(at: indexPath)?.textLabel?.text)! ) {
            case true:
                message = "Трек с данным именем присутствует в архиве приложения. Перезаписать архив?"
            case false:
                message = "Загрузить в архив трек в архив трек: " + cellText + " ?"
            }
            
            let alertController = UIAlertController(title: "Внимание!", message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Да", style: .default)  { (_) in
                
                tableView.allowsSelection = false
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                self.backgroundQueue.async {
                    
                    var filePath: String
                    if cloudDrive.path.characters.last == "/" {
                        filePath = cloudDrive.path + cellText
                    } else {
                        filePath = cloudDrive.path + "/" + cellText
                    }

                    if let gpxFile = cloudDrive.downloadFile(filePath: filePath, size: self.dirItems[indexPath.row].size!) {
                        
                        Archive.saveTrack(forName: cellText, gpx: gpxFile)
                        self.showErrorMessage (forText: "Файл записан в архив")
                    } else {
                        
                        self.showErrorMessage (forText: "Ошибка при чтении, либо файл поврежден")
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        self.tableView.allowsSelection = true
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .default)  { (_) in
                tableView.deselectRow(at: indexPath, animated: false)
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
            
        default: return
        }
    }
    

    
    
    // показ сообщения об ошибке при работе с сетью
    func showErrorMessage (forText: String) {
        
        
        DispatchQueue.main.async {
            self.errorLabel.text = forText
            self.errorLabelTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.errorTimerTick), userInfo: nil, repeats: false)
            self.tableView.allowsSelection = true
            
            UIView.animate(withDuration: 0.3) {
                self.errorLabelTopConstraint.constant = -44
                self.view.layoutIfNeeded()
            }
        
        if self.tableView.indexPathForSelectedRow != nil {
            self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    
    func errorTimerTick () {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.errorLabelTopConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


