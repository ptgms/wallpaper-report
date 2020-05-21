//
//  PreviewViewController.swift
//  wallreport
//
//  Created by ptgms on 16.05.20.
//  Copyright © 2020 ptgms. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var dummyTime: UILabel!
    @IBOutlet weak var dummyDate: UILabel!
    @IBOutlet weak var aspectSwitcher: UISegmentedControl!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var detailPanel: UIVisualEffectView!
    @IBOutlet weak var showDetButton: UIButton!
    @IBOutlet weak var showDetPanel: UIVisualEffectView!
    @IBOutlet weak var hideDetButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    var copyright = ""
    var imageurl = ""
    var faved = false
    var swipe = true
    var PanelState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImage(from: URL(string: GlobalVar.URL) ?? URL(string: "https://24.media.tumblr.com/tumblr_m3tqj6tpIj1r3u7ego1_500.png")!)
        creditLabel.text = GlobalVar.copyright
        self.tabBarController?.tabBar.isHidden = true
        if (GlobalVar.favs.contains(GlobalVar.URL)) {
            starButton.setImage(UIImage(named: "star_black_filled"), for: .normal)
            faved = true
        } else {
            starButton.setImage(UIImage(named: "star_black"), for: .normal)
            faved = false
        }
        detailPanel.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(upSwiped(_:)))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(downSwiped(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        creditLabel.text = "downloadstarted".localized
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.creditLabel.text = GlobalVar.copyright
                self?.backgroundImage.image = UIImage(data: data)
                if let pickedImage = self?.backgroundImage.image {
                    if (Int(pickedImage.brightness) >= 100) {
                        print("Bright")
                        self?.creditLabel.textColor = UIColor.black
                        self?.dummyTime.textColor = UIColor.black
                        self?.dummyDate.textColor = UIColor.black
                        self?.detailPanel.effect = UIBlurEffect(style: .light)
                        self?.showDetPanel.effect = UIBlurEffect(style: .light)
                        self?.aspectSwitcher.tintColor = UIColor.black
                    } else {
                        print("Dark")
                        self?.creditLabel.textColor = UIColor.white
                        self?.dummyTime.textColor = UIColor.white
                        self?.dummyDate.textColor = UIColor.white
                        self?.detailPanel.effect = UIBlurEffect(style: .dark)
                        self?.showDetPanel.effect = UIBlurEffect(style: .dark)
                        self?.aspectSwitcher.tintColor = UIColor.white
                    }
                }
            }
        }
    }

    @IBAction func switchedAspect(_ sender: Any) {
        switch aspectSwitcher.selectedSegmentIndex {
        case 0:
            backgroundImage.contentMode = .scaleAspectFill
            if let pickedImage = self.backgroundImage.image {
                if (Int(pickedImage.brightness) >= 100) {
                    print("Bright")
                    self.creditLabel.textColor = UIColor.black
                    self.dummyTime.textColor = UIColor.black
                    self.dummyDate.textColor = UIColor.black
                } else {
                    print("Dark")
                    self.creditLabel.textColor = UIColor.white
                    self.dummyTime.textColor = UIColor.white
                    self.dummyDate.textColor = UIColor.white
                }
            }
        case 1:
            backgroundImage.contentMode = .scaleAspectFit
            self.dummyTime.textColor = UIColor.blue
            self.dummyDate.textColor = UIColor.blue
        default:
            exit(-1)
        }
        print(aspectSwitcher.selectedSegmentIndex)
    }
    
    
    @IBAction func getButton(_ sender: Any) {
        if let pickedImage = backgroundImage.image {
            UIImageWriteToSavedPhotosAlbum(pickedImage, completed(), nil, nil)
        }
    }
    
    @objc func upSwiped(_ sender: Any) {
        print("Swiped up!")
        if (swipe == false) {
            return
        }
        if (self.PanelState == true) {
            return
        } else {
          self.ShowPanel()
        }
    }
    @objc func downSwiped(_ sender: Any) {
        print("Swiped down!")
        if (swipe == false) {
            return
        }
        if (self.PanelState == false) {
            return
        } else {
            self.hidePanel()
        }
    }
    
    @IBAction func favPressed(_ sender: Any) {
        if (faved==true) {
            if let index = GlobalVar.favs.index(of: GlobalVar.URL) {
                GlobalVar.favs.remove(at: index)
                GlobalVar.favsDate.remove(at: index)
                GlobalVar.favsAuthor.remove(at: index)
                faved = false
                starButton.setImage(UIImage(named: "star_black"), for: .normal)
                defaults.set(GlobalVar.favs, forKey: "favsURL")
                defaults.set(GlobalVar.favsDate, forKey: "favsDate")
                defaults.set(GlobalVar.favsAuthor, forKey: "favsAuthor")
            }
        } else {
            let date = Date()
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            GlobalVar.favs.insert(GlobalVar.URL, at: 0)
            GlobalVar.favsDate.insert(String(hour) + ":" + String(minutes), at: 0)
            GlobalVar.favsAuthor.insert(GlobalVar.copyrightNoText, at: 0)
            defaults.set(GlobalVar.favs, forKey: "favsURL")
            defaults.set(GlobalVar.favsDate, forKey: "favsDate")
            defaults.set(GlobalVar.favsAuthor, forKey: "favsAuthor")
            faved = true
            starButton.setImage(UIImage(named: "star_black_filled"), for: .normal)
        }
    }
    
    @IBAction func collapseDetails(_ sender: Any) {
        hidePanel()
    }
    
    @IBAction func showDetails(_ sender: Any) {
        ShowPanel()
    }
    
    func ShowPanel() {
        showDetButton.isEnabled = false
        swipe = false
        let xPosition = detailPanel.frame.origin.x
        let yPosition = detailPanel.frame.origin.y - 245
        let width = detailPanel.frame.size.width
        let height = detailPanel.frame.size.height
        
        self.detailPanel.isHidden = false
        
        UIView.animate(withDuration: 0.7, delay: 0.0, options: .curveEaseOut, animations: {
            self.detailPanel.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        }, completion: { [weak self] finished in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self?.showDetPanel.alpha = 0.0
                self?.PanelState = true
                self?.showDetButton.isEnabled = true
                self?.swipe = true
            })
        })
    }
    
    func hidePanel() {
        print(detailPanel.frame.origin.y)
        swipe = false
        hideDetButton.isEnabled = false
        let xPosition = detailPanel.frame.origin.x
        let yPosition = detailPanel.frame.origin.y + 245
        
        showDetPanel.isHidden = false
        showDetButton.isEnabled = false
        let width = detailPanel.frame.size.width
        let height = detailPanel.frame.size.height
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.detailPanel.frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        }, completion: { [weak self] finished in
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self?.showDetPanel.alpha = 1.0
                self?.hideDetButton.isEnabled = true
                self?.swipe = true
            })
            self?.showDetButton.isEnabled = true
            self?.PanelState = false
        })
    }
    
    @objc func completed() {
        let alert = UIAlertController(title: "completed".localized, message: "setaswall".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "opensettings".localized, style: .default, handler: { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }}))
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { action in
            return
            }))
        self.present(alert, animated: true, completion: nil)
    }
    

}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
