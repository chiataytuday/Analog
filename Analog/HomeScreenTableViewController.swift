//
//  HomeScreenTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import CoreData

class HomeScreenTableViewController: UITableViewController {
    
//    var album = [Roll]()
//    var rollIndexPath: IndexPath?

    var dataController: DataController!
    
    var fetchedResultsController: NSFetchedResultsController<NewRoll>!
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<NewRoll> = NewRoll.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "album")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Home screen rolls can't be fetched")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //Hide unused cell
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        tableView.tableFooterView?.isHidden = true
        
        
        if fetchedResultsController.sections == nil || fetchedResultsController.sections?[0].numberOfObjects == 0 {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
//            //let notifGroup = DispatchGroup()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
////                notifGroup.enter()
//                self.navigationItem.prompt = "Tap ➕ to add a roll"
////                notifGroup.leave()
//            })
//            //wait for the first to complete
////            notifGroup.wait()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
//                self.navigationItem.prompt = nil
//            })

        } else {
            //reload table
            //tableView.reloadData()

            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
//        //load the album
//        if let savedAlbum = Roll.loadAlbum() {
//            album = savedAlbum
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController.sections == nil || fetchedResultsController.sections?[0].numberOfObjects == 0 {
            self.navigationItem.prompt = "Tap ➕ to add a roll"
        } else {
            self.navigationItem.prompt = nil
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .automatic
        }
        
//        //reload album from file
//        if let savedAlbum = Roll.loadAlbum() {
//            album = savedAlbum
//        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setEditing(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rollCell", for: indexPath) as! HomeTableViewCell
        
        let roll = fetchedResultsController.object(at: indexPath)
        
        cell.update(with: roll)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //prepare for the destination's index path
        //rollIndexPath = indexPath

        performSegue(withIdentifier: "showRollSegue", sender: self)
    }

    
    // MARK: - Editing
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //present an alert to notify the user before delete
            let alertController = UIAlertController(title: "Delete Roll", message: "All data in this roll will be lost", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                
                let rollToDelete = self.fetchedResultsController.object(at: indexPath)
                self.dataController.viewContext.delete(rollToDelete)
                try? self.dataController.viewContext.save()
                
                
//                Roll.deleteRoll(at: indexPath)
//                if let albumLoaded = Roll.loadAlbum() {
//                    self.album = albumLoaded
//
//                    if self.album.isEmpty {
//                        self.setEditing(false, animated: true)
//                        self.navigationItem.leftBarButtonItem?.isEnabled = false
//                    }
//                }
                
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                tableView.beginUpdates()
//                tableView.endUpdates()
                
            }
            
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
            
            //pass the album object to the frame editing view controller
            if let indexPath = tableView.indexPathForSelectedRow {
                destination.roll = fetchedResultsController.object(at: indexPath)
                destination.dataController = dataController
                destination.navigationItem.leftBarButtonItem = nil
            }
            
//            //set the index path for usage
//            destination.rollIndexPath = rollIndexPath
        } else if segue.identifier == "addRollSegue" {
            let destination = segue.destination as! UINavigationController
            let addRollViewController = destination.topViewController as! AddRollViewController
            addRollViewController.dataController = dataController
        }
        
    }
    
}

extension HomeScreenTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        if controller.sections == nil || controller.sections?[0].numberOfObjects == 0 {
            self.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            break
        default:
            break
        }
        
        
    }
}
