//
//  CloudDrive.swift
//  GMap
//
//  Created by Alex on 12.07.17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import Foundation
import CloudrailSI




class CloudDrive {
    

    struct DirItem {
        var fileName: String
        var size: Int?
        var isFolder: Int
        var priority: Int {
            get {
                if fileName == "root" {
                    return 0
                }
                if fileName == ".."  {
                    return 1
                }
                if isFolder == 1 {
                    return 2
                }
                if fileName.hasSuffix(".gpx") {
                    return 3
                } else {
                    return 4
                }
            }
        }
        
        var image: UIImage {
            get {
                switch priority {
                case 0:
                    return cloudDrive.getExtensionImage()
                case 1:
                    return UIImage()
                case 2:
                    return #imageLiteral(resourceName: "folder_extension")
                case 3:
                    return #imageLiteral(resourceName: "gpx_extension")
                case 4:
                    return #imageLiteral(resourceName: "file_extension")
                default:
                    return UIImage()
                }
            }
        }
        
        
        init () {
            self.fileName = ""
            self.size = 0
            self.isFolder = 0
        }
        
        init (fileName: String, size: Int?, isFolder: Int) {
            self.fileName = fileName
            self.size = size
            self.isFolder = isFolder
        }
    }   // end of struct DirItem

    

    // текущий путь для облачного хранилища
    var path = "/"
    // список папок и файлов данной папки
    var dirItems = Array(repeating: CloudDrive.DirItem(), count: 0)

    // откуда будет идти загрузка: dropBox, googleDrive, oneDrive
    var cloudStorage: CRCloudStorageProtocol?
    var storageType = ""
    


    func getExtensionImage () -> UIImage {
        switch storageType {
        case "dropBox" :
            return #imageLiteral(resourceName: "dropBox_extension")
        case "googleDrive" :
            return #imageLiteral(resourceName: "gogleDrive_extension")
        case "oneDrive" :
            return #imageLiteral(resourceName: "oneDrive_extension")
        default:
            return UIImage()
        }
    }
      

    
    
    // MARK: userLogin - Login User
    func setupService() {
        
        if CRCloudRail.appKey() == nil {
            CRCloudRail.setAppKey(CR_API_KEY)
        }
        
        switch cloudDrive.storageType {
        case "dropBox":
            let drive = CRDropbox(clientId: DB_CLIENT_ID, clientSecret: DB_SECRET)
            cloudStorage = drive!
            
        case "googleDrive":
            let drive = CRGoogleDrive(clientId: GD_CLIENT_ID, clientSecret: GD_SECRET, redirectUri: GD_REDIRECT_URL, state: GD_STATE)
            drive?.useAdvancedAuthentication()
            cloudStorage = drive!
            
        case "oneDrive":
            let drive = CROneDrive(clientId: OD_CLIENT_ID, clientSecret: OD_SECRET, redirectUri:  OD_REDIRECT_URL, state: OD_STATE)
            cloudStorage = drive!
            
        default: break
        }
        
        
        //Load Saved Service
        guard let result = UserDefaults.standard.value(forKey: cloudDrive.storageType) else {
            return
        }
        if !String(describing: result).isEmpty {
            cloudDrive.loadAsString(cloudStorage: cloudStorage!, savedState: result as! String)
        }
    }
    
    
    
    // извлечение данных папки
    func retriveFilesFoldersData(path: String) -> [DirItem] {
        
        self.dirItems = cloudDrive.childrenOfFolderWithPath(cloudStorage: self.cloudStorage!, path: path)!

        //Persistent data - Save Service
        let savedString = cloudDrive.saveAsString(cloudStorage: self.cloudStorage!)
        UserDefaults.standard.set(savedString, forKey: cloudDrive.storageType)
        return dirItems
 
    
    }
    

