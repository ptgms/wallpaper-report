//
//  FavsTableViewController.swift
//  wallreport
//
//  Created by ptgms on 17.05.20.
//  Copyright © 2020 ptgms. All rights reserved.
//

import UIKit

class FavsTableViewController: UITableViewController {

    @IBOutlet var favTableView: UITableView!
    @IBOutlet weak var clearAllButton: UIButton!
    @IBOutlet weak var editModeButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        update()
        self.tabBarController?.tabBar.isHidden = false
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (GlobalVar.favs.count == 0) {
            clearAllButton.isHidden = true
            editModeButton.isHidden = true
            if(self.tableView.isEditing == true) {
                self.tableView.setEditing(false, animated: true)
                editModeButton.setTitle("edit", for: UIControl.State.normal)
            }
        } else {
            clearAllButton.isHidden = false
            editModeButton.isHidden = false
        }
        return GlobalVar.favs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for: indexPath)
        
        let url = GlobalVar.favs[indexPath.row]
        cell.textLabel?.text = "favat".localized + GlobalVar.favsDate[indexPath.row] + "madeby".localized + GlobalVar.favsAuthor[indexPath.row]
        cell.detailTextLabel?.text = url
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let preView = storyboard.instantiateViewController(withIdentifier: "PreviewView")
        GlobalVar.URL = GlobalVar.favs[indexPath.row]
        GlobalVar.copyright = GlobalVar.favsAuthor[indexPath.row]
        self.navigationController?.pushViewController(preView, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "delete".localized) { (action, indexPath) in
            GlobalVar.favs.remove(at: indexPath.row)
            GlobalVar.favsDate.remove(at: indexPath.row)
            GlobalVar.favsAuthor.remove(at: indexPath.row)
            self.defaults.set(GlobalVar.favs, forKey: "favsURL")
            self.defaults.set(GlobalVar.favsDate, forKey: "favsDate")
            self.defaults.set(GlobalVar.favsAuthor, forKey: "favsAuthor")
            self.update()
        }
        return [delete]
    }
    
    @IBAction func editModePressed(_ sender: Any) {
        if(self.tableView.isEditing == true) {
            self.tableView.setEditing(false, animated: true)
            editModeButton.setTitle("edit".localized, for: UIControl.State.normal)
        } else {
            self.tableView.setEditing(true, animated: true)
            editModeButton.setTitle("done".localized, for: UIControl.State.normal)
        }
        if ((GlobalVar.favs.count) == 0) {
            editModeButton.isHidden = true
        }
    }
    
    @IBAction func clearAllPressed(_ sender: Any) {
        GlobalVar.favs.removeAll(keepingCapacity: false)
        
        GlobalVar.favsDate.removeAll(keepingCapacity: false)
        GlobalVar.favsAuthor.removeAll(keepingCapacity: false)
        defaults.set(GlobalVar.favs, forKey: "favsURL")
        defaults.set(GlobalVar.favsDate, forKey: "favsDate")
        defaults.set(GlobalVar.favsAuthor, forKey: "favsAuthor")
        clearAllButton.isHidden = true
        editModeButton.isHidden = true
        update()
    }
    
    func update() {
        GlobalVar.favs = defaults.stringArray(forKey: "favsURL") ?? [String]()
        GlobalVar.favsDate = defaults.stringArray(forKey: "favsDate") ?? [String]()
        GlobalVar.favsAuthor = defaults.stringArray(forKey: "favsAuthor") ?? [String]()
        favTableView.reloadData()
    }
}
