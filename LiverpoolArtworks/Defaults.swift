//
//  Defaults.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 25/11/2021.
//

import Foundation

//Custom clas to access UserDefaults
class Defaults{
    
    //save to user defaults the current date
    public func saveLastDate(){
        //get date and format it to the specific type of format of the api data
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        UserDefaults.standard.set(dateFormatter.string(from: date),forKey: "lastDate")
    
    }
    
    //retrieve the date from user defaults
    public func getLastDate() -> String {
        UserDefaults.standard.string(forKey: "lastDate") ?? ""
    }
}
