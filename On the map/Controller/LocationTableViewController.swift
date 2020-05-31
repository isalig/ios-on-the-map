//
//  LocationTableViewController.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    var apiClient : ApiClient  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.apiClient
    }
    
    var locations: [StudentLocation]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.studentLocations
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")!
        let location = locations[indexPath.row]
        
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        cell.imageView!.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        
        let location = locations[indexPath.row]
        app.open(URL(string: location.mediaURL)!)
    }
    
    func loadLocations() {
        
        apiClient.loadLocations(result: {locationResult, error in
            
            if error != nil {
                self.showAlert(alertMessage: self.apiClient.getAlertDataFromError(error: error!), buttonTitle: "Ok")
                return
            }
            
            DispatchQueue.main.async {
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.studentLocations.removeAll()
                appDelegate.studentLocations.append(contentsOf: locationResult!.results)
                
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        apiClient.logout { (authResponse, error) in
            DispatchQueue.main.async {
                if let errorResponse = error {
                    self.showAlert(alertMessage: self.apiClient.getAlertDataFromError(error: errorResponse), buttonTitle: "Ok")
                } else {
                    DispatchQueue.main.async {
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func reloadTapped(_ sender: Any) {
        loadLocations()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let detailController = storyboard?.instantiateViewController(withIdentifier: "addPlaceController") as! UINavigationController
        detailController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        navigationController?.showDetailViewController(detailController, sender: self)
    }
}
