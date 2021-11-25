//
//  Defaults.swift
//  LiverpoolArtworks
//
//  Created by Ilkin Samedzade on 25/11/2021.
//

import Foundation

class Defaults{
    
    public func saveLastDate(){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        UserDefaults.standard.set(dateFormatter.string(from: date),forKey: "lastDate")
    
    }
    
    public func getLastDate() -> String {
        UserDefaults.standard.string(forKey: "lastDate") ?? ""
    }
}
