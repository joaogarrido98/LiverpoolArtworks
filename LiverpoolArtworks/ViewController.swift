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
    var locationManager = CLLocationManager()
    let defaults : Defaults = Defaults()
    var firstRun = true
    var startTrackingTheUser = false
    var coreArtwork : [ArtworkModel] = []
    var locationNames : Array<String> = []
    var allLocations : [String : Locations] = [:]
    var dataDictionary : [String : [ArtworkModel]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize location
        initLocation()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //initialize data from core data or api call
        initData(mContext: managedContext)
    }
    
    private func initLocation(){
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0]
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if(firstRun){
            firstRun = false
            let latDelta : CLLocationDegrees = 0.0025
            let lonDelta : CLLocationDegrees = 0.0025
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
            
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startUserTracking), userInfo: nil, repeats: false)
        }
        
        if(startTrackingTheUser){
            map.setCenter(location, animated: true)
        }
    }
    
    @objc func startUserTracking(){
        startTrackingTheUser = true
    }
    
    private func initData(mContext : NSManagedObjectContext){
        //fetch data from core data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Artwork")
        request.returnsObjectsAsFaults = false
        do{
            //if data is empty get all data from api call
            let results = try mContext.fetch(request) as? [Artwork]
            if(results == nil){
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
                self.getAllLocations()
                self.setDataDictionary()
                self.setAnnotations()
                self.table.reloadData()
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
        //if user doesnt have any data yet retrieve all data from api
        //else get data since the last date that is stored in the phone
        if (!hasData){
            stringifiedUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart"
        }else{
            //get last date where data was modified
            let date = defaults.getLastDate()
            stringifiedUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campusart&lastModified=\(date)"
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
                        self.getAllLocations()
                        self.setDataDictionary()
                        self.setAnnotations()
                        self.table.reloadData()
                    }
                } catch let jsonErr {
                    print("Error decoding json", jsonErr)
                }
            }.resume()
        }
    }
    
    private func getAllLocations(){
        for element in coreArtwork{
            if(!locationNames.contains(element.locationNotes)){
                locationNames.append(element.locationNotes)
            }
        }
        for location in locationNames {
            for element in coreArtwork{
                if(location == element.locationNotes){
                    let lat = Double(element.lat)
                    let lon = Double(element.long)
                    allLocations[location] = Locations(name: element.locationNotes, lat: lat, lon: lon)
                }
            }
        }
    }
    
    private func setDataDictionary(){
        dataDictionary = [:]
        var art = [ArtworkModel]()
        for location in locationNames {
                for element in coreArtwork {
                    if(location == element.locationNotes){
                        art.append(element)
                    }
                }
            dataDictionary[location] = art
        }
    }
    
    private func setAnnotations(){
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
    
    //prepare the segue with the data from core data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetail"){
            let destination = segue.destination as! DetailViewController
            let selectedRow = table.indexPathForSelectedRow!.row
            let data = coreArtwork[selectedRow]
            //attribute the data to the variables in destination view
            destination.titles = data.title
            destination.information = data.Information
            destination.artist = data.artist
            destination.locationNotes = data.locationNotes
            destination.yearOfWork = data.yearOfWork
            destination.image = data.ImagefileName
        }
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

