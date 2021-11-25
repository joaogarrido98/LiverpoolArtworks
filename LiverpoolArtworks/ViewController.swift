//
//  ViewController.swift
//  LiverpoolArtworks
//
//  Created by Garrido, Joao on 24/11/2021.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    var coreArtwork : [artwork] = []
    let defaults : Defaults = Defaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artwork")
        request.returnsObjectsAsFaults = false
        do{
            let results = try managedContext.fetch(request)
            if(results.count == 0){
                getData(hasData: false)
            }else{
                getData(hasData: true)
            }
        }catch let error {
            print(error)
        }
    }
    
    //save data to persistent core data
    func saveData(model: artwork){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
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
            try managedContext.save()
        }catch let error as NSError{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetail"){
            let destination = segue.destination as! DetailViewController
            let selectedRow = table.indexPathForSelectedRow!.row
            let data = coreArtwork[selectedRow]
            destination.titles = data.title
            destination.information = data.Information
            destination.artist = data.artist
            destination.locationNotes = data.locationNotes
            destination.yearOfWork = data.yearOfWork
            destination.image = data.ImagefileName
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 2){
            return "fuck"
        }else{
            return "me"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "hello"
        return cell
    }
    
    //get data from the api
    private func getData(hasData: Bool){
        var stringifiedUrl : String
        //if user doesnt have any date yet retrieve all data from api
        //else get data since the last date thats stored in the phone
        if (!hasData){
            stringifiedUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart"
        }else{
            let date = defaults.getLastDate()
            stringifiedUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart&lastModified=\(date)"
        }
        
        if let url  = URL(string: stringifiedUrl) {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else{
                    return
                }
                do{
                    let decoder = JSONDecoder()
                    let artworkList : artworks = try decoder.decode(artworks.self, from: jsonData)
                    DispatchQueue.main.async{
                        //for each element of the data received save to core data
                        for element in artworkList.campusart{
                            self.saveData(model: element)
                            //save the latest date
                            self.defaults.saveLastDate()
                        }
                    }
                } catch let jsonErr {
                    print("Error decoding json", jsonErr)
                }
            }.resume()
        }
    }

 
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var map: MKMapView!
}

