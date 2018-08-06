//
//  AppDelegate.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Data controller for Core Data Stack
    var dataController = DataController(modelName: "Analog")
    var locationController = LocationController()
    var timer: Timer!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if UserDefaults.standard.value(forKey: "Updated") == nil {
            migrateOldData()
            UserDefaults.standard.set(true, forKey: "Updated")
        } else {
            //This will setup the stack after the app launch
            dataController.load()
        }
        
        //automatically save view context every 20 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: { (timer) in
            if self.dataController.viewContext.hasChanges {
                try? self.dataController.viewContext.save()
            }
        })
        
        let navigationController = window?.rootViewController as! UINavigationController
        
        let homeScreenTableViewController = navigationController.topViewController as! HomeScreenTableViewController
        
        //pass the data controller to home screen
        homeScreenTableViewController.dataController = dataController
        //singleton design for location manager and geocoder
        homeScreenTableViewController.locationController = locationController
        
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let current = navigationController?.visibleViewController as? FrameEditingViewController
        
        if let current = current {
            current.updateView(for: current.currentFrameIndex)
        }
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        //used to notify the user which frame they are in while unlocking
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let current = navigationController?.visibleViewController as? FrameEditingViewController

        current?.performIndexViewAnimation()
//
//        current?.locationManager.requestWhenInUseAuthorization()
//        current?.locationManager.startUpdatingLocation()
//
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    
    func saveViewContext() {
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
    }

    func migrateOldData() {
        let rowDeleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewRoll")
        let recentlyAddedDeleteFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentlyAddedRoll")
        
        let rowBatchDelete = NSBatchDeleteRequest(fetchRequest: rowDeleteFetchRequest)
        let recentlyAddedBatchDelete = NSBatchDeleteRequest(fetchRequest: recentlyAddedDeleteFetchRequest)
        
        dataController.load()
        
        let _ = try? dataController.viewContext.execute(rowBatchDelete)
        let _ = try? dataController.viewContext.execute(recentlyAddedBatchDelete)
        
        let migrator = DataMigrator(dataController: dataController)
        print(migrator.migrateRollsAndFrames())
        print(migrator.migrateRecentlyAdded())
        
    }

}

