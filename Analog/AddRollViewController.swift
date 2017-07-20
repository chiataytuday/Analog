//
//  AddRollViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class AddRollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //data for pre-defined rolls
    let predefinedRolls: [String : Roll] = [
        
        "Kodak Portra 400 (135)" : Roll(filmName: "Kodak Portra 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 400 (120)" : Roll(filmName: "Kodak Portra 400", format: 120, frameCount: nil, iso: 400),
        "Kodak Ektar 100 (135)" : Roll(filmName: "Kodak Ektar 100", format: 135, frameCount: 36, iso: 100),
        "Ilford HP5 Plus (135)" : Roll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 36, iso: 400),
        "Kodak Tri-X 400 (135)" : Roll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 36, iso: 400),
        "Ilford HP5 Plus (120)" : Roll(filmName: "Ilford HP5 Plus", format: 120, frameCount: nil, iso: 400),
        "Kodak Tri-X 400 (120)" : Roll(filmName: "Kodak Tri-X 400", format: 120, frameCount: nil, iso: 400),
        "Kodak Portra 160 (120)" : Roll(filmName: "Kodak Portra 160", format: 120, frameCount: nil, iso: 160),
        "Kodak T-Max 400 (135)" : Roll(filmName: "Kodak T-Max 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 800 (135)" : Roll(filmName: "Kodak Portra 800", format: 135, frameCount: 36, iso: 800),
        "Kodak Ektar 100 (120)" : Roll(filmName: "Kodak Ektar 100", format: 120, frameCount: nil, iso: 100),
        "Fuji Pro 400H (120)" : Roll(filmName: "Fuji Pro 400H", format: 120, frameCount: nil, iso: 400),
        "Kodak Portra 160 (135)" : Roll(filmName: "Kodak Portra 160", format: 135, frameCount: 36, iso: 160),
        "Fuji Neopan 100 (120)" : Roll(filmName: "Fuji Neopan 100", format: 120, frameCount: nil, iso: 100),
        "Ilford Delta 3200 (135)" : Roll(filmName: "Ilford Delta 3200", format: 135, frameCount: 36, iso: 3200),
        "Kodak UltraMax 400 (135, 36exp.)" : Roll(filmName: "Kodak UltraMax 400", format: 135, frameCount: 36, iso: 400),
        "Ilford Delta 3200 (120)" : Roll(filmName: "Ilford Delta 3200", format: 120, frameCount: nil, iso: 3200),
        "Fuji Provia 100F (135)" : Roll(filmName: "Fuji Provia 100F", format: 135, frameCount: 36, iso: 100),
        "Fuji Pro 400H (135)" : Roll(filmName: "Fuji Pro 400H", format: 135, frameCount: 36, iso: 400),
        "Ilford Delta 100 (120)" : Roll(filmName: "Ilford Delta 100", format: 120, frameCount: nil, iso: 100),
        "Fuji Neopan 100 (135)" : Roll(filmName: "Fuji Neopan 100", format: 135, frameCount: nil, iso: 100),
        "Agfa Vista Plus 200 (135)" : Roll(filmName: "Agfa Vista Plus 200", format: 135, frameCount: 36, iso: 200),
        "Kodak T-Max 100 (135)" : Roll(filmName: "Kodak T-Max 100", format: 135, frameCount: 36, iso: 100),
        "Kodak UltraMax 400 (135, 24exp.)" : Roll(filmName: "Kodak UltraMax 400", format: 135, frameCount: 24, iso: 400),
        "Ilford FP4 Plus (120)" :Roll (filmName: "Ilford FP4 Plus", format: 120, frameCount: nil, iso: 125),
        "Kodak T-Max 400 (120)" : Roll(filmName: "Kodak T-Max 400", format: 120, frameCount: nil, iso: 400)
    
    
    ]
    
    
    
    var filteredArray = [String]()
    var selectedRoll: Roll?
    
    @IBOutlet weak var filmSearchTable: UITableView!
    @IBOutlet weak var filmSearchBar: UISearchBar!
    @IBOutlet weak var questionLabel: UILabel!
    //Constraint to animate
    @IBOutlet weak var searchBarLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var zeroDistanceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmSearchTable.dataSource = self
        filmSearchTable.delegate = self
        filmSearchBar.delegate = self
        //hide cancel button on searchBar
        filmSearchBar.showsCancelButton = false
        //register for keyboard notification
        filmSearchTable.registerForKeyboardNotifications()
        
        self.navigationController?.navigationBar.tintColor = .black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table view data source requied method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        
        cell.textLabel?.text = filteredArray[indexPath.row]
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = filmSearchTable.cellForRow(at: indexPath)
        
        if let cellText = selectedCell?.textLabel?.text {
            if cellText == "Not Listed?" {
                self.selectedRoll = nil
                performSegue(withIdentifier: "customRollSegue", sender: self)
                
            } else if predefinedRolls.keys.contains(cellText) {
                let roll = predefinedRolls[cellText]!
                
                if predefinedRolls[cellText]?.format == 120 {
                    self.selectedRoll = roll
                    performSegue(withIdentifier: "customRollSegue", sender: self)
                } else {
                    self.selectedRoll = roll
                    performSegue(withIdentifier: "cameraSettingSegue", sender: self)
                }
            }
        }
        filmSearchTable.deselectRow(at: indexPath, animated: true)
    }
    
    //helper method to filter the roll
    func rollFilter(searchBar: UISearchBar, text: String) {
        
        if searchBar.selectedScopeButtonIndex == 0 {
            filteredArray = predefinedRolls.keys.filter({ (rollName) -> Bool in
                return rollName.lowercased().contains(text.lowercased())
                    && rollName.lowercased().contains("135")
            })
        } else {
            filteredArray = predefinedRolls.keys.filter({ (rollName) -> Bool in
                return rollName.lowercased().contains(text.lowercased())
                    && rollName.lowercased().contains("120")
            })
        }
        
        if let searchText = searchBar.text {
            if !searchText.isEmpty && !filteredArray.contains("Not Listed?") {
                filteredArray.append("Not Listed?")
            }
        }
        
        filmSearchTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        rollFilter(searchBar: searchBar, text: searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let text = searchBar.text {
            rollFilter(searchBar: searchBar, text: text)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        UIView.animate(withDuration: 0.3) {
            self.searchBarLocationConstraint.constant = 0.0
            self.zeroDistanceConstraint.constant = 0.0
            self.tableBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            self.filmSearchBar.showsCancelButton = true
            self.questionLabel.isHidden = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reverseAnimation()
    }
    
    func reverseAnimation() {
        //resign first responser
        self.filmSearchBar.resignFirstResponder()
        
        UIView.animate(withDuration: 0.3) {
            self.searchBarLocationConstraint.constant = 163.0
            self.zeroDistanceConstraint.constant = 0.0
            self.tableBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            self.filmSearchBar.showsCancelButton = false
            self.questionLabel.isHidden = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        reverseAnimation()
        
        if segue.identifier == "customRollSegue" {
            filmSearchBar.resignFirstResponder()
            let destination = segue.destination as! CustomRollViewController
            destination.customRoll = selectedRoll
        } else if segue.identifier == "cameraSettingSegue" {
            let destination = segue.destination as! CameraSettingViewController
            destination.roll = selectedRoll
        }
        
    }
    

}
