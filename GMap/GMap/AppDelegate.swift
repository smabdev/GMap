//
//  AppDelegate.swift
//  GMap
//
//  Created by Alex on 10/06/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import GoogleMaps


let KEYS = (NSMutableDictionary.init(contentsOfFile: Bundle.main.path(forResource: "client_keys", ofType: "plist")!))!
let GM_KEY = KEYS["GM_KEY"] as! String
let CR_API_KEY = KEYS["CR_API_KEY"] as! String

// dropBox
let DB_CLIENT_ID = KEYS["DB_CLIENT_ID"] as! String
let DB_SECRET = KEYS["DB_SECRET"] as! String

// oneDrive (ключи их проекта example)
let OD_CLIENT_ID = KEYS["OD_CLIENT_ID"] as! String
let OD_SECRET = KEYS["OD_SECRET"] as! String
let OD_REDIRECT_URL = KEYS["OD_REDIRECT_URL"] as! String
let OD_STATE = KEYS["OD_STATE"] as! String

// googleDrive 
let GD_CLIENT_ID = KEYS["GD_CLIENT_ID"] as! String
let GD_SECRET = KEYS["GD_SECRET"] as! String
let GD_REDIRECT_URL = KEYS["GD_REDIRECT_URL"] as! String
let GD_STATE = KEYS["GD_STATE"] as! String


let BUNDLE = Bundle.main.bundleIdentifier!
let bundles = BUNDLE.components(separatedBy: ".")
let APP_NAME = bundles[bundles.count-1]
let DEFAULTS = UserDefaults.standard


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(GM_KEY)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // перехват авторизации googleDrive
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (sourceApplication == "com.apple.SafariViewService") {
            // Here we pass the response to the SDK which will automatically
            // complete the authentication process.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kCloseSafariViewControllerNotification"), object: url)
            return true
        }
        return true
    }


}

