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
    let coreManager : CoreManager = CoreManager()
    var locationManager = CLLocationManager()
    var coreArtwork : [ArtworkModel] = []
    var locationNames : Array<String> = []
    var allLocations : [String : Locations] = [:]
    var dataDictionary : [String : [ArtworkModel]] = [:]
    var chosen : [ArtworkModel]? = []
    var selectedRow : Int = -1
    var selectedSection : String = ""
    var favourites : [String] = []
    var images : [String : Data] = [:]
    
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        //initialize location
        initLocation()
        
        //get allFavourites
        favourites = coreManager.getFavourites()
        
        //initialize data from core data or api call
        initData()
    }
    
    //on view appear get new favourites and reload data in case any was updated on the detail page
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favourites = coreManager.getFavourites()
        table.reloadData()
    }
    
    // MARK: - Data setup
    private func initData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let mContext = appDelegate.persistentContainer.viewContext
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
                self.getAllBuildings()
                self.setAnnotations()
                self.setDataDictionary()
                self.getImages()
                //get data since the last time it was updated
                self.getData(hasData: true)
            }
        }catch let error {
            print(error)
        }
    }
    
    //download image from the api
    private func getImages() {
        for element in coreArtwork{
            if let url = URL(string: element.thumbnail){
                let session = URLSession.shared
                session.dataTask(with: url) { (data,response,err) in
                    guard let imageData = data else { return }
                    do {
                        DispatchQueue.main.async { [self] in
                            //add image to the dictionary
                            images[element.title] = imageData
                            table.reloadData()
                        }
                    }
                }.resume()
            }
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
            let date = defaults.getLastDate()
            //get last date where data was modified
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
                            self.checkForDuplicate(art: element)
                        }
                        self.defaults.saveLastDate()
                        self.getAllBuildings()
                        self.setAnnotations()
                        self.setDataDictionary()
                        self.getImages()
                    }
                } catch let jsonErr {
                    print("Error decoding json", jsonErr)
                }
            }.resume()
        }
    }
    
    //check is duplicate if yes delete and put the new one
    private func checkForDuplicate(art: ArtworkModel){
        for (index,artwork) in coreArtwork.enumerated() {
            //if artwork already exists we delete the old one and put new one
            if(artwork.title == art.title){
                self.coreManager.deleteArtwork(id: artwork.id)
                coreArtwork.remove(at: index)
            }
        }
        self.coreManager.saveData(model: art)
        self.coreArtwork.append(art)
        self.table.reloadData()
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
            //orderByDistance(location: location)
        }
    }
    
    //function that orders the table depending on the distance
    private func orderByDistance(location : CLLocation){
        var locations : [String] = []
        var distance : Double = 0.0
        print(allLocations)
        for loc in allLocations {
            guard let lat = loc.value.lat else { return }
            guard let long = loc.value.lon else { return }
            let coordinate = CLLocation(latitude: lat , longitude: long)
            let distanceInMeters = location.distance(from: coordinate)
            if(distanceInMeters < distance){
                locations.insert(loc.key, at: 0)
            }else{
                locations.append(loc.key)
            }
            distance = distanceInMeters
            print(locations)
        }
        locationNames = locations
        table.reloadData()
    }
    
    //gets annotation clicked title and performs segue to list controller
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //if is the user annotation do nothing
        if (view.annotation as? MKUserLocation) != nil{ return }
        //if location has more than 1 artwork than show list of artworks
        //else go straight to the detail about that artwork
        if((view.annotation?.title) != nil){
            mapView.deselectAnnotation(view.annotation, animated: true)
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
            destination.artwork = dataDictionary[selectedSection]?[selectedRow]
        }
        if(segue.identifier == "toList"){
            let destination = segue.destination as! ListViewController
            destination.data = chosen ?? []
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
        selectedRow = indexPath.row
        selectedSection = locationNames[indexPath.section]
        performSegue(withIdentifier: "toDetail", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return locationNames.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return locationNames[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = locationNames[section]
        return dataDictionary[sectionName]?.count ?? 0
    }
    
    //add swiping gestures for adding/deleting from favourites
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //get specific artwork
        let location = self.locationNames[indexPath.section]
        let artwork = self.dataDictionary[location]?[indexPath.row]
        var isFavourite = false
        //check if its in favourites
        if(favourites.contains(artwork!.title)){
            isFavourite = true
        }
        let shareAction = UIContextualAction(style: .normal, title: "Like") { (action, sourceView, completionHandler) in
            if(artwork?.title == nil){return}
            //if is a favourite delete it from favourites if not add to favourites
            if(isFavourite){
                self.coreManager.deleteFavourite(title: artwork!.title)
            }else{
                self.coreManager.saveToFavourites(title: artwork!.title)
            }
            //reload table and favourites
            self.favourites = self.coreManager.getFavourites()
            self.table.reloadData()
        }
        shareAction.backgroundColor = UIColor.orange
        if(isFavourite){
            shareAction.image = UIImage(systemName: "heart.slash.fill")
        }else{
            shareAction.image = UIImage(systemName: "heart.fill")
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [shareAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        //get the specific artwork and add the data to the cell
        let location = locationNames[indexPath.section]
        let artwork = dataDictionary[location]?[indexPath.row]
        cell.textLabel?.text = artwork?.title
        cell.detailTextLabel?.text = artwork?.artist
        //put image onto cell
        if(images[artwork!.title] != nil){
            cell.imageView?.image = UIImage(data: images[artwork!.title]!)
        }
        //check if its a user favourite if is show a heart else dont show anything
        if(favourites.contains(artwork!.title)){
            let image = UIImageView(image: UIImage(systemName: "heart.fill"))
            image.tintColor = UIColor.red
            cell.accessoryView = image
        }else{
            cell.accessoryView = nil
        }
        return cell
    }
    
    // MARK: - IBOUTLETS
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var map: MKMapView!
}
