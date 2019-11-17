//
//  ViewController.swift
//  Homework1
//
//  Created by Niu Shang on 10/7/19.
//  Copyright © 2019 Niu Shang. All rights reserved.
//

import UIKit
import PhoneNumberKit
import MapKit
import CoreLocation
class ViewController: UIViewController ,CLLocationManagerDelegate,MKMapViewDelegate,UIGestureRecognizerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var currentLocation: UIButton!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        //add annoation
        setAllAnnotations()
        //add for long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(press:)))
        longPress.minimumPressDuration = 0.5

        mapView.addGestureRecognizer(longPress)
       
    }
    @objc func handleLongPress( press: UILongPressGestureRecognizer)
    {
        if press.state == .began {

            let touchPoint = press.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Event place"
            
            mapView.addAnnotation(annotation) //drops the pin
      }
    }
    
    func setAllAnnotations() {
        var pointAry :[MKPointAnnotation] = []
        
        let pin = MKPointAnnotation()
        pin.title = "Welcome to Davis"
        pin.coordinate = CLLocationCoordinate2D(latitude: 38.533958, longitude: -121.744560)
        
        let silo = MKPointAnnotation()
        silo.title = "Silo"
        silo.coordinate = CLLocationCoordinate2D(latitude: 38.5386986, longitude:  -121.7532308)
       
        let mu = MKPointAnnotation()
        mu.title = "MU"
        mu.coordinate = CLLocationCoordinate2D(latitude: 38.5424733, longitude: -121.7495532 )
        
        pointAry.append(pin)
        pointAry.append(silo)
        pointAry.append(mu)
        
        for point in pointAry{
            mapView.addAnnotation(point)
        }
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("Unknown location authorization")
        }
    }
    
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    @IBAction func currentLocationPressed(_ sender: Any) {
        centerViewOnUserLocation()
    }
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
//        {
//            if !(annotation is MKPointAnnotation) {
//                return nil
//            }
//
//            let annotationIdentifier = "AnnotationIdentifier"
//            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
//
//            if annotationView == nil {
//                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//                annotationView!.canShowCallout = true
//            }
//            else {
//                annotationView!.annotation = annotation
//            }
//
//                let pinImage = UIImage(named: "cowhead")
//                annotationView!.image = pinImage
//           
//
//
//           return annotationView
//    }
    
}







