//
//  DetailViewController.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 25/11/2021.
//

import UIKit

class DetailViewController: UIViewController {
    //data gotten from the segue
    var artwork : ArtworkModel?
    //class variables
    var downloadedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if values are not nil put it on the UI
        if(artwork?.locationNotes != nil) {
            locationLabel.text = artwork!.locationNotes
        }
        
        if(artwork?.artist != nil){
            artistLabel.text = "By " + artwork!.artist
        }
        
        if(artwork?.yearOfWork != nil){
            madeLabel.text = "Made in " + artwork!.yearOfWork
        }
        
        if(artwork?.Information != nil){
            textLabel.text = artwork!.Information
        }
        
        if(artwork?.title != nil){
            titleLabel.text = artwork!.title
        }
        
        if(artwork?.ImagefileName != nil){
            getImage(image: artwork!.ImagefileName)
        }else{
            //if image is empty put a default image
            imageLabel.image = UIImage(imageLiteralResourceName: "default")
        }
    }
    
    //api call to images url and get the image from the server
    private func getImage(image: String){
        //remove spaces from url and put %20 instead
        let transformedString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/" + (image.replacingOccurrences(of: " ", with: "%20"))
        if(transformedString != ""){
            if let url = URL(string: transformedString ){
                let session = URLSession.shared
                session.dataTask(with: url) { (data,response,err) in
                    guard let imageData = data else { return }
                    do {
                        //put image in the image view
                        DispatchQueue.main.async { [self] in
                            downloadedImage = UIImage(data: imageData)
                            imageLabel.image = downloadedImage
                        }
                    }
                }.resume()
            }
        }
    }
    
    //on image tap a new view appears with image on full size
    @IBAction func imagedTapped(_ sender: Any) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        let largeView = UIImageView(image: downloadedImage)
        largeView.frame = UIScreen.main.bounds
        largeView.backgroundColor = .black
        largeView.contentMode = .scaleAspectFit
        largeView.isUserInteractionEnabled = true
        largeView.addGestureRecognizer(tap)
        //animation for showing image
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(largeView) }, completion: nil)
    }
    
    //dismiss the image view created previous
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
