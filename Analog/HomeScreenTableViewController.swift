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

    var dataController: DataController!
    
    var locationController: LocationController!
    
    var fetchedResultsController: NSFetchedResultsController<NewRoll>!
    
    @IBOutlet weak var addRollButton: UIBarButtonItem!
    
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
        tableView.tableFooterView = UIView()
        
        if fetchedResultsController.sections == nil || fetchedResultsController.sections?[0].numberOfObjects == 0 {
            self.navigationItem.leftBarButtonItem?.isEnabled = false

        } else {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
        //In order to detect shake motion
        self.becomeFirstResponder()
        
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
        
        refreshTable()
        
        //prevent undoing frame changes and undoing changes during launching
        dataController.viewContext.undoManager?.removeAllActions()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setEditing(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showRollSegue" && self.isEditing {
            return false
        } else {
            return true
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        guard let undoManager = dataController.viewContext.undoManager else {return}

        if undoManager.canUndo {
            let alertController = UIAlertController(title: "Undo", message: "Undo Action?", preferredStyle: .alert)
            
            let undoAction = UIAlertAction(title: "Undo", style: .default) { (action) in
                undoManager.undo()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(undoAction)
            
            present(alertController, animated: true, completion: nil)
        }
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
        if self.isEditing {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.isEditing {
            if tableView.indexPathsForSelectedRows == nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
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
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing == true {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(commitDeleteMultipleRolls))
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
        } else {
            self.navigationItem.rightBarButtonItem = addRollButton
        }
    }
    
    @objc func commitDeleteMultipleRolls() {
        let alertController = UIAlertController(title: "Delete Rolls", message: "Are you sure you want to delete these rolls?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            while self.tableView.indexPathsForSelectedRows != nil {
                let firstIndex = self.tableView.indexPathsForSelectedRows?.first
                let rollToDelete = self.fetchedResultsController.object(at: firstIndex!)
                self.dataController.viewContext.delete(rollToDelete)
                try? self.dataController.viewContext.save()
            }
            
            self.setEditing(false, animated: true)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func refreshTable(interval: TimeInterval = 40) {
        print("refreshing table")
        guard interval > 0 else {
            print("Time interval is negative")
            return
        }
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.refreshTable(interval: interval)
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func unwindToHome(unwindSegue: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRollSegue" {
            let destination = segue.destination as! FrameEditingViewController
            
            //pass the album object to the frame editing view controller
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell) {
                
                destination.roll = fetchedResultsController.object(at: indexPath)
                destination.dataController = dataController
                destination.locationController = locationController
                destination.navigationItem.leftBarButtonItem = nil
                
            }
        } else if segue.identifier == "addRollSegue" {
            let destination = segue.destination as! UINavigationController
            let addRollViewController = destination.topViewController as! AddRollViewController
            addRollViewController.dataController = dataController
            addRollViewController.locationController = locationController
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
            self.navigationItem.rightBarButtonItem?.isEnabled = true
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
