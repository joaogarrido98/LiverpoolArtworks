//
//  DetailViewController.swift
//  LiverpoolArtworks
//
//  Created by Joao Garrido on 25/11/2021.
//

import UIKit

class DetailViewController: UIViewController {
    //data gotten from
    var titles : String?
    var artist : String?
    var image : String?
    var yearOfWork : String?
    var information : String?
    var locationNotes : String?
    var downloadedImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImage()
        locationLabel.text = locationNotes
        if(artist != ""){
            artistLabel.text = "By " + artist!
        }
        if(yearOfWork != ""){
            madeLabel.text = "Made in " + yearOfWork!
        }
        textLabel.text = information
        titleLabel.text = titles
    }
    
    private func getImage(){
        if(image != ""){
            let transformedString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/" + (image?.replacingOccurrences(of: " ", with: "%20"))!
            if(transformedString != ""){
                if let url = URL(string: transformedString ){
                    let session = URLSession.shared
                    session.dataTask(with: url) { (data,response,err) in
                        guard let imageData = data else {
                            return
                        }
                        do {
                            DispatchQueue.main.async { [self] in
                                downloadedImage = UIImage(data: imageData)
                                imageLabel.image = downloadedImage
                            }
                        }
                    }.resume()
                }
            }
        }else{
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
