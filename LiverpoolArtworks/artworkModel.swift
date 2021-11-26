//
//  artworkModel.swift
//  LiverpoolArtworks
//
//  Created by Garrido, Joao on 24/11/2021.
//

import Foundation

//Model for the data that comes from the api 
struct ArtworkModel : Decodable {
    let id : String
    let title : String
    let artist : String
    let yearOfWork : String
    let type : String?
    let Information : String
    let lat : String
    let long : String
    let location : String
    let locationNotes : String
    let ImagefileName : String
    let thumbnail : String
    let lastModified : String
    let enabled : String
}

struct Artworks : Decodable {
    let campusart : [ArtworkModel]
}

