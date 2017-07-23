//
//  AddRollViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class AddRollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, RecentlyAddedTableViewControllerDelegate {
    
    var filteredArray = [String]()
    var selectedRoll: Roll?
    //decleard in order to pass it to the last view controller
    var selectedRollKey: String?
    
    let recentlyAddedController = RecentlyAddedTableViewController()
    
    @IBOutlet weak var filmSearchTable: UITableView!
    @IBOutlet weak var filmSearchBar: UISearchBar!
    @IBOutlet weak var questionLabel: UILabel!
    //Constraint to animate
    @IBOutlet weak var searchBarLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var zeroDistanceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmSearchTable.dataSource = recentlyAddedController
        filmSearchTable.delegate = recentlyAddedController
        //hideScopeBar
        self.filmSearchBar.showsScopeBar = false
        
        //Add self as the recent dataSource's delegate
        recentlyAddedController.delegate = self
        
        filmSearchBar.delegate = self
        //hide cancel button on searchBar
        filmSearchBar.showsCancelButton = false
        filmSearchBar.showsScopeBar = false
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
        let selectedCellView = filmSearchTable.cellForRow(at: indexPath)
        let predefinedRolls = Roll.predefinedRolls
        
        if let cellText = selectedCellView?.textLabel?.text {
            if cellText == "Not Listed?" {
                self.selectedRoll = nil
                performSegue(withIdentifier: "customRollSegue", sender: self)
                
            } else if predefinedRolls.keys.contains(cellText) {
                //set the selected roll key to pass
                selectedRollKey = cellText
                
                selectedRoll = predefinedRolls[cellText]!
                
                if predefinedRolls[cellText]?.format == 120 {
                    performSegue(withIdentifier: "customRollSegue", sender: self)
                } else {
                    performSegue(withIdentifier: "cameraSettingSegue", sender: self)
                }
            }
        }
        filmSearchTable.deselectRow(at: indexPath, animated: true)
    }
    
    //helper method to filter the roll
    func rollFilter(searchBar: UISearchBar, text: String) {
        
        if searchBar.selectedScopeButtonIndex == 0 {
            filteredArray = Roll.predefinedRolls.keys.filter({ (rollName) -> Bool in
                return rollName.lowercased().contains(text.lowercased())
                    && rollName.lowercased().contains("135")
            })
        } else {
            filteredArray = Roll.predefinedRolls.keys.filter({ (rollName) -> Bool in
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
        filmSearchTable.dataSource = self
        filmSearchTable.delegate = self
        filmSearchTable.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.searchBarLocationConstraint.constant = 0.0
            self.zeroDistanceConstraint.constant = 0.0
            self.tableBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
            self.filmSearchBar.showsCancelButton = true
            self.questionLabel.isHidden = true
            self.filmSearchBar.showsScopeBar = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filmSearchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {
            return
        }
        
        if text.isEmpty {
            //set the delegate to recentlyAddedController
            filmSearchTable.dataSource = recentlyAddedController
            filmSearchTable.delegate = recentlyAddedController
            //hide the scope bar if text is not empty
            filmSearchBar.showsScopeBar = false
        }
        
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
    
    //Protocol requirement to do segue for recently added rolls
    func performSegueWithInfo(roll: Roll, selectedRollKey: String) {
        self.selectedRoll = roll
        self.selectedRollKey = selectedRollKey
        if roll.format == 120 {
            performSegue(withIdentifier: "customRollSegue", sender: self)
        } else {
            performSegue(withIdentifier: "cameraSettingSegue", sender: self)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        reverseAnimation()
        
        if segue.identifier == "customRollSegue" {
            filmSearchBar.resignFirstResponder()
            let destination = segue.destination as! CustomRollViewController
            destination.selectedRollKey = selectedRollKey
            destination.customRoll = selectedRoll
        } else if segue.identifier == "cameraSettingSegue" {
            let destination = segue.destination as! CameraSettingViewController
            destination.selectedRollKey = selectedRollKey
            destination.roll = selectedRoll
        }
        
    }
    

}
