//
//  HomeScreenTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class HomeScreenTableViewController: UITableViewController {
    
    var album = [Roll]()
    var rollIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide unused cell
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.tableFooterView?.isHidden = true
        
        
        //load the album
        if let savedAlbum = Roll.loadAlbum() {
            album = savedAlbum
        }

        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //reload album from file
        if let savedAlbum = Roll.loadAlbum() {
            album = savedAlbum
        }
        
        if album.isEmpty {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            
            let notifGroup = DispatchGroup()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                notifGroup.enter()
                self.navigationItem.prompt = "Tap ➕ to add a roll"
                notifGroup.leave()
            })
            //wait for the first to complete
            notifGroup.wait()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.navigationItem.prompt = nil
            })
            
            
        } else {
            //reload table
            tableView.reloadData()
            
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //table view delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return album.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rollCell", for: indexPath) as! HomeTableViewCell
        let roll = album[indexPath.row]
        
        cell.update(with: roll)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //prepare for the destination's index path
        rollIndexPath = indexPath
        
        performSegue(withIdentifier: "showRollSegue", sender: self)
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //present an alert to notify the user before delete
            let alertController = UIAlertController(title: "Delete Roll", message: "All data in this roll will be lost", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                Roll.deleteRoll(at: indexPath)
                if let albumLoaded = Roll.loadAlbum() {
                    self.album = albumLoaded
                    
                    if self.album.isEmpty {
                        self.setEditing(false, animated: true)
                        self.navigationItem.leftBarButtonItem?.isEnabled = false
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.beginUpdates()
                tableView.endUpdates()
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    
    // MARK: - Navigation
    
    @IBAction func unwindToHome(unwindSegue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRollSegue" {
            let destination = segue.destination as! FrameEditingViewController
            //set the index path for usage
            destination.rollIndexPath = rollIndexPath
        }
        
    }
    

}
