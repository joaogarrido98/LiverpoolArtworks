//
//  CoreDataController.swift
//  LiverpoolArtworks
//
//  Created by Garrido, Joao on 24/11/2021.
//

import Foundation
import CoreData

class CoreDataController{
    
    private init(){}
    
    class func getContext() -> NSManagedObjectContext {
        return CoreDataController.persistentContainer.viewContext
    }
    
    static var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Artwork")
        container.loadPersistentStores(completionHandler: {(arwtorkDescription, error) in
            if let error = error as NSError? {
                fatalError("iafwi")
            }
        })
        return container
    }()
    
    
}
