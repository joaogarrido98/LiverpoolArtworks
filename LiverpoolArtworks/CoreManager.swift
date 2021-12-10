//
//  Favourites.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 08/12/2021.
//

import Foundation
import UIKit
import CoreData

class CoreManager{
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
    func getFavourites() -> [String] {
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
                    if(element.title != nil){
                        favourites.append(element.title!)
                    }
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
    
    //save data to persistent core data
    func saveData(model: ArtworkModel){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //insert new object into core data from the model gotten from the api
        let toInsert = NSEntityDescription.insertNewObject(forEntityName: "Artwork", into: managedContext) as! Artwork
        toInsert.artist = model.artist
        toInsert.title = model.title
        toInsert.id = model.id
        toInsert.yearOfWork = model.yearOfWork
        toInsert.type = model.type
        toInsert.information = model.Information
        toInsert.lat = model.lat
        toInsert.long = model.long
        toInsert.location = model.location
        toInsert.locationNotes = model.locationNotes
        toInsert.imagefileName = model.ImagefileName
        toInsert.thumbnail = model.thumbnail
        toInsert.lastModified = model.lastModified
        toInsert.enabled = model.enabled
        do{
            //save the data
            try managedContext.save()
        }catch _ as NSError{
            return
        }
    }
    
    func deleteArtwork(id: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //get the core data object where the title equals
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artwork")
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? managedContext.fetch(request) as? [Artwork]
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
