//
//  ViewController.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 24/11/2021.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Class Variables
    //Class variables
    let defaults : Defaults = Defaults()
    var locationManager = CLLocationManager()
    var coreArtwork : [ArtworkModel] = []
    var locationNames : Array<String> = []
    var allLocations : [String : Locations] = [:]
    var dataDictionary : [String : [ArtworkModel]] = [:]
    var chosen : [ArtworkModel]? = []
    var selected : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize location
        initLocation()
        
        //initialize data from core data or api call
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        initData(mContext: managedContext)
    }
    
    
    // MARK: - Data setup
    
    private func initData(mContext : NSManagedObjectContext){
        //fetch data from core data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artwork")
        request.returnsObjectsAsFaults = false
        do{
            //if data is empty get all data from api call
            let results = try mContext.fetch(request) as? [Artwork]
            if(results?.count == 0){
                getData(hasData: false)
            }else{
                //if data is not empty get the data from core data and transform it to the data model
                for elem in results!{
                    let art = ArtworkModel(
                        id: elem.id ?? "",
                        title: elem.title ?? "",
                        artist: elem.artist ?? "",
                        yearOfWork: elem.yearOfWork ?? "",
                        type: elem.type ?? "",
                        Information: elem.information ?? "",
                        lat: elem.lat ?? "",
                        long: elem.long ?? "",
                        location: elem.location ?? "",
                        locationNotes: elem.locationNotes ?? "",
                        ImagefileName: elem.imagefileName ?? "",
                        thumbnail: elem.thumbnail ?? "",
                        lastModified: elem.lastModified ?? "",
                        enabled: elem.enabled ?? "")
                    self.coreArtwork.append(art)
                }
                //get data since the last time it was updated
                self.getData(hasData: true)
            }
        }catch let error {
            print(error)
        }
    }
    
    //save data to persistent core data
    private func saveData(model: ArtworkModel){
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
        }catch let error as NSError{
            print(error)
        }
    }
    
    //get data from the api
    private func getData(hasData: Bool){
        var stringifiedUrl : String
        //get last date where data was modified
        let lastDate = defaults.getLastDate()
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        //if user doesnt have any data yet retrieve all data from api
        //else get data since the last date that is stored in the phone
        if (!hasData){
            stringifiedUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart"
        }else{
            stringifiedUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart&lastModified=\(lastDate)"
        }
        //fetch data from url
        if let url  = URL(string: stringifiedUrl) {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else{
                    return
                }
                do{
                    //transform json data to artwork object
                    let decoder = JSONDecoder()
                    let artworkList : Artworks = try decoder.decode(Artworks.self, from: jsonData)
                    DispatchQueue.main.async{
                        //for each element of the data received save to core data
                        for element in artworkList.campusart{
                            self.saveData(model: element)
                            //save the latest date
                            self.defaults.saveLastDate()
                            self.coreArtwork.append(element)
                        }
                        self.getAllBuildings()
                        self.setAnnotations()
                        self.setDataDictionary()
                        self.table.reloadData()
                    }
                } catch let jsonErr {
                    print("Error decoding json", jsonErr)
                }
            }.resume()
        }
    }
    
    //get all possible buildings and its coordinates
    private func getAllBuildings(){
        //create a list with all names of the locations
        for element in coreArtwork{
            if(!locationNames.contains(element.location) && element.enabled == String(1)){
                locationNames.append(element.location)
            }
        }
        //create a dictionary with the name and its coordinates
        for location in locationNames {
            for element in coreArtwork{
                if(location == element.location  && element.enabled == String(1)){
                    let lat = Double(element.lat)
                    let lon = Double(element.long)
                    allLocations[location] = Locations(name: element.location, lat: lat, lon: lon)
                }
            }
        }
    }
    
    //create a dictionary with all the data for each location
    private func setDataDictionary(){
        dataDictionary = [:]
        for location in locationNames {
            var art : [ArtworkModel] = []
            for element in coreArtwork {
                //if location is the same append artwork to artwork array
                if(location == element.location && element.enabled == String(1)){
                    art.append(element)
                }
            }
            //put art array to the specific location array
            dataDictionary[location] = art
        }
    }
    
    // MARK: - Map setup
    private func initLocation(){
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    //get the user location and put it on the map, keeps track of location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0018, longitudeDelta: 0.0018))
            self.map.setRegion(region, animated: true)
        }
    }
    
    //gets annotation clicked title and performs segue to list controller
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        //if is the user annotation do nothing
        if (view.annotation as? MKUserLocation) != nil{ return }
        //if location has more than 1 artwork than show list of artworks
        //else go straight to the detail about that artwork
        if((view.annotation?.title) != nil){
            chosen = dataDictionary[(view.annotation?.title)! ?? ""]
            if(chosen!.count > 1){
                performSegue(withIdentifier: "toList", sender: self)
            }else if(chosen!.count > 0){
                performSegue(withIdentifier: "toDetailFromAnnotation", sender: self)
            }
        }
    }
    
    //create the annotations on the map
    private func setAnnotations(){
        //put an annotation for each location
        for location in allLocations {
            guard let name = location.value.name else {return}
            guard let lat = location.value.lat else {return}
            guard let lon = location.value.lon else {return}
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = name
            self.map.addAnnotation(annotation)
        }
    }
    
    // MARK: - Segue
    
    //prepare the segue with the data from core data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetail"){
            let destination = segue.destination as! DetailViewController
            //attribute the data to the variable in destination view
            destination.artwork = coreArtwork[selected]
        }
        if(segue.identifier == "toList"){
            let destination = segue.destination as! ListViewController
            destination.data = chosen
        }
        if(segue.identifier == "toDetailFromAnnotation"){
            let destination = segue.destination as! DetailViewController
            if(chosen!.count > 0){
                destination.artwork = chosen![0]
            }
        }
    }
    
    //go back to this view on back button
    @IBAction func unwind( _ seg: UIStoryboardSegue) {}
    
    // MARK: - Table setup
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = indexPath.row
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locationNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "hello"
        return cell
    }
    
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var map: MKMapView!
}
