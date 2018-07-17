//
//  LocationSearchViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit

protocol LocationSearchViewControllerDelegate {
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String)
}

class LocationSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet weak var mapHeightConstraint: NSLayoutConstraint!
    
    var previousRegion: MKCoordinateRegion?
    var resultMapItems = [MKMapItem]()
    var delegate: LocationSearchViewControllerDelegate?
    
    var selectedLocation: CLLocation?
    var selectedName: String?
    var selectedDetail: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        searchResultTable.delegate = self
        searchResultTable.dataSource = self
        
        searchBar.delegate = self
        
        if let region = previousRegion {
            mapView.region = region
        }
        
        mapView.showsUserLocation = true
        
        searchResultTable.registerForKeyboardNotifications()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dropPin(with placemark: MKPlacemark) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        //show the annotation title automatically
        mapView.selectAnnotation(annotation, animated: true)
        
        let span = MKCoordinateSpanMake(0.002, 0.002)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func checkAndEnable() {
        if selectedLocation != nil && selectedName != nil && selectedDetail != nil {
            doneButton.isEnabled = true
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            self.mapHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.searchBar.showsCancelButton = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        //disable the done button while start editing (again)
        doneButton.isEnabled = false
    }
    
    func reverseAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.mapHeightConstraint.constant = 180
            self.view.layoutIfNeeded()
            self.searchBar.showsCancelButton = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {return}
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let response = response {
                self.resultMapItems = response.mapItems
                //let the table view to reload data
                self.searchResultTable.reloadData()
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reverseAnimation()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        reverseAnimation()
        //in case user has selscted a location before search again and want to cancel
        checkAndEnable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultMapItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
        
        let placeMark = resultMapItems[indexPath.row].placemark
        
        var locationName = ""
        var locationDetail = ""
        
        if let name = placeMark.name {
            locationName += name
        }
        
        locationDetail += placeMark.phrasePlacemarkDetail()
        
        cell.textLabel?.text = locationName
        cell.detailTextLabel?.text = locationDetail
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchResultTable.deselectRow(at: indexPath, animated: true)
        
        searchBar.resignFirstResponder()
        reverseAnimation()
        
        let selectedItem = resultMapItems[indexPath.row].placemark
        dropPin(with: selectedItem)
        
        
        //auto completes the search bar's text
        searchBar.text = selectedItem.name
        
        let location = CLLocation(latitude: selectedItem.coordinate.latitude, longitude: selectedItem.coordinate.longitude)
        
        selectedLocation = location
        selectedName = selectedItem.name
        selectedDetail = searchResultTable.cellForRow(at: indexPath)?.detailTextLabel?.text
        
        checkAndEnable()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "doneEditingLocationSegue" {
            
            if let location = selectedLocation,
                let title = selectedName,
                let detail = selectedDetail {
                
                delegate?.didUpdateLocationInfo(location: location, title: title, detail: detail)
            }
            
        }
    }
    

}
