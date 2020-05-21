//
//  PixabayTableViewController.swift
//  wallreport
//
//  Created by ptgms on 20.05.20.
//  Copyright © 2020 ptgms. All rights reserved.
//

import UIKit
import Foundation

struct Pixabay: Codable {
    let total, totalHits: Int
    let hits: [Hit]
}

class PixabayTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var pixabayTable: UITableView!
    @IBOutlet weak var titleBar: UINavigationItem!
    
    
    var results = [Hit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.showsScopeBar = true
        searchBar.delegate = self
        
        update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PixaCell", for: indexPath) as! PixaBayCell
        
        cell.AuthorLabel?.text = results[indexPath.row].user
        cell.LinkLabel?.text = results[indexPath.row].largeImageURL
        getData(from: URL(string: results[indexPath.row].previewURL)!) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? URL(string: self.results[indexPath.row].previewURL)!.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                cell.imagePreView?.image = UIImage(data: data)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let preView = storyboard.instantiateViewController(withIdentifier: "PreviewView")
        GlobalVar.URL = results[indexPath.row].largeImageURL
        GlobalVar.copyright = "madeby2".localized + results[indexPath.row].user
        GlobalVar.copyrightNoText = results[indexPath.row].user
        self.navigationController?.pushViewController(preView, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print(searchBar.text!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!)
        let apicall = URL(string: "https://pixabay.com/api/?key=" + GlobalVar.pixa_key + "&q=" + searchBar.text!.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)! + "&image_type=photo&pretty=true")
        let task = URLSession.shared.pixabayTask(with: apicall!) { pixabay, response, error in
            do {
                if let pixabay = pixabay {
                    self.results = pixabay.hits
                    print(self.results.count)
                    DispatchQueue.main.async() { [weak self] in
                        self?.update()
                    }
                }
            }
        }
        task.resume()
    }

    func update() {
        pixabayTable.reloadData()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    

}

class PixaBayCell: UITableViewCell {
    
   
    @IBOutlet weak var imagePreView: UIImageView!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var LinkLabel: UILabel!
    
}

struct Hit: Codable {
    let id: Int
    let pageURL: String
    let type: TypeEnum
    let tags: String
    let previewURL: String
    let previewWidth, previewHeight: Int
    let webformatURL: String
    let webformatWidth, webformatHeight: Int
    let largeImageURL: String
    let imageWidth, imageHeight, imageSize, views: Int
    let downloads, favorites, likes, comments: Int
    let userID: Int
    let user: String
    let userImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, favorites, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}

extension Hit {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Hit.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        id: Int? = nil,
        pageURL: String? = nil,
        type: TypeEnum? = nil,
        tags: String? = nil,
        previewURL: String? = nil,
        previewWidth: Int? = nil,
        previewHeight: Int? = nil,
        webformatURL: String? = nil,
        webformatWidth: Int? = nil,
        webformatHeight: Int? = nil,
        largeImageURL: String? = nil,
        imageWidth: Int? = nil,
        imageHeight: Int? = nil,
        imageSize: Int? = nil,
        views: Int? = nil,
        downloads: Int? = nil,
        favorites: Int? = nil,
        likes: Int? = nil,
        comments: Int? = nil,
        userID: Int? = nil,
        user: String? = nil,
        userImageURL: String? = nil
        ) -> Hit {
        return Hit(
            id: id ?? self.id,
            pageURL: pageURL ?? self.pageURL,
            type: type ?? self.type,
            tags: tags ?? self.tags,
            previewURL: previewURL ?? self.previewURL,
            previewWidth: previewWidth ?? self.previewWidth,
            previewHeight: previewHeight ?? self.previewHeight,
            webformatURL: webformatURL ?? self.webformatURL,
            webformatWidth: webformatWidth ?? self.webformatWidth,
            webformatHeight: webformatHeight ?? self.webformatHeight,
            largeImageURL: largeImageURL ?? self.largeImageURL,
            imageWidth: imageWidth ?? self.imageWidth,
            imageHeight: imageHeight ?? self.imageHeight,
            imageSize: imageSize ?? self.imageSize,
            views: views ?? self.views,
            downloads: downloads ?? self.downloads,
            favorites: favorites ?? self.favorites,
            likes: likes ?? self.likes,
            comments: comments ?? self.comments,
            userID: userID ?? self.userID,
            user: user ?? self.user,
            userImageURL: userImageURL ?? self.userImageURL
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum TypeEnum: String, Codable {
    case photo = "photo"
}

extension Pixabay {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Pixabay.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        total: Int? = nil,
        totalHits: Int? = nil,
        hits: [Hit]? = nil
        ) -> Pixabay {
        return Pixabay(
            total: total ?? self.total,
            totalHits: totalHits ?? self.totalHits,
            hits: hits ?? self.hits
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
