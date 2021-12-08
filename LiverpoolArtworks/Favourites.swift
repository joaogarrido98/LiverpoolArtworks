//
//  Favourites.swift
//  LiverpoolArtworks
//
//  Created by Ilkin Samedzade on 08/12/2021.
//

import Foundation
import UIKit
import CoreData

class Favourites{
    //save title of the artwork the user favourites
    func saveToFavourites(title: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let toInsert = NSEntityDescription.insertNewObject(forEntityName: "UserFavourites", into: managedContext) as! UserFavourites
        toInsert.title = title
        do {
            //save the new core data inserted
            try managedContext.save()
        }catch _ as NSError{
            return
        }
    }
    
    //get all favourites from core data into string array
    func getFavourites() -> [String]{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let mContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFavourites")
        request.returnsObjectsAsFaults = false
        //clear existing favourites
        var favourites : [String] = []
        do{
            //fetch all the favourites stored in core data
            let results = try mContext.fetch(request) as? [UserFavourites]
            if(results!.count > 0){
                //add favourites to a class array so they can be used
                for element in results!{
                    favourites.append(element.title ?? "")
                }
            }
        }catch _ as NSError{
            return []
        }
        return favourites
    }
    
    //delete entry for a specific favourite artwork
    func deleteFavourite(title : String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //get the core data object where the title equals
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserFavourites")
        request.predicate = NSPredicate(format: "title == %@", title)
        let results = try? managedContext.fetch(request) as? [UserFavourites]
        if(results!.count > 0){
            for element in results!{
                //delete the object
                managedContext.delete(element)
            }
        }
        do{
            //save the changes
            try managedContext.save()
        }catch _ as NSError{
            return
        }
    }
}
