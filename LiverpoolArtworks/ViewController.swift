//
//  ViewController.swift
//  LiverpoolArtworks
//
//  Created by Garrido, Joao on 24/11/2021.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    var artworkArray : artwork? = nil
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var map: MKMapView!
}

