//
//  HomeScreenTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit

class HomeScreenTableViewController: UITableViewController {
    
    var album = [Roll]()
    var rollIndexPath: IndexPath?
    
    //used only for asking permisstion
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide unused cell
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.tableFooterView?.isHidden = true
        
        //setting up location manager
        if CLLocationManager.authorizationStatus() != .denied
            && CLLocationManager.authorizationStatus() != .restricted {
            
            //request authorization
            locationManager.requestWhenInUseAuthorization()
        }
        
        //load the album
        if let savedAlbum = Roll.loadAlbum() {
            album = savedAlbum
        }

        self.navigationItem.leftBarButtonItem = self.editButtonItem
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
    
    //reload data everytime unwinding to home
    @IBAction func unwindToHome(unwindSegue: UIStoryboardSegue) {
        if let savedAlbum = Roll.loadAlbum() {
            album = savedAlbum
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRollSegue" {
            let destination = segue.destination as! FrameEditingViewController
            //set the index path for usage
            destination.rollIndexPath = rollIndexPath
        }
        
    }
    

}
