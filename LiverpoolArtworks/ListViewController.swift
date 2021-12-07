//
//  ListViewController.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 30/11/2021.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    //data received from
    var data : [ArtworkModel]?
    //class variables to store the images
    var images : Array<Data>? = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artCell", for: indexPath)
        cell.textLabel?.text = data?[indexPath.row].title
        cell.detailTextLabel?.text = data?[indexPath.row].artist
        if(data?[indexPath.row].thumbnail != nil){
            if(images != nil){
                if(images!.indices.contains(indexPath.row)){
                    cell.imageView?.image = UIImage(data: images![indexPath.row])
                }
            }
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the image frol the api for each artwork
        if(data != nil){
            for art in data!{
                getImage(path: art.thumbnail)
            }
        }
    }
    
    //download image from the api
    //put it on the array so it can be used in the table
    private func getImage(path: String) {
        if let url = URL(string: path){
            let session = URLSession.shared
            session.dataTask(with: url) { (data,response,err) in
                guard let imageData = data else { return }
                do {
                    //put imqge in the image view
                    DispatchQueue.main.async { [self] in
                        images?.append(imageData)
                        table.reloadData()
                    }
                }
            }.resume()
        }
    }
    
    //send data to the detail page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetailFromList"){
            let destination = segue.destination as! DetailViewController
            let selectedRow = table.indexPathForSelectedRow!.row
            if let data = data?[selectedRow] {
                //attribute the data to the variable in destination view
                destination.artwork = data
            }
        }
    }

    @IBOutlet weak var table: UITableView!
}
