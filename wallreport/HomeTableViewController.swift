//
//  HomeTableViewController.swift
//  wallreport
//
//  Created by ptgms on 17.05.20.
//  Copyright © 2020 ptgms. All rights reserved.
//

import UIKit
import Foundation


// Set NASA structure to decode JSON later
struct Nasa: Codable {
    let copyright, date, explanation: String
    let hdurl: String
    let mediaType, serviceVersion, title: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case copyright, date, explanation, hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title, url
    }
}



class HomeTableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        // Load settings if set
        GlobalVar.pixa_key = defaults.string(forKey: "pixa_key") ?? ""
        GlobalVar.nasa_key = defaults.string(forKey: "nasa_key") ?? ""
        
        GlobalVar.picsumres1 = defaults.string(forKey: "picsumres1") ?? "1080"
        GlobalVar.picsumres2 = defaults.string(forKey: "picsumres2") ?? "1920"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let preView = storyboard.instantiateViewController(withIdentifier: "PreviewView")
        if (indexPath.section == 0) {
            switch indexPath.row {
            case 0:
                print("NASA pressed")
                if (GlobalVar.nasa_key == "") {
                    let alert = UIAlertController(title: "info".localized, message: "notset".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                let apicall = URL(string: "https://api.nasa.gov/planetary/apod?api_key=" + GlobalVar.nasa_key)
                let task = URLSession.shared.nasaTask(with: apicall!) { nasa, response, error in
                    do {
                        if let nasa = nasa {
                            print(nasa.hdurl)
                            print(nasa.copyright)
                            GlobalVar.copyright = "madeby2".localized + nasa.copyright
                            GlobalVar.copyrightNoText = nasa.copyright
                            GlobalVar.URL = nasa.hdurl
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(preView, animated: true)
                            }
                        }
                    }
                }
                task.resume()
            case 1:
                print("picsum pressed")
                let picsumapi = URL(string: "https://picsum.photos/" + GlobalVar.picsumres1 + "/" + GlobalVar.picsumres2)
                GlobalVar.copyright = "Picsum"
                GlobalVar.copyrightNoText = "Picsum"
                guard let requestUrl = picsumapi else { fatalError() }
                var request = URLRequest(url: requestUrl)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                        GlobalVar.URL = (response.url?.absoluteString)!
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(preView, animated: true)
                        }
                    }
                }
                task.resume()
            case 2:
                print("Cat pressed")
                let catapi = URL(string: "http://thecatapi.com/api/images/get?format=src&type=png")
                GlobalVar.copyright = "The Cat API"
                GlobalVar.copyrightNoText = "The Cat API"
                guard let requestUrl = catapi else { fatalError() }
                var request = URLRequest(url: requestUrl)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                        GlobalVar.URL = (response.url?.absoluteString)!
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(preView, animated: true)
                        }
                    }
                }
                task.resume()
            case 3:
                print("Dog pressed")
                let dogapi = URL(string: "https://api.thedogapi.com/v1/images/search?format=src&mime_types=image/png")
                GlobalVar.copyright = "The Dog API"
                GlobalVar.copyrightNoText = "The Dog API"
                guard let requestUrl = dogapi else { fatalError() }
                var request = URLRequest(url: requestUrl)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error took place \(error)")
                        return
                    }
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                        GlobalVar.URL = (response.url?.absoluteString)!
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(preView, animated: true)
                        }
                    }
                }
                task.resume()
            case 4:
                if (GlobalVar.pixa_key == "") {
                    let alert = UIAlertController(title: "info".localized, message: "notset".localized, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let pixaView = storyboard.instantiateViewController(withIdentifier: "pixaView")
                    self.navigationController?.pushViewController(pixaView, animated: true)
                }
            case 5:
                print("User pressed")
                let alert = UIAlertController(title: "notyet".localized, message: "pleasebepatient".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized, style: .destructive, handler: { action in
                    return
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                exit(-1)
            }
            if let indexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        
    }
    
}



struct GlobalVar {
    static var URL = ""
    static var copyright = ""
    static var favs = [String]()
    static var favsDate = [String]()
    static var favsAuthor = [String]()
    static var copyrightNoText = ""
    
    static var pixa_key = ""
    static var nasa_key = ""
    
    static var picsumres1 = ""
    static var picsumres2 = ""
}

extension Nasa {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Nasa.self, from: data)
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
        copyright: String? = nil,
        date: String? = nil,
        explanation: String? = nil,
        hdurl: String? = nil,
        mediaType: String? = nil,
        serviceVersion: String? = nil,
        title: String? = nil,
        url: String? = nil
        ) -> Nasa {
        return Nasa(
            copyright: copyright ?? self.copyright,
            date: date ?? self.date,
            explanation: explanation ?? self.explanation,
            hdurl: hdurl ?? self.hdurl,
            mediaType: mediaType ?? self.mediaType,
            serviceVersion: serviceVersion ?? self.serviceVersion,
            title: title ?? self.title,
            url: url ?? self.url
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
    
    func nasaTask(with url: URL, completionHandler: @escaping (Nasa?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
    func pixabayTask(with url: URL, completionHandler: @escaping (Pixabay?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension CGImage {
    var brightness: Double {
        get {
            let imageData = self.dataProvider?.data
            let ptr = CFDataGetBytePtr(imageData)
            var x = 0
            var result: Double = 0
            for _ in 0..<self.height {
                for _ in 0..<self.width {
                    let r = ptr![0]
                    let g = ptr![1]
                    let b = ptr![2]
                    result += (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                    x += 1
                }
            }
            let bright = result / Double (x)
            return bright
        }
    }
}
extension UIImage {
    var brightness: Double {
        get {
            return (self.cgImage?.brightness)!
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
