//
//  DataController.swift
//  Analog
//
//  Created by Zizhou Wang on 2018/7/6.
//  Copyright © 2018 Zizhou Wang. All rights reserved.
//

import Foundation
import CoreData


class DataController {
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load() {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            
            self.autoSaveViewContext()
        }
    }
}

extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 20) {
        print("autosaving")
        guard interval > 0 else {
            print("Time interval is negative")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
