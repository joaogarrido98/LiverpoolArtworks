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
    var coreArtwork : [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artwork")
        request.returnsObjectsAsFaults = false
        do{
            let results = try managedContext.fetch(request)
            if(results.count == 0){
                getData()
            }else{
            }
        }catch let error {
            print(error)
        }
    }
    
    func saveData(model: artwork){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Artwork", in: managedContext) else { return }
        let artwork = NSManagedObject(entity: entity, insertInto: managedContext)
        
        artwork.setValue(model.id, forKey: "id")
        artwork.setValue(model.title, forKey: "title")
        artwork.setValue(model.artist, forKey: "artist")
        artwork.setValue(model.yearOfWork, forKey: "yearOfWork")
        artwork.setValue(model.type, forKey: "type")
        artwork.setValue(model.Information, forKey: "information")
        artwork.setValue(model.lat, forKey: "lat")
        artwork.setValue(model.long, forKey: "long")
        artwork.setValue(model.location, forKey: "location")
        artwork.setValue(model.locationNotes, forKey: "locationNotes")
        artwork.setValue(model.ImagefileName, forKey: "imagefileName")
        artwork.setValue(model.thumbnail, forKey: "thumbnail")
        artwork.setValue(model.lastModified, forKey: "lastModified")
        artwork.setValue(model.enabled, forKey: "enabled")
                
        do{
            try managedContext.save()
            coreArtwork.append(artwork)
        }catch let error as NSError{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetail"){
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
    
    private func getData(){
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart"){
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else{
                    return
                }
                do{
                    let decoder = JSONDecoder()
                    let artworkList : artworks = try decoder.decode(artworks.self, from: jsonData)
                    DispatchQueue.main.async{
                        for element in artworkList.campusart{
                            self.saveData(model: element)
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

