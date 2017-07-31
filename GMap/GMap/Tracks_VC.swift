//
//  Tracks_VC.swift
//  GMap
//
//  Created by Alex on 15/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import CoreLocation
import CloudrailSI


class Tracks_VC:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tracksTableView: UITableView!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        Archive.refreshNames()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "cloudSourceIcon"), style: .plain, target: self, action:  #selector(selectSourceCloud))
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
        tracksTableView.reloadData()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // установка размера таблицы (строк)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Archive.names.count
    }
    
    // отрисовка таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as UITableViewCell
   //     cell.selectionStyle = .none
        cell.textLabel!.text = Archive.names[(indexPath as NSIndexPath).row]

        return cell
    }
    
    
    // выбор ячейки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // имя ключа для загрузки из user.defaults в виде BUNDLE-2017-10-10 10:10:10
        Archive.currentName = Archive.names[(indexPath as IndexPath).row]
        moveToPopoverVC (vcID: "changeCloudForLoad_VC")
        tracksTableView.deselectRow(at: indexPath, animated: true)
    }

    
    
    // удаление ячейки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            Archive.deleteTrack(forName: Archive.names[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .none)
        }
    }

    
    
    // вызов экрана с иконками облаков
    func selectSourceCloud() {
        moveToPopoverVC (vcID: "changeCloudForSave_VC")
        
    }
    
   
    func moveToPopoverVC (vcID: String) {
      
        let popoverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: vcID)
        
        self.addChildViewController(popoverVC)
        popoverVC.view.frame = self.view.frame
        self.view.addSubview(popoverVC.view)
        popoverVC.didMove(toParentViewController: self)

    }
    
 
}




