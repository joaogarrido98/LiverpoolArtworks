//
//  DetailViewController.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 25/11/2021.
//

import UIKit

class DetailViewController: UIViewController {
    //data gotten from
    var artwork : ArtworkModel?
    var image : String?
    var downloadedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(artwork?.ImagefileName != ""){
            image = artwork?.ImagefileName
        }
        getImage()
        
        //if values are not empty put it on the UI
        if(artwork?.locationNotes != nil) {
            locationLabel.text = artwork?.locationNotes
        }
        if(artwork?.artist != ""){
            artistLabel.text = "By " + artwork!.artist
        }
        if(artwork?.yearOfWork != ""){
            madeLabel.text = "Made in " + artwork!.yearOfWork
        }
        if(artwork?.Information != ""){
            textLabel.text = artwork!.Information
        }
        if(artwork?.title != ""){
            titleLabel.text = artwork!.title
        }
    }
    
    //qpi call to images url and get the image from the server
    private func getImage(){
        if(image != ""){
            //remove spaces from url and put %20 instead
            let transformedString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/" + (image?.replacingOccurrences(of: " ", with: "%20"))!
            if(transformedString != ""){
                if let url = URL(string: transformedString ){
                    let session = URLSession.shared
                    session.dataTask(with: url) { (data,response,err) in
                        guard let imageData = data else {
                            return
                        }
                        do {
                            //put imqge in the image view
                            DispatchQueue.main.async { [self] in
                                downloadedImage = UIImage(data: imageData)
                                imageLabel.image = downloadedImage
                            }
                        }
                    }.resume()
                }
            }
        }else{
            //if image is empty put a default image
            imageLabel.image = UIImage(imageLiteralResourceName: "default")
        }
    }
    
    @IBAction func imagedTapped(_ sender: Any) {
            let newImageView = UIImageView(image: downloadedImage)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var madeLabel: UILabel!
    @IBOutlet weak var textLabel: UITextView!
}
