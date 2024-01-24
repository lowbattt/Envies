//
//  FavouriteViewController.swift
//  Envies
//
//  Created by lowbatt on 7/11/2565 BE.
//

import UIKit
import FirebaseFirestore
import JGProgressHUD

class FavouriteViewController: UIViewController {
    private var titles: [MyFavourite]? = []
    private let db = Firestore.firestore()
    lazy var hud = JGProgressHUD()
    
    private let favouriteTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.971771419, green: 0.907574594, blue: 0.9130775332, alpha: 1)
        title = "Favourite"
        view.addSubview(favouriteTable)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        favouriteTable.delegate = self
        favouriteTable.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        favouriteTable.frame = view.bounds
        favouriteTable.backgroundColor = #colorLiteral(red: 0.971771419, green: 0.907574594, blue: 0.9130775332, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readData()
    }
    
    private func readData() {
        showLoading()
        db.collection("Favourites").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.titles = documents.map({ (queryDocumentSnapshot) -> MyFavourite in
                    let data = queryDocumentSnapshot.data()
                    let id = data["id"] as? Int ?? 0
                    let mediaType = data["media_type"] as? String ?? ""
                    let originalName = data["original_name"] as? String ?? ""
                    let originalTitle = data["original_title"] as? String ?? ""
                    let posterPath = data["poster_path"] as? String ?? ""
                    let overview = data["overview"] as? String ?? ""
                    let voteCount = data["vote_count"] as? Int ?? 0
                    let releaseDate = data["release_date"] as? String ?? ""
                    let voteAverage = data["vote_average"] as? Double ?? 0.0
                    let isFavourite = data["isFavourite"] as? Bool ?? false
                    
                    return MyFavourite(id: id, mediaType: mediaType, originalName: originalName, originalTitle: originalTitle, posterPath: posterPath, overview: overview, voteCount: voteCount, releaseDate: releaseDate, voteAverage: voteAverage, isFavourite: isFavourite)
                })
            }
            self.favouriteTable.reloadData()
            self.hideLoading()
        }
    }
    
    private func showLoading() {
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
    }
    
    private func hideLoading() {
        hud.dismiss(animated: true)
    }
}

extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles?[indexPath.row]
        let originalName = title?.originalName ?? "Unknown title name"
        let originalTitle = title?.originalTitle ?? "Unknown title name"
        var titleName = ""
        
        if originalName == "" {
            titleName = originalTitle
        } else if originalTitle == "" {
            titleName = originalName
        }
        
        cell.configure(with: TitleViewModel(titleName: titleName, posterURL: title?.posterPath ?? ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles?[indexPath.row]
        let originalTitle = title?.originalTitle ?? ""
        let originalName = title?.originalName ?? ""
        var titleName = ""
        if originalTitle == "" {
            titleName = originalName
        } else {
            titleName = originalTitle
        }
        
        APICall.shared.getMovie(with: titleName + " trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    vc.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title?.overview ?? ""))
                    vc.myFavourite = self?.titles?[indexPath.row]
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
