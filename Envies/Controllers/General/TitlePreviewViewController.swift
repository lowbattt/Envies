//
//  TitlePreviewViewController.swift
//  Envies
//
//  Created by lowbatt on 7/11/2565 BE.
//

import UIKit
import WebKit
import FirebaseFirestore

class TitlePreviewViewController: UIViewController {
    var myFavourite: MyFavourite?
    let db = Firestore.firestore()
    
    private let titleLabel: UILabel = {
       
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "Harry potter"
        return label
    }()
    
    private let overviewLabel: UILabel = {
       
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "This is the best movie ever to watch as a kid!"
        return label
    }()
    
    private let favouriteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = #colorLiteral(red: 0.7042132616, green: 0.1341748238, blue: 0.1260605454, alpha: 1)
        button.setTitle("Add Favourite", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(favouritePressed(_:)), for: .touchUpInside)
        
        return button
    }()
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.971771419, green: 0.907574594, blue: 0.9130775332, alpha: 1)
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(favouriteButton)
        
        configureConstraints()
        
        readData()
    }
    
    @objc func favouritePressed(_ sender: UIButton) {
        guard let myFavourite = myFavourite else { return }
        
        if myFavourite.isFavourite {
            removeData()
        } else {
            writeData()
        }
    }
    
    private func readData() {
        guard let myFav = myFavourite else { return }
        let id = myFav.id
        let docRef = db.collection("Favourites").document("ID\(id)")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let id = data?["id"] as? Int ?? 0
                let mediaType = data?["media_type"] as? String ?? ""
                let originalName = data?["original_name"] as? String ?? ""
                let originalTitle = data?["original_title"] as? String ?? ""
                let posterPath = data?["poster_path"] as? String ?? ""
                let overview = data?["overview"] as? String ?? ""
                let voteCount = data?["vote_count"] as? Int ?? 0
                let releaseDate = data?["release_date"] as? String ?? ""
                let voteAverage = data?["vote_average"] as? Double ?? 0.0
                let isFavourite = data?["isFavourite"] as? Bool ?? false
                
                self.myFavourite = MyFavourite(id: id, mediaType: mediaType, originalName: originalName, originalTitle: originalTitle, posterPath: posterPath, overview: overview, voteCount: voteCount, releaseDate: releaseDate, voteAverage: voteAverage, isFavourite: isFavourite)
                self.favouriteButton.setTitle("Remove favourite", for: .normal)
            } else {
                print("Document does not exist")
                self.favouriteButton.setTitle("Add Favourite", for: .normal)
            }
        }
    }
    
    private func writeData() {
        guard let myFavourite = myFavourite else { return }
        let id = myFavourite.id
        let mediaType = myFavourite.mediaType ?? ""
        let originalName = myFavourite.originalName ?? ""
        let originalTitle = myFavourite.originalTitle ?? ""
        let posterPath = myFavourite.posterPath ?? ""
        let overview = myFavourite.overview ?? ""
        let voteCount = myFavourite.voteCount
        let releaseDate = myFavourite.releaseDate ?? ""
        let voteAverage = myFavourite.voteAverage
        let isFavourite = true
        
        let docData: [String: Any] = [
            "id": id,
            "media_type": mediaType,
            "original_name": originalName,
            "original_title": originalTitle,
            "poster_path": posterPath,
            "overview": overview,
            "vote_count": voteCount,
            "release_date": releaseDate,
            "vote_average": voteAverage,
            "isFavourite": isFavourite
        ]
        
        db.collection("Favourites").document("ID\(id)").setData(docData) { (err) in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                self.readData()
            }
        }
    }
    
    private func removeData() {
        guard let myFavourite = myFavourite else { return }
        let id = myFavourite.id
        
        db.collection("Favourites").document("ID\(id)").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                self.readData()
            }
        }
    }
    
    func configureConstraints() {
        let webViewConstraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300)
        ]
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ]
        
        let overviewLabelConstraints = [
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let favouriteButtonConstraints = [
            favouriteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            favouriteButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 25),
            favouriteButton.widthAnchor.constraint(equalToConstant: 200),
            favouriteButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(overviewLabelConstraints)
        NSLayoutConstraint.activate(favouriteButtonConstraints)
        
    }
    
    
    public func configure(with model: TitlePreviewViewModel) {
        titleLabel.text = model.title
        overviewLabel.text = model.titleOverview
        
        guard let url = URL(string: "https://www.youtube.com/embed/\(model.youtubeView.id.videoId)") else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }

}
