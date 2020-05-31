//
//  AddLocationViewController.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var preloader: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    
    var location: CLLocationCoordinate2D?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showDetail") {
            let controller = segue.destination as! GeoCodingResultViewController
            controller.location = location
            controller.link = linkTextField.text
            controller.mapString = locationTextField.text
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        togglePreloader(isVisible: false)
    }
    
    func togglePreloader(isVisible: Bool) {
        preloader.isHidden = !isVisible
        submitButton.isEnabled = !isVisible
    }
    
    @IBAction func findLocationTapped(_ sender: Any) {
        
        guard !linkTextField.text!.isEmpty else {
            let alert = UIAlertController(title: "Please fill all the fields", message: "Link is empty and I feel sad :(", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true)
            return
        }
        
        togglePreloader(isVisible: true)
        
        getCoordinate(addressString: locationTextField.text!, completionHandler: {
            (coordinate, error) in
            self.togglePreloader(isVisible: false)
            if (error != nil) {
                self.showAlert(alertMessage: ApiClient.AlertMessage(title: "Geocoding fails", message: "And we can't find you on the map"), buttonTitle: "Ok")
            } else {
                DispatchQueue.main.async {
                    self.navigateToNextScreen(coordinate: coordinate)
                }
            }
        })
    }
    
    func getCoordinate( addressString : String, completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func navigateToNextScreen(coordinate: CLLocationCoordinate2D) {
        location = coordinate
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