    // MARK: childrenOfFolderWithPath - Get Containts of Folder with Path
    func childrenOfFolderWithPath(cloudStorage: CRCloudStorageProtocol, path: String) -> [DirItem]? {
            let result = cloudStorage.childrenOfFolder(withPath: path)
            parsePathFolder (result: result)
            return dirItems
    }
    
    


    // сортировка папки по каталог-файл
    func parsePathFolder(result: NSMutableArray)  {
        
        var fileNames: [String] = []
        var isFolders: [Int] = []
        var sizes: [Int?] = []

        // пустая папка - 0 elevents
        // nil - может ли быть такое значение? ошибка при чтении?
        dirItems.removeAll()
        if result.count != 0 {
            
            fileNames = (result.mutableArrayValue(forKey: "name")) as NSArray as! [String]
            sizes = (result.mutableArrayValue(forKey: "size")) as NSArray as! [Int?]
            isFolders = (result.mutableArrayValue(forKey: "folder")) as NSArray as! [Int]
            
            for index in 0 ..< fileNames.count {
                let dirItem = (DirItem(fileName: fileNames[index], size: sizes[index], isFolder: isFolders[index]))
                dirItems.append(dirItem)
            }
            
            dirItems = dirItems.sorted {
                (item1, item2) -> Bool in
                return item1.priority < item2.priority
            }
        }
        
        if path == "/" {
            dirItems.insert(DirItem(fileName: "root", size: nil, isFolder: 1), at: 0)
        } else {
            dirItems.insert(DirItem(fileName: "..", size: nil, isFolder: 1), at: 0)
        }
    }
    
    
    
    
     func movePathToParentDirectory()  {

        let range = path.range(of: "/", options: .backwards, range: nil, locale: nil)
        path = path.substring(to: (range?.lowerBound)!)
        if path == "" {
            path = "/"
        }
     }
    
    

        // MARK: downloadFileWithPath - Download File with Path
    func downloadFile(filePath: String, size: Int) -> String? {
        
                let inputStream = cloudStorage?.downloadFile(withPath: filePath)
                var buffer = [UInt8](repeating: 0, count: size)
                inputStream?.open()
                inputStream?.read(&buffer, maxLength: buffer.count)
                inputStream?.close()
                
                let gpx = String(cString: buffer)
                if gpxIsCorrect(gpx: gpx) {
                    return gpx
                } else {
                    return nil
                }
        }
        
        
 
    // проверка файла на корректность GPX формату
    private func gpxIsCorrect (gpx: String) -> Bool {
        
        if gpx.contains("trkseg") && gpx.contains("trkpt") && gpx.contains("lat")  {
            
            var gpx2 = gpx.components(separatedBy: "trkseg")
            var dots = gpx2[1].components(separatedBy: "trkpt")
            var i = 0
            
            repeat {
                if dots[i].contains("lat") == false {
                    dots.remove(at: i)
                } else {
                    let coords = dots[i].components(separatedBy: "\"")
                    if Double(coords[1]) == nil || Double(coords[3]) == nil {
                        return false
                    }
                    i = i + 1
                }
            } while i < dots.count
            return true
        }
        return false
    }
    
    
    
    // MARK: createFolderWithPath - Create Folder with Path
     func createFolder(withPath: String) {
            cloudStorage?.createFolder (withPath: path)
    }
    
    
    
    // MARK: uploadFileToPath - Upload File to Path
    func saveFile(toPath: String, fileName: String, inputStream: InputStream, size: Int) -> Bool {
            cloudStorage?.uploadFile(toPath: toPath + fileName, with: inputStream, size: size, overwrite: true)
            return true
    }

    
    
    func saveAsString(cloudStorage: CRCloudStorageProtocol) -> String {
        return cloudStorage.saveAsString()
    }
    
    func loadAsString(cloudStorage: CRCloudStorageProtocol, savedState: String) {
        cloudStorage.load(as: savedState)
    }
    
    
    
    
    static let shared = CloudDrive()
    private init () { }
    
}

let cloudDrive = CloudDrive.shared


