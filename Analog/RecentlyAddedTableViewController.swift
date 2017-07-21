//
//  RecentlyAddedTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 21/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import UIKit

protocol RecentlyAddedTableViewControllerDelegate {
    func performSegueWithInfo(roll: Roll, selectedRollKey: String)
}

class RecentlyAddedTableViewController: UITableViewController {
    
    let recentlyAddedRolls = Roll.loadRecentlyAdded()
    var delegate: RecentlyAddedTableViewControllerDelegate?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mappedDict = recentlyAddedRolls?.map({ (key, value)  in key }) {
            return mappedDict.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        let mappedDict = recentlyAddedRolls?.map { (key, value)  in key }
        
        cell.textLabel?.text = mappedDict?[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recently Added"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let text = tableView.cellForRow(at: indexPath)?.textLabel?.text,
            let recentlyAddedRolls = recentlyAddedRolls else { return }
        if recentlyAddedRolls.keys.contains(text) {
            let selectedRoll = recentlyAddedRolls[text]!
            delegate?.performSegueWithInfo(roll: selectedRoll, selectedRollKey: text)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
