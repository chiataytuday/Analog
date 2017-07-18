//
//  AddRollViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class AddRollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
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
    
    @IBOutlet weak var filmSearchTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    //Constraint to animate
    @IBOutlet weak var searchBarLocationConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var zeroDistanceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        filmSearchTable.dataSource = self
        filmSearchTable.delegate = self
        searchBar.delegate = self
        //hide cancel button on searchBar
        searchBar.showsCancelButton = false
        //register for keyboard notification
        registerForKeyboardNotifications()
        // Do any additional setup after loading the view.
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
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArray = predefinedRolls.keys.filter({ (rollName) -> Bool in
            return rollName.lowercased().contains(searchText.lowercased())
        })
        
        if let searchText = searchBar.text {
            if !searchText.isEmpty && !filteredArray.contains("Not Listed?") {
                filteredArray.append("Not Listed?")
            }
        }
        
        filmSearchTable.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
        cancelButton.isHidden = true
        questionLabel.isHidden = true
        
        UIView.animate(withDuration: 0.2) {
            self.searchBarLocationConstraint.constant = 0.0
            self.zeroDistanceConstraint.constant = 0.0
            self.tableBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        cancelButton.isHidden = false
        questionLabel.isHidden = false
        
        UIView.animate(withDuration: 0.2) {
            self.searchBarLocationConstraint.constant = 288.0
            self.zeroDistanceConstraint.constant = 0.0
            self.tableBottomConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    //Keyboard inset registration
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: NSNotification) {
        guard let info = notification.userInfo, let keyboardFrameValue = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardFrameValue.cgRectValue
        let keyboardSize = keyboardFrame.size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
        filmSearchTable.contentInset = contentInsets
        filmSearchTable.scrollIndicatorInsets = contentInsets
        
    }
    
    
    func keyboardWillBeHidden(_ notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        filmSearchTable.contentInset = contentInsets
        filmSearchTable.scrollIndicatorInsets = contentInsets
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
