//
//  ListViewController.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 30/11/2021.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    //data received from
    var data : [ArtworkModel] = []
    //class variables to store the images
    var images : [String : Data] = [:]
    let coreManager : CoreManager = CoreManager()
    var favourites : [String] = []
    
    //return the number of artworks in array in case there are non return 0
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artCell", for: indexPath)
        //put the data in the cells
        cell.textLabel?.text = data[indexPath.row].title
        cell.detailTextLabel?.text = data[indexPath.row].artist
        let title = data[indexPath.row].title
        if(images[title] != nil){
            cell.imageView?.image = UIImage(data: images[title]!)
        }
        //if it's favourite add heart icon to cell
        if(favourites.contains(title)){
            let image = UIImageView(image: UIImage(systemName: "heart.fill"))
            image.tintColor = UIColor.red
            cell.accessoryView = image
        }else{
            cell.accessoryView = nil
        }
        return cell
    }
    
    //add swiping gestures for adding/deleting from favourites
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //get specific artwork
        let artwork = data[indexPath.row]
        var isFavourite = false
        //check if its in favourites
        if(favourites.contains(artwork.title)){
            isFavourite = true
        }
        let shareAction = UIContextualAction(style: .normal, title: "Like") { (action, sourceView, completionHandler) in
            //if is a favourite delete it from favourites if not add to favourites
            if(isFavourite){
                self.coreManager.deleteFavourite(title: artwork.title)
            }else{
                self.coreManager.saveToFavourites(title: artwork.title)
            }
            //reload table and favourites
            self.favourites = self.coreManager.getFavourites()
            self.table.reloadData()
        }
        shareAction.backgroundColor = UIColor.orange
        //change type of heart according to if is favourite or not
        if(isFavourite){
            shareAction.image = UIImage(systemName: "heart.slash.fill")
        }else{
            shareAction.image = UIImage(systemName: "heart.fill")
        }
        //add the action to the swipez configuration
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [shareAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        return swipeConfiguration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the image frol the api for each artwork
        for art in data{
            getImage(path: art.thumbnail, title: art.title)
        }
        favourites = coreManager.getFavourites()
    }
    
    //download image from the api
    //put it on the array so it can be used in the table
    private func getImage(path: String, title: String) {
        if let url = URL(string: path){
            let session = URLSession.shared
            session.dataTask(with: url) { (data,response,err) in
                guard let imageData = data else { return }
                do {
                    //put image in a image dictionary and reload table
                    DispatchQueue.main.async { [self] in
                        images[title] = imageData
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
            //attribute the data to the variable in destination view
            destination.artwork = data[selectedRow]
        }
    }
    
    @IBOutlet weak var table: UITableView!
}
