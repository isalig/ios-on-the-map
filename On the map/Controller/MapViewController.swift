//
//  MapViewController.swift
//  On the map
//
//  Created by Ischuk Alexander on 31.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var apiClient : ApiClient  {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.apiClient
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!)
            }
        }
    }
    
    
    func loadLocations() {
        
        apiClient.loadLocations(result: {locationResult, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.showAlert(alertMessage: self.apiClient.getAlertDataFromError(error: error!), buttonTitle: "Ok")
                }
                return
            }
            
            var annotations = [MKPointAnnotation]()
            
            DispatchQueue.main.async {
                let object = UIApplication.shared.delegate
                let appDelegate = object as! AppDelegate
                appDelegate.studentLocations.removeAll()
                appDelegate.studentLocations.append(contentsOf: locationResult!.results)
            }
            
            for studentLocation in locationResult!.results {
                let lat = CLLocationDegrees(studentLocation.latitude)
                let long = CLLocationDegrees(studentLocation.longitude)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                annotation.subtitle = studentLocation.mediaURL
                annotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            }
        })
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        apiClient.logout { (authResponse, error) in
            DispatchQueue.main.async {
                if (error != nil) {
                    self.showAlert(alertMessage: self.apiClient.getAlertDataFromError(error: error!), buttonTitle: "Ok")
                } else {
                    self.navigationController?.dismiss(animated: true, completion: nil)
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
