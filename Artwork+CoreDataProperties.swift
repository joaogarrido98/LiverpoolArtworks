//
//  Artwork+CoreDataProperties.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 25/11/2021.
//
//

import Foundation
import CoreData


extension Artwork {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artwork> {
        return NSFetchRequest<Artwork>(entityName: "Artwork")
    }

    @NSManaged public var artist: String?
    @NSManaged public var enabled: String?
    @NSManaged public var id: String?
    @NSManaged public var imagefileName: String?
    @NSManaged public var information: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var lat: String?
    @NSManaged public var location: String?
    @NSManaged public var locationNotes: String?
    @NSManaged public var long: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var yearOfWork: String?

}

extension Artwork : Identifiable {

}
