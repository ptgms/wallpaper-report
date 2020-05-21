//
//  SettingsTableViewController.swift
//  wallreport
//
//  Created by ptgms on 21.05.20.
//  Copyright © 2020 ptgms. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var pixabayApiField: UITextField!
    @IBOutlet weak var nasaApiField: UITextField!
    @IBOutlet weak var picSumResField: UITextField!
    
    let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
    let build: String = Bundle.main.infoDictionary!["CFBundleVersion"]! as! String
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = "version".localized + version
        buildLabel.text = "build".localized + build
        
        if (GlobalVar.pixa_key != "") {
            pixabayApiField.text = GlobalVar.pixa_key
        }
        if (GlobalVar.nasa_key != "") {
            nasaApiField.text = GlobalVar.nasa_key
        }
        
        picSumResField.text = GlobalVar.picsumres1 + "x" + GlobalVar.picsumres2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            switch indexPath.row {
            case 0:
                if let url = URL(string: "https://pixabay.com/api/docs/") {
                    UIApplication.shared.open(url)
                }
            case 1:
                break
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                if let url = URL(string: "https://api.nasa.gov/") {
                    UIApplication.shared.open(url)
                }
            case 1:
                break
            default:
                break
            }
        case 3:
            break
        default:
            exit(-1)
        }
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func pixabaySavePressed(_ sender: Any) {
        if (pixabayApiField.text!.count != 34) {
            // API Key always is 34 chars long, if it's not it must be invalid.
            pixabayApiField.text = ""
            let alert = UIAlertController(title: "info".localized, message: "apisize1".localized + "34" + "apisize2".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            // test the key with a sample request
            var respondCode = 200
            let pixabayapi = URL(string: "https://pixabay.com/api/?key=" + pixabayApiField.text!)
            guard let requestUrl = pixabayapi else { fatalError() }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                    respondCode = response.statusCode
                    DispatchQueue.main.async {
                        if (respondCode == 200) {
                            self.defaults.set(self.pixabayApiField.text!, forKey: "pixa_key")
                            GlobalVar.pixa_key = self.pixabayApiField.text!
                            let alert = UIAlertController(title: "info".localized, message: "apivalid1".localized, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "info".localized, message: "apiinvalid".localized, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                                self.pixabayApiField.text = ""
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    @IBAction func nasaSavePressed(_ sender: Any) {
        if (nasaApiField.text!.count != 40) {
            nasaApiField.text = ""
            let alert = UIAlertController(title: "info".localized, message: "apisize1".localized + "40" + "apisize2".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            var respondCode = 200
            let nasaapi = URL(string: "https://api.nasa.gov/planetary/apod?api_key=" + nasaApiField.text!)
            guard let requestUrl = nasaapi else { fatalError() }
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                    respondCode = response.statusCode
                    DispatchQueue.main.async {
                        if (respondCode == 200) {
                            self.defaults.set(self.nasaApiField.text!, forKey: "nasa_key")
                            GlobalVar.nasa_key = self.nasaApiField.text!
                            let alert = UIAlertController(title: "info", message: "apivalid2".localized, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "info".localized, message: "apiinvalid".localized, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                                self.nasaApiField.text = ""
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            task.resume()

        }
    }
    
    @IBAction func picsumSavePressed(_ sender: Any) {
        if (picSumResField.text!.contains("x")) {
            let resarray = picSumResField.text!.components(separatedBy: "x")
            if (resarray.count != 2) {
                return
            } else {
                var returnURL = URL(string: "")
                let picsumURL = URL(string: "https://picsum.photos/" + resarray[0] + "/" + resarray[1])
                guard let requestUrl = picsumURL else { fatalError() }
                var request = URLRequest(url: requestUrl)
                request.httpMethod = "GET"
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let response = response as? HTTPURLResponse {
                        print("Response HTTP Status code: \(response.statusCode)")
                        returnURL = response.url
                        DispatchQueue.main.async {
                            if (returnURL != picsumURL) {
                                self.defaults.set(resarray[0], forKey: "picsumres1")
                                self.defaults.set(resarray[1], forKey: "picsumres2")
                                GlobalVar.picsumres1 = resarray[0]
                                GlobalVar.picsumres2 = resarray[1]
                                let alert = UIAlertController(title: "info".localized, message: "customsaved".localized, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                let alert = UIAlertController(title: "info".localized, message: "invalidres".localized, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                                    self.picSumResField.text = "1080x1920"
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                task.resume()
            }
        } else {
            let alert = UIAlertController(title: "info".localized, message: "usex".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
                self.picSumResField.text = "1080x1920"
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
